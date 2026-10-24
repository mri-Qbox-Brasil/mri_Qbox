-- Reports: player tickets answered by the staff in the mri_Qadmin Reports tab.
local PERM_VIEW <const> = 'qadmin.page.reports'
local PERM_MANAGE <const> = 'qadmin.action.manage_reports'
local PERM_DELETE <const> = 'qadmin.action.delete_report'
local PERM_CAPTURE <const> = 'qadmin.action.screen_capture'
local MESSAGE_MIN <const> = 3
local MESSAGE_MAX <const> = 1000
local STREET_MAX <const> = 120
local LIST_LIMIT <const> = 100
local MEDIA_MAX <const> = 2 * 1024 * 1024
local CAPTURE_TIMEOUT <const> = 10000
local CAPTURE_OPTIONS <const> = { encoding = 'webp', maxWidth = 1280, maxHeight = 720 }
local SNAPSHOT_TTL <const> = 900
local PLAYER_SHOT_COOLDOWN <const> = 20
local STATUSES <const> = { open = true, claimed = true, closed = true }
local COLUMNS <const> = [[id, citizenid, name, category, target_name AS targetName, status,
    staff_name AS staffName, staff_license AS staffLicense,
    UNIX_TIMESTAMP(created_at) AS createdAt, UNIX_TIMESTAMP(updated_at) AS updatedAt]]
local DETAIL_COLUMNS <const> = COLUMNS .. ', target_citizenid AS targetCitizenid, context'

local running = false
local schemaReady = false
---@type table<string, integer> citizenid -> os.time() of the last report
local lastReport = {}
---@type table<integer, integer> source -> os.time() of the last print sent in a chat
local lastShot = {}
---@type table<integer, { image: string?, context: table, at: integer }> what the player saw when the form opened
local pending = {}

local function Config() return Mri.cfg('reports') end
local function radius() return tonumber(Config().nearbyRadius) or 50.0 end

---@param source integer
---@param perm string
local function can(source, perm)
    if not source or source <= 0 then return false end
    if GetResourceState('mri_Qadmin') == 'started' then
        local ok, allowed = pcall(function() return exports.mri_Qadmin:HasPerms(source, perm) end)
        if ok then return allowed == true end
    end
    return IsPlayerAceAllowed(source, 'command')
end

---@return string? citizenId, string? name
local function character(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    local info = player.PlayerData.charinfo or {}
    local name = ('%s %s'):format(info.firstname or '', info.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '')
    return player.PlayerData.citizenid, name
end

local function license(source)
    return GetPlayerIdentifierByType(source, 'license') or ('src:%d'):format(source)
end

---@return integer?
local function onlineSource(citizenId)
    local player = citizenId and exports.qbx_core:GetPlayerByCitizenId(citizenId)
    return player and player.PlayerData.source or nil
end

local function staffSource(staffLicense)
    if not staffLicense then return end
    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id)
        if license(src) == staffLicense then return src end
    end
end

local function cleanText(value)
    if type(value) ~= 'string' then return end
    value = value:gsub('^%s+', ''):gsub('%s+$', '')
    if #value < MESSAGE_MIN then return end
    return value:sub(1, MESSAGE_MAX)
end

local function ensureColumn(tableName, column, definition)
    local found = MySQL.scalar.await([[SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?]], { tableName, column })
    if (tonumber(found) or 0) == 0 then
        MySQL.query.await(('ALTER TABLE `%s` ADD COLUMN %s'):format(tableName, definition))
    end
end

