-- Passport = players.id, kept by qbx_core but never loaded; ox_lib resolves playerId params through it
local COMMANDS_KEY = 'mri:passportCommands'
local ADMIN_ACES = { 'mri_Qbox.admin', 'command' }

local running = false
local firstPassport = 1
-- source -> passport; the statebag is for display only, a client can write its own
---@type table<integer, integer>
local passports = {}

---@param source integer
---@param passport integer?
local function setPassport(source, passport)
    passports[source] = passport
    Player(source).state:set('passport', passport, true)
end

---@param citizenId string
---@return integer?
local function fetchPassport(citizenId)
    return MySQL.scalar.await('SELECT id FROM players WHERE citizenid = ?', { citizenId })
end

---@param source integer
local function assign(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    setPassport(source, fetchPassport(player.PlayerData.citizenid))
end

-- sent by the multichar after load and after creation, when the players row already exists
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    if running then assign(source) end
end)

AddEventHandler('qbx_core:server:playerLoggedOut', function(source)
    setPassport(source, nil)
end)

AddEventHandler('playerDropped', function()
    passports[source] = nil
end)

-- InnoDB raises a lower AUTO_INCREMENT to MAX(id) + 1 by itself, so lowering never reuses a number
---@param passport integer
local function reserveBelow(passport)
    if passport <= 1 then return end
    if (MySQL.scalar.await('SELECT MAX(id) FROM players') or 0) >= passport - 1 then return end
    MySQL.query.await(('ALTER TABLE players AUTO_INCREMENT = %d'):format(passport))
end

-- Passaportes tab in mri_Qadmin, only while the module is on
local function registerPlugin()
    if not running or GetResourceState('mri_Qadmin') ~= 'started' then return end
    local ok, err = pcall(function()
        exports['mri_Qadmin']:RegisterPlugin({
            id = 'passport',
            label = 'Passaportes',
            icon = 'id-card',
            resource = GetCurrentResourceName(),
            htmlPath = 'html/passport.html',
            requiredPerms = ADMIN_ACES,
            description = 'Lista de personagens com o passaporte de cada um e troca de passaporte',
        })
    end)
    if not ok then
        lib.print.warn(('[mri_Qbox] Falha ao registrar a aba Passaportes no mri_Qadmin: %s'):format(tostring(err)))
    end
end

AddEventHandler('mri_Qadmin:server:pluginsReady', registerPlugin)

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'mri_Qadmin' then registerPlugin() end
end)

Mri.lifecycle('passport', function(cfg)
    running = true
    firstPassport = math.max(1, math.floor(tonumber(cfg.firstPassport) or 1))
    reserveBelow(firstPassport)
    GlobalState[COMMANDS_KEY] = cfg.commands == true
    for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
        assign(player.PlayerData.source)
    end
    registerPlugin()
end, function()
    running = false
    if GetResourceState('mri_Qadmin') == 'started' then pcall(function() exports['mri_Qadmin']:UnregisterPlugin('passport') end) end
    GlobalState[COMMANDS_KEY] = false
    for source in pairs(passports) do
        setPassport(source, nil)
    end
end)

---@param source integer
---@return integer?
local function getPlayerPassport(source)
    return passports[tonumber(source)]
end

---@param passport integer
---@return integer? source
local function getPlayerByPassport(passport)
    passport = tonumber(passport)
    if not passport then return end
    for source, id in pairs(passports) do
        if id == passport then return source end
    end
end

-- works offline too (ban, give item to someone who left)
---@param passport integer
---@return string? citizenId
local function getCitizenIdByPassport(passport)
    passport = tonumber(passport)
    if not passport then return end
    return MySQL.scalar.await('SELECT citizenid FROM players WHERE id = ?', { passport })
end

-- only reserved or freed numbers: one above the counter would later collide with a new character
---@param citizenId string
---@param passport integer
---@return boolean ok, 'invalid'|'not_found'|'taken'|'not_reserved'? reason
local function setCitizenPassport(citizenId, passport)
    passport = tonumber(passport)
    if type(citizenId) ~= 'string' or not passport or passport < 1 or passport % 1 ~= 0 then return false, 'invalid' end
    local row = MySQL.single.await('SELECT id, (SELECT MAX(id) FROM players) AS maxId FROM players WHERE citizenid = ?', { citizenId })
    if not row then return false, 'not_found' end
    if row.id == passport then return true end
    if passport >= math.max(firstPassport, row.maxId) then return false, 'not_reserved' end
    if MySQL.scalar.await('SELECT 1 FROM players WHERE id = ?', { passport }) then return false, 'taken' end
    -- the primary key still guards a race between the check and the update
    local ok, changed = pcall(MySQL.update.await, 'UPDATE players SET id = ? WHERE citizenid = ?', { passport, citizenId })
    if not ok or changed ~= 1 then return false, 'taken' end
    local player = exports.qbx_core:GetPlayerByCitizenId(citizenId)
    if player and running then setPassport(player.PlayerData.source, passport) end
    return true
end

local LIST_LIMIT = 200

local function isAdmin(source)
    for i = 1, #ADMIN_ACES do
        if IsPlayerAceAllowed(source, ADMIN_ACES[i]) then return true end
    end
    return false
end

lib.callback.register('mri_Qbox:passport:list', function(source, search)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    search = type(search) == 'string' and search:sub(1, 60):gsub('^%s+', ''):gsub('%s+$', '') or ''
    local like = ('%%%s%%'):format(search)
    local rows = MySQL.query.await([[
        SELECT id, citizenid,
            CONCAT_WS(' ', JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')), JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname'))) AS name
        FROM players
        WHERE ? = '' OR id = ? OR citizenid LIKE ?
            OR CONCAT_WS(' ', JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')), JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname'))) LIKE ?
        ORDER BY id LIMIT ]] .. LIST_LIMIT, { search, tonumber(search) or -1, like, like }) or {}

    local online = {}
    for _, passport in pairs(passports) do online[passport] = true end
    local characters = {}
    for i = 1, #rows do
        local row = rows[i]
        characters[i] = { passport = row.id, citizenId = row.citizenid, name = row.name or '', online = online[row.id] == true }
    end

    local taken = firstPassport > 1 and MySQL.scalar.await('SELECT COUNT(*) FROM players WHERE id < ?', { firstPassport }) or 0
    return {
        success = true,
        characters = characters,
        limited = #rows == LIST_LIMIT,
        firstPassport = firstPassport,
        freeReserved = math.max(0, firstPassport - 1 - taken),
    }
end)

lib.callback.register('mri_Qbox:passport:set', function(source, data)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    if type(data) ~= 'table' then return { success = false, message = 'invalid' } end
    local ok, reason = setCitizenPassport(data.citizenId, data.passport)
    return { success = ok, message = reason }
end)

exports('GetPlayerPassport', getPlayerPassport)
exports('GetPlayerByPassport', getPlayerByPassport)
exports('GetCitizenIdByPassport', getCitizenIdByPassport)
exports('SetCitizenPassport', setCitizenPassport)
