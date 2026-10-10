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

local function publish(catalog)
    SaveResourceFile(GetCurrentResourceName(), FILE, json.encode(saved, { indent = true }), -1)
    local edits = saved[catalog]
    GlobalState[KEY:format(catalog)] = edits and next(edits) and toVectors(edits) or nil
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
    if not CATALOGS[catalog] then return { success = false, message = 'invalid_catalog' } end
    id = cleanId(catalog, id)
    if not id then return { success = false, message = 'invalid_id' } end
    if value == nil then return { success = false, message = 'invalid_data' } end

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
    return { success = true, id = id }
end)

lib.callback.register('mri_Qbox:inventory:remove', function(source, catalog, id)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    if not CATALOGS[catalog] or type(id) ~= 'string' then return { success = false, message = 'invalid_data' } end

    local edits = saved[catalog] or {}
    -- a file entry is marked false; an added one is just deleted (`x and false or nil` is always nil)
    if baseEntries(catalog)[id] ~= nil then
        edits[id] = false
    else
        edits[id] = nil
    end
    saved[catalog] = next(edits) and edits or nil
    publish(catalog)
    return { success = true }
end)

lib.callback.register('mri_Qbox:inventory:restore', function(source, catalog, id)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    if not CATALOGS[catalog] or type(id) ~= 'string' then return { success = false, message = 'invalid_data' } end

    local edits = saved[catalog]
    if edits then
        edits[id] = nil
        saved[catalog] = next(edits) and edits or nil
        publish(catalog)
    end
    return { success = true }
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