local function prepareSchema()
    if schemaReady then return end
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `mri_qbox_reports` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `citizenid` VARCHAR(50) NOT NULL,
            `name` VARCHAR(100) NOT NULL,
            `category` VARCHAR(60) NOT NULL,
            `target_citizenid` VARCHAR(50) DEFAULT NULL,
            `target_name` VARCHAR(100) DEFAULT NULL,
            `status` VARCHAR(10) NOT NULL DEFAULT 'open',
            `staff_name` VARCHAR(100) DEFAULT NULL,
            `staff_license` VARCHAR(80) DEFAULT NULL,
            `context` MEDIUMTEXT DEFAULT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `citizenid` (`citizenid`),
            KEY `status` (`status`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `mri_qbox_report_messages` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `report_id` INT NOT NULL,
            `author_name` VARCHAR(100) NOT NULL,
            `staff` TINYINT(1) NOT NULL DEFAULT 0,
            `message` TEXT NOT NULL,
            `media_id` INT DEFAULT NULL,
            `internal` TINYINT(1) NOT NULL DEFAULT 0,
            `event` VARCHAR(20) DEFAULT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `report_id` (`report_id`),
            CONSTRAINT `mri_qbox_report_messages_report` FOREIGN KEY (`report_id`) REFERENCES `mri_qbox_reports` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `mri_qbox_report_media` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `report_id` INT NOT NULL,
            `data` MEDIUMTEXT NOT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `report_id` (`report_id`),
            CONSTRAINT `mri_qbox_report_media_report` FOREIGN KEY (`report_id`) REFERENCES `mri_qbox_reports` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    -- Tables created by the first version of the module.
    ensureColumn('mri_qbox_reports', 'context', '`context` MEDIUMTEXT DEFAULT NULL')
    ensureColumn('mri_qbox_report_messages', 'media_id', '`media_id` INT DEFAULT NULL')
    ensureColumn('mri_qbox_report_messages', 'internal', '`internal` TINYINT(1) NOT NULL DEFAULT 0')
    ensureColumn('mri_qbox_report_messages', 'event', '`event` VARCHAR(20) DEFAULT NULL')
    schemaReady = true
end

local function loadReport(id)
    id = tonumber(id)
    if not id then return end
    return MySQL.single.await(('SELECT %s FROM mri_qbox_reports WHERE id = ?'):format(DETAIL_COLUMNS), { id })
end

local function decodeContext(report)
    local ok, context = pcall(json.decode, report.context or '')
    return ok and type(context) == 'table' and context or nil
end

-- Citizen ids the staff may act on from a report: its owner, the reported player and whoever was around.
local function reportPeople(report)
    local allowed = { [report.citizenid] = true }
    if report.targetCitizenid then allowed[report.targetCitizenid] = true end
    for _, person in ipairs((decodeContext(report) or {}).people or {}) do
        if person.citizenid then allowed[person.citizenid] = true end
    end
    return allowed
end

-- What the NUI gets: no staff license, who is online, whether the viewer holds it; context only for the staff.
local function present(report, viewer)
    local out = Mri.copy(report)
    out.online = onlineSource(report.citizenid) ~= nil
    out.mine = viewer ~= nil and report.staffLicense == license(viewer)
    out.staffLicense = nil
    out.context = nil
    if viewer then
        local context = decodeContext(report)
        if context then
            for _, person in ipairs(context.people or {}) do
                person.online = onlineSource(person.citizenid) ~= nil
                person.target = person.citizenid ~= nil and person.citizenid == report.targetCitizenid
            end
            out.context = context
        end
    else
        out.targetCitizenid = nil
    end
    return out
end

local function staffOnline()
    local list = {}
    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id)
        if can(src, PERM_VIEW) then list[#list + 1] = src end
    end
    return list
end

-- Refreshes the owner's window and every open staff tab.
local function broadcast(report)
    local sent = {}
    local owner = onlineSource(report.citizenid)
    if owner then
        TriggerClientEvent('mri_Qbox:reports:changed', owner, report.id)
        sent[owner] = true
    end
    for _, src in ipairs(staffOnline()) do
        if not sent[src] then TriggerClientEvent('mri_Qbox:reports:changed', src, report.id) end
    end
end

local function notify(source, key, ...)
    if source then TriggerClientEvent('ox_lib:notify', source, { title = locale('reports.title'), description = locale(key, ...), type = 'inform' }) end
end

local function webhook(message)
    local url = Config().webhook
    if type(url) ~= 'string' or not url:match('^https://') then return end
    PerformHttpRequest(url, function() end, 'POST', json.encode({ username = 'Reports', content = message }), { ['Content-Type'] = 'application/json' })
end

local function log(source, message, data)
    if GetResourceState('mri_Qadmin') ~= 'started' then return end
    pcall(function() exports.mri_Qadmin:AddLog(GetCurrentResourceName(), 'players', 'info', message, data, source) end)
end

---@param opts? { mediaId?: integer, internal?: boolean, event?: string }
local function addMessage(reportId, authorName, staff, message, opts)
    opts = opts or {}
    MySQL.insert.await([[INSERT INTO mri_qbox_report_messages (report_id, author_name, staff, message, media_id, internal, event)
        VALUES (?, ?, ?, ?, ?, ?, ?)]], { reportId, authorName, staff and 1 or 0, message or '', opts.mediaId, opts.internal and 1 or 0, opts.event })
    MySQL.update.await('UPDATE mri_qbox_reports SET updated_at = CURRENT_TIMESTAMP WHERE id = ?', { reportId })
end

local function setStatus(report, status, staffName, staffLicense)
    MySQL.update.await('UPDATE mri_qbox_reports SET status = ?, staff_name = ?, staff_license = ? WHERE id = ?',
        { status, staffName, staffLicense, report.id })
end

-- screencapture grabs the game frame without the NUI on top.
---@return string? dataUri
local function capture(target)
    if GetResourceState('screencapture') ~= 'started' or not GetPlayerName(target) then return end
    local p = promise.new()
    local settled = false
    local function settle(data)
        if settled then return end
        settled = true
        p:resolve(data)
    end
    if not pcall(function() exports.screencapture:serverCapture(target, CAPTURE_OPTIONS, settle) end) then return end
    SetTimeout(CAPTURE_TIMEOUT, function() settle(nil) end)
    local data = Citizen.Await(p)
    if type(data) ~= 'string' or #data > MEDIA_MAX or not data:find('^data:image/') then return end
    return data
end

local function saveMedia(reportId, data)
    return MySQL.insert.await('INSERT INTO mri_qbox_report_media (report_id, data) VALUES (?, ?)', { reportId, data })
end

-- Everyone within the configured radius, nearest first.
local function peopleAround(source)
    local me = GetEntityCoords(GetPlayerPed(source))
    local range = radius()
    local list = {}
    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id)
        local ped = GetPlayerPed(src)
        if src ~= source and ped ~= 0 then
            local distance = #(GetEntityCoords(ped) - me)
            local player = distance <= range and exports.qbx_core:GetPlayer(src)
            if player then
                local citizenId, name = character(src)
                local meta = player.PlayerData.metadata or {}
                local vehicle = GetVehiclePedIsIn(ped, false)
                list[#list + 1] = {
                    id = src,
                    name = name,
                    citizenid = citizenId,
                    distance = math.floor(distance + 0.5),
                    plate = vehicle ~= 0 and GetVehicleNumberPlateText(vehicle):gsub('^%s+', ''):gsub('%s+$', '') or nil,
                    down = meta.isdead == true or meta.inlaststand == true,
                }
            end
        end
    end
    table.sort(list, function(a, b) return a.distance < b.distance end)
    return list, me
