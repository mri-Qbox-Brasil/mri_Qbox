-- Inventory editor: ox_inventory data/*.lua is the base; edits go to data/inventory.json and the GlobalState its mri/data.lua reads.

local FILE = 'data/inventory.json'
-- MRI defaults over the ox_inventory file, read by its mri/data.lua too: each entry replaces, false removes
local LAYER_FILE = 'resources/modules/inventory/base/%s.lua'
local KEY = 'mri:inventory:%s'
local ADMIN_ACES = { 'mri_Qbox.admin', 'command' }

local CATALOGS = {
    items = true, weapons = true, shops = true, crafting = true, licenses = true,
    stashes = true, evidence = true, vehicles = true, animations = true,
}
local ARRAYS = { crafting = true, licenses = true, stashes = true, evidence = true }
local SECTIONS = {
    weapons = { Weapons = true, Components = true, Ammo = true, Tints = true },
    animations = { anim = true, prop = true },
    vehicles = { Storage = true, trunk = true, glovebox = true, ['trunk.models'] = true, ['glovebox.models'] = true },
}

---@param source integer
local function isAdmin(source)
    if source == 0 then return true end
    for i = 1, #ADMIN_ACES do
        if IsPlayerAceAllowed(source, ADMIN_ACES[i]) then return true end
    end
    return false
end

local function isList(value)
    return type(value) == 'table' and value[1] ~= nil
end

local function same(a, b)
    if type(a) ~= 'table' or type(b) ~= 'table' then return a == b end
    for k, v in pairs(a) do
        if not same(v, b[k]) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

-- same merge as the ox_inventory mri/data.lua: maps key by key, lists and values replace
local function merge(base, patch)
    if type(base) ~= 'table' or type(patch) ~= 'table' or isList(base) or isList(patch) then
        return Mri.copy(patch)
    end
    for k, v in pairs(patch) do base[k] = merge(base[k], v) end
    return base
end

-- the smallest patch that turns base into value (nil when equal)
local function diff(base, value)
    if same(base, value) then return nil end
    if type(base) ~= 'table' or type(value) ~= 'table' or isList(base) or isList(value) then return value end
    local patch = {}
    for k, v in pairs(value) do
        local change = diff(base[k], v)
        if change ~= nil then patch[k] = change end
    end
    return next(patch) and patch or nil
end

local function toVectors(value)
    if type(value) ~= 'table' then return value end
    local x, y, z, w = value.x, value.y, value.z, value.w
    local size = 0
    for _ in pairs(value) do size = size + 1 end
    if type(x) == 'number' and type(y) == 'number' and type(z) == 'number' then
        if size == 3 then return vec3(x, y, z) end
        if size == 4 and type(w) == 'number' then return vec4(x, y, z, w) end
    end
    local out = {}
    for k, v in pairs(value) do out[k] = toVectors(v) end
    return out
end

-- what the NUI can hold: vectors as {x, y, z}, functions dropped (flags.code tells the screen)
local function plain(value, flags)
    local kind = type(value)
    if kind == 'function' then
        flags.code = true
        return nil
    end
    if kind == 'vector3' then return { x = value.x, y = value.y, z = value.z } end
    if kind == 'vector4' then return { x = value.x, y = value.y, z = value.z, w = value.w } end
    if kind == 'vector2' then return { x = value.x, y = value.y } end
    if kind ~= 'table' then return value end
    local out, count, sequence = {}, 0, true
    for k, v in pairs(value) do out[k] = plain(v, flags) end
    for k in pairs(out) do
        count += 1
        if math.type(k) ~= 'integer' or k < 1 then sequence = false end
    end
    if sequence and count == #out then return out end
    -- mixed or sparse tables crash the game on the way to the NUI (msgpack type_error): string keys only
    local map = {}
    for k, v in pairs(out) do map[tostring(k)] = v end
    return map
end

---@type table<string, table<string, any>> edits as saved in the json (plain values)
local saved = {}
do
    local raw = LoadResourceFile(GetCurrentResourceName(), FILE)
    local ok, data = pcall(json.decode, raw or '{}')
    if ok and type(data) == 'table' then
        saved = data
    else
        lib.print.error(('%s inválido: o editor do inventário começa vazio'):format(FILE))
    end
end

local publishQstashes, publishQcrafting

local function publish(catalog)
    SaveResourceFile(GetCurrentResourceName(), FILE, json.encode(saved, { indent = true }), -1)
    local edits = saved[catalog]
    GlobalState[KEY:format(catalog)] = edits and next(edits) and toVectors(edits) or nil
    if catalog == 'stashes' then publishQstashes() end
    if catalog == 'crafting' then publishQcrafting() end
end

---@type table<integer, string>?
local modelNames

local function modelName(hash)
    if type(hash) ~= 'number' then return tostring(hash) end
    if not modelNames then
        modelNames = {}
        for model in pairs(exports.qbx_core:GetVehiclesByName()) do modelNames[joaat(model)] = model end
    end
    return modelNames[hash] or tostring(hash)
end

---@type table<string, table>
local fileCache = {}

-- the ox_inventory file as it ships, run with the globals it expects
local function loadFile(catalog)
    if fileCache[catalog] then return fileCache[catalog] end
    local raw = LoadResourceFile('ox_inventory', ('data/%s.lua'):format(catalog))
    if not raw then return {} end

    local police = json.decode(GetConvar('inventory:police', '["police", "sheriff"]'))
    if type(police) == 'string' then police = { police } end
    local groups = {}
    for i = 1, #police do groups[police[i]] = 0 end

    local env = setmetatable({ shared = { police = groups, target = GetConvar('inventory:target', 'false') == 'true' } }, { __index = _G })
    local chunk, err = load(raw, ('@@ox_inventory/data/%s.lua'):format(catalog), 't', env)
    local ok, data = false, err
    if chunk then ok, data = pcall(chunk) end
    if not ok or type(data) ~= 'table' then
        lib.print.error(('não deu pra ler ox_inventory/data/%s.lua: %s'):format(catalog, data))
        return {}
    end

    local layerFile = LAYER_FILE:format(catalog)
    local layerRaw = LoadResourceFile(GetCurrentResourceName(), layerFile)
    if layerRaw then
        local layerChunk, layerErr = load(layerRaw, ('@@mri_Qbox/%s'):format(layerFile), 't', env)
        local layerOk, entries = false, layerErr
        if layerChunk then layerOk, entries = pcall(layerChunk) end
        if layerOk and type(entries) == 'table' then
            -- same rule as ox_inventory mri/data.lua: an owner-edited file keeps its entries
            local okExport, replace = pcall(function() return exports.ox_inventory:MriOriginalFile(catalog) end)
            replace = okExport and replace == true
            for id, entry in pairs(entries) do
                if replace then
                    data[id] = entry ~= false and entry or nil
                elseif entry ~= false and data[id] == nil then
                    data[id] = entry
                end
            end
        else
            lib.print.error(('não deu pra ler %s: %s'):format(layerFile, entries))
        end
    end

    fileCache[catalog] = data
    return data
end

-- the file as id -> entry, ids as the ox_inventory mri/data.lua reads them
---@return table<string, any>
local function baseEntries(catalog)
    local data, list = loadFile(catalog), {}

    if ARRAYS[catalog] then
        for i, entry in ipairs(data) do list[entry.name or ('#%d'):format(i)] = entry end
    elseif SECTIONS[catalog] then
        for section, entries in pairs(data) do
            for key, entry in pairs(entries) do
                if catalog == 'vehicles' and key == 'models' then
                    for hash, value in pairs(entry) do list[('%s.models:%s'):format(section, modelName(hash))] = value end
                else
                    list[('%s:%s'):format(section, section == 'Storage' and modelName(key) or key)] = entry
                end
            end
        end
    else
        for id, entry in pairs(data) do list[id] = entry end
    end

    return list
end

---@param catalog string
---@param id unknown
---@return string?
local function cleanId(catalog, id)
    if type(id) ~= 'string' then return end
    id = id:match('^%s*(.-)%s*$')
    if id == '' or #id > 100 or not id:match('^[%w_%-%.:#]+$') then return end
    local sections = SECTIONS[catalog]
    if sections then
        local section = id:match('^(.-):.+$')
        if not section or not sections[section] then return end
    elseif id:find(':') then
        return
    end
    return id
end

-- One path for the editor, the exports and the console: validate, keep the smallest patch, publish.
---@return boolean ok, string idOrMessage
local function saveEntry(catalog, id, value)
    if not CATALOGS[catalog] then return false, 'invalid_catalog' end
    id = cleanId(catalog, id)
    if not id then return false, 'invalid_id' end
    if type(value) ~= 'table' then return false, 'invalid_data' end

    local edits = saved[catalog] or {}
    local base = baseEntries(catalog)[id]

    -- a file entry keeps only what changed; a new one is saved whole
    if base ~= nil then
        edits[id] = diff(plain(base, {}), value)
    else
        edits[id] = value
    end

    saved[catalog] = next(edits) and edits or nil
    publish(catalog)
    return true, id
end

---@return boolean ok, string? message
local function removeEntry(catalog, id)
    if not CATALOGS[catalog] or type(id) ~= 'string' then return false, 'invalid_data' end
    local edits = saved[catalog] or {}
    -- a file entry is marked false; an added one is just deleted (`x and false or nil` is always nil)
    if baseEntries(catalog)[id] ~= nil then
        edits[id] = false
    else
        edits[id] = nil
    end
    saved[catalog] = next(edits) and edits or nil
    publish(catalog)
    return true
end

---@return boolean ok, string? message
local function restoreEntry(catalog, id)
    if not CATALOGS[catalog] or type(id) ~= 'string' then return false, 'invalid_data' end
    local edits = saved[catalog]
    if edits then
        edits[id] = nil
        saved[catalog] = next(edits) and edits or nil
        publish(catalog)
    end
    return true
end

-- The entry as the inventory sees it now (plain values), plus where it comes from.
---@return table? value, string? status
local function getEntry(catalog, id)
    if not CATALOGS[catalog] or type(id) ~= 'string' then return end
    local edit = (saved[catalog] or {})[id]
    local base = baseEntries(catalog)[id]
    if edit == false then return nil, 'removed' end
    if base == nil then return edit and Mri.copy(edit) or nil, edit and 'added' or nil end
    local value = plain(base, {})
    if edit == nil then return value, 'base' end
    return merge(value, edit), 'edited'
end

---@return { id: string, status: string }[]?
local function listEntries(catalog)
    if not CATALOGS[catalog] then return end
    local edits, list, base = saved[catalog] or {}, {}, baseEntries(catalog)
    for id in pairs(base) do
        local edit = edits[id]
        list[#list + 1] = { id = id, status = edit == false and 'removed' or edit ~= nil and 'edited' or 'base' }
    end
    for id, edit in pairs(edits) do
        if edit and base[id] == nil then list[#list + 1] = { id = id, status = 'added' } end
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

-- The mri_Qstashes panel lists the ox_inventory stashes beside its own; they keep being edited here.
publishQstashes = function()
    if GetResourceState('mri_Qstashes') ~= 'started' then return end
    local list = {}
    for _, row in ipairs(listEntries('stashes') or {}) do
        local stash = row.status ~= 'removed' and getEntry('stashes', row.id)
        local target = type(stash) == 'table' and type(stash.target) == 'table' and stash.target.loc
        local coords = type(stash) == 'table' and (target or stash.coords)
        if coords then
            local groups = {}
            for name in pairs(type(stash.groups) == 'table' and stash.groups or {}) do groups[#groups + 1] = tostring(name) end
            list[#list + 1] = { id = row.id, label = stash.label or row.id, coords = coords, groups = groups, personal = stash.owner == true }
        end
    end
    pcall(function()
        exports.mri_Qstashes:SetExternalStashes(list, { label = 'Editor do inventário', plugin = 'inventory' })
    end)
end

-- The mri_Qcrafting panel lists the ox_inventory benches beside its own, one per spot (zones or points).
publishQcrafting = function()
    if GetResourceState('mri_Qcrafting') ~= 'started' then return end
    local list = {}
    for _, row in ipairs(listEntries('crafting') or {}) do
        local bench = row.status ~= 'removed' and getEntry('crafting', row.id)
        if type(bench) == 'table' then
            local groups = {}
            for name in pairs(type(bench.groups) == 'table' and bench.groups or {}) do groups[#groups + 1] = tostring(name) end
            local spots = {}
            for _, zone in ipairs(type(bench.zones) == 'table' and bench.zones or {}) do
                if type(zone) == 'table' and zone.coords then spots[#spots + 1] = zone.coords end
            end
            if #spots == 0 then
                for _, point in ipairs(type(bench.points) == 'table' and bench.points or {}) do spots[#spots + 1] = point end
            end
            local label = tostring(bench.label or bench.name or row.id)
            for index, coords in ipairs(spots) do
                list[#list + 1] = {
                    id = ('%s:%d'):format(row.id, index),
                    label = #spots > 1 and ('%s %d'):format(label, index) or label,
                    coords = coords,
                    groups = groups,
                    recipes = #(type(bench.items) == 'table' and bench.items or {}),
                }
            end
        end
    end
    pcall(function()
        exports.mri_Qcrafting:SetExternalBenches(list, { label = 'Editor do inventário', plugin = 'inventory' })
    end)
end

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'mri_Qstashes' then publishQstashes() end
    if resourceName == 'mri_Qcrafting' then publishQcrafting() end
end)

CreateThread(function()
    Wait(0)
    publishQstashes()
    publishQcrafting()
end)

lib.callback.register('mri_Qbox:inventory:qstashes', function(source)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    if GetResourceState('mri_Qstashes') ~= 'started' then return { success = false, message = 'missing' } end
    local ok, stashes = pcall(function() return exports.mri_Qstashes:GetStashes() end)
    if not ok or type(stashes) ~= 'table' then return { success = false, message = 'missing' } end
    local list = {}
    for _, stash in ipairs(stashes) do
        list[#list + 1] = { id = stash.id, label = stash.label, slots = stash.slots, weight = stash.weight, personal = stash.personal == true }
    end
    return { success = true, stashes = list }
end)

exports('GetInventoryEntry', getEntry)
exports('ListInventoryEntries', listEntries)
exports('SaveInventoryEntry', saveEntry)
exports('RemoveInventoryEntry', removeEntry)
exports('RestoreInventoryEntry', restoreEntry)

-- Server console only (agents through txAdmin): one JSON line per answer, easy to parse.
RegisterCommand('mri_inventory', function(source, _, raw)
    if source ~= 0 then return end
    local action, catalog, id, body = raw:match('^%S+%s+(%S+)%s*(%S*)%s*(%S*)%s*(.-)%s*$')
    local result

    if action == 'list' then
        local list = listEntries(catalog)
        result = list and { success = true, entries = list } or { success = false, message = 'invalid_catalog' }
    elseif action == 'get' then
        local value, status = getEntry(catalog, id)
        result = { success = status ~= nil, status = status, value = value }
    elseif action == 'set' then
        local ok, value = pcall(json.decode, body)
        if not ok or type(value) ~= 'table' then
            result = { success = false, message = 'invalid_json' }
        else
            local saveOk, info = saveEntry(catalog, id, value)
            result = { success = saveOk, id = saveOk and info or nil, message = not saveOk and info or nil }
        end
    elseif action == 'remove' or action == 'restore' then
        local ok, message = (action == 'remove' and removeEntry or restoreEntry)(catalog, id)
        result = { success = ok, message = message }
    else
        result = { success = false, message = 'usage: mri_inventory list|get|set|remove|restore <catalog> [id] [json]' }
    end

    print('[mri_inventory] ' .. json.encode(result))
end, true)

lib.callback.register('mri_Qbox:inventory:get', function(source, catalog)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    if not CATALOGS[catalog] then return { success = false, message = 'invalid_catalog' } end

    local edits = saved[catalog] or {}
    local base = baseEntries(catalog)
    local entries = {}

    for id, entry in pairs(base) do
        local flags = {}
        local value = plain(entry, flags)
        local edit = edits[id]
        entries[#entries + 1] = {
            id = id,
            value = (edit == false or edit == nil) and value or merge(Mri.copy(value), edit),
            status = edit == false and 'removed' or edit ~= nil and 'edited' or 'base',
            code = flags.code or nil,
        }
    end

    for id, edit in pairs(edits) do
        if edit and base[id] == nil then
            entries[#entries + 1] = { id = id, value = edit, status = 'added' }
        end
    end

    return { success = true, entries = entries }
end)

-- names and labels for the item pickers (shops, crafting)
lib.callback.register('mri_Qbox:inventory:itemNames', function(source)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end

    local names = {}
    for _, catalog in ipairs({ 'items', 'weapons' }) do
        local edits = saved[catalog] or {}
        local base = baseEntries(catalog)
        for id, entry in pairs(base) do
            local edit = edits[id]
            if edit ~= false then
                local name = id:match(':(.+)$') or id
                names[#names + 1] = { name = name, label = edit and edit.label or entry.label or name }
            end
        end
        for id, edit in pairs(edits) do
            if edit and base[id] == nil then
                local name = id:match(':(.+)$') or id
                names[#names + 1] = { name = name, label = edit.label or name }
            end
        end
    end

    return { success = true, items = names }
end)

lib.callback.register('mri_Qbox:inventory:save', function(source, catalog, id, value)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    local ok, info = saveEntry(catalog, id, value)
    if not ok then return { success = false, message = info } end
    return { success = true, id = info }
end)

lib.callback.register('mri_Qbox:inventory:remove', function(source, catalog, id)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    local ok, message = removeEntry(catalog, id)
    return { success = ok, message = message }
end)

lib.callback.register('mri_Qbox:inventory:restore', function(source, catalog, id)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    local ok, message = restoreEntry(catalog, id)
    return { success = ok, message = message }
end)

lib.callback.register('mri_Qbox:inventory:give', function(source, name)
    if not isAdmin(source) or source == 0 then return { success = false, message = 'no_permission' } end
    if type(name) ~= 'string' then return { success = false, message = 'invalid_data' } end

    local ok, response = exports.ox_inventory:AddItem(source, name, 1)
    if not ok then return { success = false, message = response or 'give_failed' } end
    return { success = true }
end)

lib.callback.register('mri_Qbox:inventory:canTeleport', function(source)
    return source ~= 0 and isAdmin(source)
end)

-- ===== Ajustes: the inventory:* convars, applied by ox_inventory mri/settings.lua ===========

local SETTINGS_KEY = 'mri:inventory:settings'

local function intSetting(min, max)
    return function(v)
        v = tonumber(v)
        if not v or v % 1 ~= 0 or v < min or v > max then return end
        return math.tointeger(v)
    end
end

local function boolSetting(v)
    if type(v) == 'boolean' then return v end
end

local function choiceSetting(...)
    local allowed = {}
    for _, value in ipairs({ ... }) do allowed[value] = true end
    return function(v)
        if allowed[v] then return v end
    end
end

local function namesSetting(pattern, max)
    return function(v)
        if type(v) ~= 'table' then return end
        local out, seen = {}, {}
        for _, name in ipairs(v) do
            if type(name) ~= 'string' or not name:match(pattern) then return end
            if not seen[name] then
                out[#out + 1] = name
                seen[name] = true
            end
            if #out > max then return end
        end
        return out
    end
end

local function markerSetting(v)
    if type(v) ~= 'table' or type(v.colour) ~= 'table' or type(v.scale) ~= 'table' then return end
    local kind = intSetting(0, 43)(v.type)
    local colour, scale = {}, {}
    for i = 1, 3 do
        colour[i] = intSetting(0, 255)(v.colour[i])
        scale[i] = tonumber(v.scale[i])
        if not colour[i] or not scale[i] or scale[i] < 0.05 or scale[i] > 5 then return end
    end
    if not kind then return end
    return { type = kind, colour = colour, scale = scale }
end

-- [item, min, max, chance?] as ox_inventory reads vehicleloot and dumpsterloot
local function lootSetting(v)
    if type(v) ~= 'table' or #v > 50 then return end
    local out = {}
    for i, row in ipairs(v) do
        if type(row) ~= 'table' or type(row[1]) ~= 'string' or not row[1]:match('^[%w_%-]+$') then return end
        local min, max = intSetting(1, 100000)(row[2]), intSetting(1, 100000)(row[3])
        if not min or not max or max < min then return end
        local chance = row[4] ~= nil and intSetting(1, 100)(row[4]) or nil
        if row[4] ~= nil and not chance then return end
        out[i] = { row[1], min, max, chance }
    end
    return out
end

local SETTINGS = {
    slots = intSetting(1, 500),
    weight = intSetting(1000, 1000000),
    dropslots = intSetting(1, 500),
    dropweight = intSetting(1000, 1000000),
    target = boolSetting,
    police = namesSetting('^[%w_%-]+$', 30),
    networkdumpsters = boolSetting,
    autoreload = boolSetting,
    screenblur = boolSetting,
    aimedfiring = boolSetting,
    giveplayerlist = boolSetting,
    weaponanims = boolSetting,
    itemnotify = boolSetting,
    weaponnotify = boolSetting,
    imagepath = function(v)
        if type(v) ~= 'string' or #v > 300 or v:find('%s') then return end
        v = v:gsub('/+$', '')
        if v:match('^nui://[%w_%-]+/.+') or v:match('^https://[%w%.%-]+%.%a+') then return v end
    end,
    dropprops = boolSetting,
    dropmodel = function(v)
        if type(v) == 'string' and v:match('^[%w_]+$') and #v <= 64 then return v end
    end,
    weaponmismatch = boolSetting,
    ignoreweapons = namesSetting('^WEAPON_[%w_]+$', 100),
    suppresspickups = boolSetting,
    disableweapons = boolSetting,
    enablestealcommand = boolSetting,
    disablesetupnotification = boolSetting,
    dropmarker = markerSetting,
    shopmarker = markerSetting,
    evidencemarker = markerSetting,
    craftingmarker = markerSetting,
    randomprices = boolSetting,
    randomloot = boolSetting,
    evidencegrade = intSetting(0, 20),
    loglevel = intSetting(0, 2),
    vehicleloot = lootSetting,
    dumpsterloot = lootSetting,
    clearstashes = choiceSetting('1 MONTH', '3 MONTH', '6 MONTH', '1 YEAR'),
    cleartime = intSetting(1, 120),
    bulkstashsave = boolSetting,
    loghookrejection = boolSetting,
}

lib.callback.register('mri_Qbox:inventory:settings', function(source)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end

    local ok, original = pcall(function() return exports.ox_inventory:MriSettingsOriginal() end)
    if not ok or type(original) ~= 'table' then return { success = false, message = 'inventory_outdated' } end

    local current = {}
    for name in pairs(SETTINGS) do current[name] = GetConvar('inventory:' .. name, original[name] or '') end

    local jobs = {}
    for name, job in pairs(exports.qbx_core:GetJobs() or {}) do
        jobs[#jobs + 1] = { value = name, label = ('%s (%s)'):format(job.label or name, name) }
    end
    table.sort(jobs, function(a, b) return a.label < b.label end)

    local weapons = {}
    for id, entry in pairs(baseEntries('weapons')) do
        local name = id:match('^Weapons:(.+)$')
        if name then weapons[#weapons + 1] = { value = name, label = ('%s (%s)'):format(entry.label or name, name) } end
    end
    table.sort(weapons, function(a, b) return a.label < b.label end)

    return { success = true, values = saved.settings or {}, original = original, current = current, jobs = jobs, weapons = weapons }
end)

lib.callback.register('mri_Qbox:inventory:saveSettings', function(source, values)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    if type(values) ~= 'table' then return { success = false, message = 'invalid_data' } end

    local clean = {}
    for name, value in pairs(values) do
        local check = SETTINGS[name]
        local result = check and check(value)
        if result == nil then return { success = false, message = 'invalid_data', key = name } end
        clean[name] = result
    end

    saved.settings = next(clean) and clean or nil
    SaveResourceFile(GetCurrentResourceName(), FILE, json.encode(saved, { indent = true }), -1)
    GlobalState[SETTINGS_KEY] = saved.settings
    return { success = true }
end)

-- Own tab in mri_Qadmin, like Veículos
local function registerPlugin()
    if GetResourceState('mri_Qadmin') ~= 'started' then return end
    local ok, err = pcall(function()
        exports['mri_Qadmin']:RegisterPlugin({
            id = 'inventory',
            label = 'Editor do inventário',
            icon = 'package',
            resource = GetCurrentResourceName(),
            htmlPath = 'html/inventory.html',
            requiredPerms = ADMIN_ACES,
            description = 'Itens, armas, lojas, crafting, baús e o resto do ox_inventory, sem mexer nos arquivos dele',
        })
    end)
    if not ok then
        lib.print.warn(('[mri_Qbox] Falha ao registrar a aba Editor do inventário no mri_Qadmin: %s'):format(tostring(err)))
    end
end

AddEventHandler('mri_Qadmin:server:pluginsReady', registerPlugin)

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'mri_Qadmin' then registerPlugin() end
end)

CreateThread(function()
    Wait(0)
    registerPlugin()
end)