end

local function buildContext(source, street)
    local people, coords = peopleAround(source)
    return {
        coords = { x = coords.x, y = coords.y, z = coords.z },
        street = type(street) == 'string' and street ~= '' and street:sub(1, STREET_MAX) or nil,
        people = people,
    }
end

-- ===== player =================================================================

local playerOps = {}

function playerOps.mine(source)
    local citizenId = character(source)
    if not citizenId then return { success = false, message = 'no_character' } end
    local rows = MySQL.query.await(('SELECT %s FROM mri_qbox_reports WHERE citizenid = ? ORDER BY id DESC LIMIT 30'):format(COLUMNS), { citizenId }) or {}
    for i = 1, #rows do rows[i] = present(rows[i]) end
    return { success = true, reports = rows, categories = Config().categories or {} }
end

function playerOps.get(source, data)
    local report = loadReport(type(data) == 'table' and data.id)
    if not report then return { success = false, message = 'not_found' } end
    local citizenId = character(source)
    local staff = can(source, PERM_VIEW)
    if report.citizenid ~= citizenId and not staff then return { success = false, message = 'no_permission' } end
    local rows = MySQL.query.await([[SELECT id, author_name AS authorName, staff, message, media_id AS mediaId, internal, event,
        UNIX_TIMESTAMP(created_at) AS createdAt FROM mri_qbox_report_messages WHERE report_id = ? ORDER BY id]], { report.id }) or {}
    local messages = {}
    for _, row in ipairs(rows) do
        row.staff = row.staff == 1 or row.staff == true
        row.internal = row.internal == 1 or row.internal == true
        if staff or not row.internal then messages[#messages + 1] = row end
    end
    return { success = true, report = present(report, staff and source or nil), messages = messages }
end

function playerOps.nearby(source)
    local list = {}
    for _, person in ipairs((peopleAround(source))) do list[#list + 1] = { id = person.id, name = person.name } end
    table.sort(list, function(a, b) return a.name < b.name end)
    return { success = true, players = list }
end

-- Taken when the new report form opens: the player sees the print and who goes along before sending.
function playerOps.snapshot(source, data)
    if not character(source) then return { success = false, message = 'no_character' } end
    local cfg = Config()
    local context = buildContext(source, type(data) == 'table' and data.street)
    local image = cfg.screenshot and capture(source) or nil
    pending[source] = { image = image, context = context, at = os.time() }
    local people = {}
    for _, person in ipairs(context.people) do people[#people + 1] = { id = person.id, name = person.name } end
    return { success = true, image = image, street = context.street, people = people, screenshot = cfg.screenshot == true }
end

function playerOps.create(source, data)
    if type(data) ~= 'table' then return { success = false, message = 'invalid' } end
    local cfg = Config()
    local citizenId, name = character(source)
    if not citizenId then return { success = false, message = 'no_character' } end

    local category
    for _, label in ipairs(cfg.categories or {}) do
        if label == data.category then category = label end
    end
    local message = cleanText(data.message)
    if not category or not message then return { success = false, message = 'invalid' } end

    local wait = (tonumber(cfg.cooldown) or 0) - (os.time() - (lastReport[citizenId] or 0))
    if wait > 0 then return { success = false, message = 'cooldown', wait = wait } end
    local open = MySQL.scalar.await("SELECT COUNT(*) FROM mri_qbox_reports WHERE citizenid = ? AND status <> 'closed'", { citizenId }) or 0
    if open >= (tonumber(cfg.maxOpen) or 3) then return { success = false, message = 'too_many' } end

    local snap = pending[source]
    pending[source] = nil
    if snap and os.time() - snap.at > SNAPSHOT_TTL then snap = nil end
    local context = snap and snap.context or buildContext(source)

    local targetCitizenId, targetName
    local target = tonumber(data.target)
    if target and GetPlayerPed(target) ~= 0
        and #(GetEntityCoords(GetPlayerPed(target)) - GetEntityCoords(GetPlayerPed(source))) <= radius() * 1.5 then
        targetCitizenId, targetName = character(target)
    end

    local id = MySQL.insert.await([[INSERT INTO mri_qbox_reports (citizenid, name, category, target_citizenid, target_name, context)
        VALUES (?, ?, ?, ?, ?, ?)]], { citizenId, name, category, targetCitizenId, targetName, json.encode(context) })
    if not id then return { success = false, message = 'unknown' } end
    addMessage(id, name, false, message)
    if snap and snap.image and data.screenshot ~= false then
        addMessage(id, name, false, '', { mediaId = saveMedia(id, snap.image) })
    end
    lastReport[citizenId] = os.time()

    local report = loadReport(id)
    broadcast(report)
    if cfg.notifyStaff then
        for _, src in ipairs(staffOnline()) do notify(src, 'reports.staff_new', id, name, category) end
    end
    webhook(('**Report #%d aberto** por %s (%s), %d por perto\n%s'):format(id, name, category, #context.people, message))
    return { success = true, id = id }
end

function playerOps.reply(source, data)
    if type(data) ~= 'table' then return { success = false, message = 'invalid' } end
    local report = loadReport(data.id)
    local message = cleanText(data.message)
    if not report or not message then return { success = false, message = 'invalid' } end

    local citizenId, name = character(source)
    local isOwner = report.citizenid == citizenId
    local isStaff = can(source, PERM_MANAGE)
    if not isOwner and not isStaff then return { success = false, message = 'no_permission' } end
    if report.status == 'closed' and not isStaff then return { success = false, message = 'closed' } end

    if isStaff and not isOwner and data.internal == true then
        addMessage(report.id, GetPlayerName(source), true, message, { internal = true })
    elseif isStaff and not isOwner then
        addMessage(report.id, GetPlayerName(source), true, message)
        if report.status == 'open' then setStatus(report, 'claimed', GetPlayerName(source), license(source)) end
        notify(onlineSource(report.citizenid), 'reports.player_reply', report.id)
    else
        addMessage(report.id, name, false, message)
        notify(staffSource(report.staffLicense), 'reports.staff_reply', report.id, name)
    end
    broadcast(report)
    return { success = true }
end

-- The owner sends a print of their own screen into the conversation.
function playerOps.screenshot(source, data)
    local report = loadReport(type(data) == 'table' and data.id)
    if not report then return { success = false, message = 'not_found' } end
    local citizenId, name = character(source)
    if report.citizenid ~= citizenId then return { success = false, message = 'no_permission' } end
    if report.status == 'closed' then return { success = false, message = 'closed' } end
    local wait = PLAYER_SHOT_COOLDOWN - (os.time() - (lastShot[source] or 0))
    if wait > 0 then return { success = false, message = 'shot_cooldown', wait = wait } end
    lastShot[source] = os.time()
    local image = capture(source)
    if not image then return { success = false, message = 'capture_failed' } end
    addMessage(report.id, name, false, '', { mediaId = saveMedia(report.id, image) })
    notify(staffSource(report.staffLicense), 'reports.staff_reply', report.id, name)
    broadcast(report)
    return { success = true }
end

-- A print is sent only to the staff or to the report owner, never an internal one to the owner.
function playerOps.media(source, data)
    local id = tonumber(type(data) == 'table' and data.id)
    if not id then return { success = false, message = 'invalid' } end
    local row = MySQL.single.await([[SELECT m.data, r.citizenid, msg.internal FROM mri_qbox_report_media m
        JOIN mri_qbox_reports r ON r.id = m.report_id
        LEFT JOIN mri_qbox_report_messages msg ON msg.media_id = m.id
        WHERE m.id = ? LIMIT 1]], { id })
    if not row then return { success = false, message = 'not_found' } end
    local internal = row.internal == 1 or row.internal == true
    if not can(source, PERM_VIEW) and (internal or row.citizenid ~= character(source)) then
        return { success = false, message = 'no_permission' }
    end
    return { success = true, data = row.data }
end

-- The owner may close their own report too.
function playerOps.close(source, data)
    local report = loadReport(type(data) == 'table' and data.id)
    if not report then return { success = false, message = 'not_found' } end
    local citizenId, name = character(source)
    local isStaff = can(source, PERM_MANAGE)
    if report.citizenid ~= citizenId and not isStaff then return { success = false, message = 'no_permission' } end
    setStatus(report, 'closed', report.staffName, report.staffLicense)
    local staffActing = isStaff and report.citizenid ~= citizenId
    addMessage(report.id, staffActing and GetPlayerName(source) or name, staffActing, '', { event = 'closed' })
    if staffActing then
        notify(onlineSource(report.citizenid), 'reports.player_closed', report.id)
        log(source, ('Fechou o report #%d de %s'):format(report.id, report.name), { report = report.id })
    end
    webhook(('**Report #%d fechado** por %s'):format(report.id, GetPlayerName(source)))
    broadcast(report)
    return { success = true }
end

-- ===== staff ==================================================================

local staffOps = {}

function staffOps.list(source, data)
    local status = type(data) == 'table' and STATUSES[data.status] and data.status or 'open'
    local order = status == 'closed' and 'updated_at DESC' or 'id ASC'
    local rows = MySQL.query.await(('SELECT %s FROM mri_qbox_reports WHERE status = ? ORDER BY %s LIMIT %d'):format(COLUMNS, order, LIST_LIMIT), { status }) or {}
    for i = 1, #rows do rows[i] = present(rows[i], source) end
    local counts = { open = 0, claimed = 0, closed = 0 }
    for _, row in ipairs(MySQL.query.await('SELECT status, COUNT(*) AS total FROM mri_qbox_reports GROUP BY status') or {}) do
        if counts[row.status] then counts[row.status] = row.total end
    end
    return {
        success = true, reports = rows, counts = counts,
        canManage = can(source, PERM_MANAGE), canDelete = can(source, PERM_DELETE), canCapture = can(source, PERM_CAPTURE),
    }
end

function staffOps.claim(source, data)
    if not can(source, PERM_MANAGE) then return { success = false, message = 'no_permission' } end
    local report = loadReport(type(data) == 'table' and data.id)
    if not report then return { success = false, message = 'not_found' } end
    setStatus(report, 'claimed', GetPlayerName(source), license(source))
    addMessage(report.id, GetPlayerName(source), true, '', { event = 'claimed' })
    notify(onlineSource(report.citizenid), 'reports.player_claimed', report.id)
    log(source, ('Assumiu o report #%d de %s'):format(report.id, report.name), { report = report.id })
    broadcast(report)
    return { success = true }
end

function staffOps.reopen(source, data)
    if not can(source, PERM_MANAGE) then return { success = false, message = 'no_permission' } end
    local report = loadReport(type(data) == 'table' and data.id)
    if not report then return { success = false, message = 'not_found' } end
    setStatus(report, 'claimed', GetPlayerName(source), license(source))
    addMessage(report.id, GetPlayerName(source), true, '', { event = 'reopened' })
    broadcast(report)
    return { success = true }
end

function staffOps.delete(source, data)
    if not can(source, PERM_DELETE) then return { success = false, message = 'no_permission' } end
    local report = loadReport(type(data) == 'table' and data.id)
    if not report then return { success = false, message = 'not_found' } end
    MySQL.update.await('DELETE FROM mri_qbox_reports WHERE id = ?', { report.id })
    log(source, ('Apagou o report #%d de %s'):format(report.id, report.name), { report = report.id })
    broadcast(report)
    return { success = true }
end

local function moveTo(ped, coords)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
end

-- visit: staff to the player; bring: the player to the staff.
local function teleport(source, data, bring)
    if not can(source, PERM_MANAGE) then return { success = false, message = 'no_permission' } end
    local report = loadReport(type(data) == 'table' and data.id)
    local target = report and onlineSource(report.citizenid)
    if not target then return { success = false, message = 'offline' } end
    local from, to = GetPlayerPed(target), GetPlayerPed(source)
    if not bring then from, to = to, from end
    moveTo(from, GetEntityCoords(to))
    log(source, ('%s o jogador do report #%d (%s)'):format(bring and 'Trouxe' or 'Foi até', report.id, report.name), { report = report.id, target_src = target })
    return { success = true }
end

function staffOps.visit(source, data) return teleport(source, data, false) end
function staffOps.bring(source, data) return teleport(source, data, true) end

-- Staff to where the report was opened, even if the player has moved since.
function staffOps.location(source, data)
    if not can(source, PERM_MANAGE) then return { success = false, message = 'no_permission' } end
    local report = loadReport(type(data) == 'table' and data.id)
    local coords = report and (decodeContext(report) or {}).coords
    if not coords then return { success = false, message = 'not_found' } end
    moveTo(GetPlayerPed(source), coords)
    log(source, ('Foi ao local do report #%d (%s)'):format(report.id, report.name), { report = report.id })
    return { success = true }
end

---@return table? report, integer? target, string? error
local function personOf(source, data, perm)
    if not can(source, perm) then return nil, nil, 'no_permission' end
    local report = loadReport(type(data) == 'table' and data.id)
    if not report then return nil, nil, 'not_found' end
    local citizenId = type(data.citizenid) == 'string' and data.citizenid or nil
    if not citizenId or not reportPeople(report)[citizenId] then return nil, nil, 'invalid' end
    local target = onlineSource(citizenId)
    if not target then return nil, nil, 'offline' end
    return report, target
end

-- Staff to anyone tied to the report (owner, reported player or someone who was around).
function staffOps.gotoPerson(source, data)
    local report, target, err = personOf(source, data, PERM_MANAGE)
    if not report then return { success = false, message = err } end
    moveTo(GetPlayerPed(source), GetEntityCoords(GetPlayerPed(target)))
    log(source, ('Foi até %s pelo report #%d'):format(GetPlayerName(target) or target, report.id), { report = report.id, target_src = target })
    return { success = true }
end

-- Print of the screen of someone tied to the report, kept as an internal staff message.
function staffOps.capture(source, data)
    local report, target, err = personOf(source, data, PERM_CAPTURE)
    if not report then return { success = false, message = err } end
    local image = capture(target)
    if not image then return { success = false, message = 'capture_failed' } end
    local _, name = character(target)
    addMessage(report.id, GetPlayerName(source), true, ('Print da tela de %s'):format(name or GetPlayerName(target)), { mediaId = saveMedia(report.id, image), internal = true })
    log(source, ('Tirou print da tela de %s pelo report #%d'):format(GetPlayerName(target) or target, report.id), { report = report.id, target_src = target })
    broadcast(report)
    return { success = true }
end

lib.callback.register('mri_Qbox:reports:call', function(source, op, data)
    if not running then return { success = false, message = 'disabled' } end
    local handler = playerOps[op]
    if not handler then
        handler = staffOps[op]
        if not handler or not can(source, PERM_VIEW) then return { success = false, message = 'no_permission' } end
    end
    local ok, result = pcall(handler, source, data)
    if not ok then
        lib.print.error(('[mri_Qbox] reports %s: %s'):format(op, result))
        return { success = false, message = 'unknown' }
    end
    return result
end)

AddEventHandler('playerDropped', function()
    pending[source] = nil
    lastShot[source] = nil
end)

-- ===== Reports tab in mri_Qadmin ==============================================

local function registerPlugin()
    if not running or GetResourceState('mri_Qadmin') ~= 'started' then return end
    local ok, err = pcall(function()
        exports['mri_Qadmin']:RegisterPlugin({
            id = 'reports',
            label = 'Reports',
            icon = 'flag',
            resource = GetCurrentResourceName(),
            htmlPath = 'html/reports.html',
            requiredPerms = { PERM_VIEW },
            description = 'Reports dos jogadores: assumir, responder, ver o print e quem estava perto, e fechar',
            sidebar = true,
        })
    end)
    if not ok then
        lib.print.warn(('[mri_Qbox] Falha ao registrar a aba Reports no mri_Qadmin: %s'):format(tostring(err)))
    end
end

AddEventHandler('mri_Qadmin:server:pluginsReady', registerPlugin)

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'mri_Qadmin' then registerPlugin() end
end)

Mri.lifecycle('reports', function()
    prepareSchema()
    running = true
    registerPlugin()
end, function()
    running = false
    if GetResourceState('mri_Qadmin') == 'started' then pcall(function() exports['mri_Qadmin']:UnregisterPlugin('reports') end) end
end)
