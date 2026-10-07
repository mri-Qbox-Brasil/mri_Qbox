-- Runtime vehicle registry and dealership stock (ex mri_Qvehicles). qbx_core owns the list
-- (API in qbx_core/mri/server/vehicles.lua); the vehicles_data table keeps the changes:
--   name/brand/price/category/type: NULL = value from shared/vehicles.lua, set = edited
--   removed: game vehicle removed from the panel
--   stock: dealership stock (mri_Qvehicles exports, answered here through provide)
-- Changes are applied again on qbx_core start and on this resource start.

-- The old resource writes the same table and answers the same exports: only one of them may run.
local function oldResourceRunning()
    for i = 0, GetNumResources() - 1 do
        if GetResourceByFindIndex(i) == 'mri_Qvehicles' then
            local state = GetResourceState('mri_Qvehicles')
            return state == 'started' or state == 'starting'
        end
    end
    return false
end

if oldResourceRunning() then
    lib.print.error('[mri_Qbox] o mri_Qvehicles está rodando: os veículos agora fazem parte do mri_Qbox. Tire o mri_Qvehicles do servidor e reinicie; até lá o cadastro e o estoque ficam com ele.')
    return
end

local ADMIN_ACES = { 'mri_Qvehicles.admin', 'mri_Qbox.admin', 'command' }

local FIELDS = { 'name', 'brand', 'price', 'category', 'type' }

---Original shared/vehicles.lua list: tells what was edited and what to restore.
---@type table<string, Vehicle>
local baseVehicles = require '@qbx_core.shared.vehicles'

---@class VehicleRow
---@field fields table edited fields (only the ones that differ from shared/vehicles.lua)
---@field removed boolean
---@field stock integer

---@type table<string, VehicleRow>
local rows = {}

local loaded = false

---Admins with the screen open: told when a vehicle or the stock changes.
---@type table<integer, true>
local watchers = {}

AddEventHandler('playerDropped', function()
    watchers[source] = nil
end)

-- At most one notice every 2s, so a wave of purchases does not reload the screen nonstop.
local lastNotify, notifyPending = 0, false

local function notifyWatchers()
    if notifyPending or not next(watchers) then return end
    notifyPending = true
    SetTimeout(math.max(0, 2000 - (GetGameTimer() - lastNotify)), function()
        notifyPending = false
        lastNotify = GetGameTimer()
        for src in pairs(watchers) do
            TriggerClientEvent('mri_Qbox:vehicles:changed', src)
        end
    end)
end

---@param source integer
---@return boolean
local function isAdmin(source)
    if source == 0 then return true end
    for i = 1, #ADMIN_ACES do
        if IsPlayerAceAllowed(source, ADMIN_ACES[i]) then return true end
    end
    return false
end

---@param model string
---@return VehicleRow
local function getRow(model)
    local row = rows[model]
    if not row then
        row = { fields = {}, removed = false, stock = 0 }
        rows[model] = row
    end
    return row
end

---@param vehicle table
---@return table
local function pickFields(vehicle)
    local data = {}
    for i = 1, #FIELDS do
        data[FIELDS[i]] = vehicle[FIELDS[i]]
    end
    return data
end

---Writes the whole row. A nil field becomes NULL (oxmysql does not take nil among the parameters).
---@param model string
local function saveRow(model)
    local row = rows[model]
    local columns = { 'model', 'stock', 'removed' }
    local values = { '?', '?', '?' }
    local params = { model, row.stock, row.removed and 1 or 0 }

    for i = 1, #FIELDS do
        local field = FIELDS[i]
        columns[#columns + 1] = ('`%s`'):format(field)
        if row.fields[field] == nil then
            values[#values + 1] = 'NULL'
        else
            values[#values + 1] = '?'
            params[#params + 1] = row.fields[field]
        end
    end

    local updates = {}
    for i = 2, #columns do
        updates[#updates + 1] = ('%s = VALUES(%s)'):format(columns[i], columns[i])
    end

    MySQL.query.await(('INSERT INTO vehicles_data (%s) VALUES (%s) ON DUPLICATE KEY UPDATE %s'):format(
        table.concat(columns, ', '), table.concat(values, ', '), table.concat(updates, ', ')
    ), params)
    notifyWatchers()
end

---@param model string
local function deleteRow(model)
    rows[model] = nil
    MySQL.query.await('DELETE FROM vehicles_data WHERE model = ?', { model })
    notifyWatchers()
end

---@param model string
local function applyRow(model)
    local row = rows[model]
    if row.removed then
        exports.qbx_core:RemoveVehicleData(model)
        return
    end
    if not next(row.fields) then return end

    local ok, err = exports.qbx_core:UpsertVehicleData(model, row.fields)
    if not ok then
        lib.print.warn(('[mri_Qbox] veículos: %s não foi aplicado: %s'):format(model, err))
    end
end

local function applyAll()
    local ok, err = pcall(function()
        for model in pairs(rows) do
            applyRow(model)
        end
    end)
    if not ok then
        lib.print.error(('[mri_Qbox] veículos: qbx_core sem a API de veículos (UpsertVehicleData): %s'):format(err))
    end
end

---@param column string
---@return table?
local function getColumn(column)
    return MySQL.single.await([[
        SELECT IS_NULLABLE FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vehicles_data' AND COLUMN_NAME = ?
    ]], { column })
end

-- Bump when a new adjustment is added below; the KVP skips the column checks once applied.
local SCHEMA_VERSION = 1
local SCHEMA_KVP = 'vehicles:schemaVersion'

---Creates the table or adjusts the one the old qbx_vehicleshop created (a full copy of each car).
local function prepareSchema()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `vehicles_data` (
            `model` VARCHAR(50) NOT NULL,
            `stock` INT NOT NULL DEFAULT 0,
            `price` INT DEFAULT NULL,
            `name` VARCHAR(100) DEFAULT NULL,
            `brand` VARCHAR(50) DEFAULT NULL,
            `category` VARCHAR(50) DEFAULT NULL,
            `hash` BIGINT DEFAULT NULL,
            `type` VARCHAR(20) DEFAULT NULL,
            `removed` TINYINT(1) NOT NULL DEFAULT 0,
            PRIMARY KEY (`model`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])

    if GetResourceKvpInt(SCHEMA_KVP) >= SCHEMA_VERSION then return end

    if not getColumn('type') then
        MySQL.query.await('ALTER TABLE `vehicles_data` ADD COLUMN `type` VARCHAR(20) DEFAULT NULL')
    end
    if not getColumn('removed') then
        MySQL.query.await('ALTER TABLE `vehicles_data` ADD COLUMN `removed` TINYINT(1) NOT NULL DEFAULT 0')
    end

    -- the old qbx_vehicleshop created price NOT NULL; NULL now means "original value"
    local price = getColumn('price')
    if price and price.IS_NULLABLE == 'NO' then
        MySQL.query.await('ALTER TABLE `vehicles_data` MODIFY `price` INT DEFAULT NULL')
    end

    SetResourceKvpInt(SCHEMA_KVP, SCHEMA_VERSION)
end

---Loads the table. A field equal to shared/vehicles.lua becomes NULL (the old
---qbx_vehicleshop wrote a full copy of each car).
local function loadRows()
    local normalized, orphans = 0, 0

    for _, data in ipairs(MySQL.query.await('SELECT * FROM vehicles_data') or {}) do
        local model = data.model
        local base = baseVehicles[model]
        local row = {
            fields = {},
            removed = data.removed == 1 or data.removed == true,
            stock = tonumber(data.stock) or 0,
        }

        local changed = false
        for i = 1, #FIELDS do
            local field = FIELDS[i]
            local value = data[field]
            if value ~= nil then
                if base and base[field] == value then
                    changed = true
                else
                    row.fields[field] = value
                end
            end
        end

        rows[model] = row

        if changed then
            normalized += 1
            saveRow(model)
        end

        -- not in shared/vehicles.lua and no type: leftover from an old full copy
        if not base and next(row.fields) and not row.fields.type then
            orphans += 1
            row.fields = {}
            saveRow(model)
        end
    end

    return normalized, orphans
end

CreateThread(function()
    prepareSchema()
    local normalized, orphans = loadRows()
    applyAll()
    loaded = true

    local changed = 0
    for _, row in pairs(rows) do
        if row.removed or next(row.fields) then changed += 1 end
    end

    lib.print.info(('[mri_Qbox] veículos: %s alterados aplicados no qbx_core'):format(changed))
    if normalized > 0 then
        lib.print.info(('[mri_Qbox] veículos: %s linhas da vehicles_data ajustadas para o formato novo'):format(normalized))
    end
    if orphans > 0 then
        lib.print.warn(('[mri_Qbox] veículos: %s linhas sem tipo e fora do shared/vehicles.lua foram ignoradas'):format(orphans))
    end
end)

-- qbx_core restarted: the list is back to shared/vehicles.lua, apply the changes again
AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'qbx_core' and loaded then
        applyAll()
    end
end)

-- Stock ----------------------------------------------------------------------

---@param model string
---@return integer
local function getStock(model)
    local row = rows[model]
    return row and row.stock or 0
end

---Stock of every model with a row in the table (no row = 0).
---@return table<string, integer>
local function getStocks()
    local stocks = {}
    for model, row in pairs(rows) do
        stocks[model] = row.stock
    end
    return stocks
end

---Takes one unit. Atomic in the database: two purchases at once do not sell the last car twice.
---@param model string
---@return boolean
local function takeStock(model)
    local affected = MySQL.update.await('UPDATE vehicles_data SET stock = stock - 1 WHERE model = ? AND stock > 0', { model })
    if affected > 0 then
        local row = rows[model]
        if row then row.stock -= 1 end
        notifyWatchers()
        return true
    end
    return false
end

---@param model string
local function returnStock(model)
    getRow(model).stock += 1
    saveRow(model)
end

---@param model string
---@param stock integer
local function setStock(model, stock)
    getRow(model).stock = math.max(0, math.floor(stock))
    saveRow(model)
end

-- old name -> new name; the old contract stays while qbx_vehicleshop and third parties call exports.mri_Qvehicles
local stockExports = {
    GetStock = { 'GetVehicleStock', getStock },
    GetStocks = { 'GetVehicleStocks', getStocks },
    TakeStock = { 'TakeVehicleStock', takeStock },
    ReturnStock = { 'ReturnVehicleStock', returnStock },
    SetStock = { 'SetVehicleStock', setStock },
}

for oldName, export in pairs(stockExports) do
    local name, fn = export[1], export[2]
    exports(name, fn)
    AddEventHandler(('__cfx_export_mri_Qvehicles_%s'):format(oldName), function(setCB)
        setCB(fn)
    end)
end

-- Screen ---------------------------------------------------------------------

---@param value any
---@return string?
local function cleanString(value)
    if type(value) ~= 'string' then return nil end
    value = value:match('^%s*(.-)%s*$')
    return value ~= '' and value or nil
end

lib.callback.register('mri_Qbox:vehicles:get', function(source)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    while not loaded do Wait(100) end

    local list = {}
    for model, vehicle in pairs(exports.qbx_core:GetVehiclesByName()) do
        local row = rows[model]
        local vehicleData = pickFields(vehicle)
        vehicleData.model = model
        vehicleData.stock = getStock(model)
        vehicleData.status = not baseVehicles[model] and 'added'
            or (row and next(row.fields) and 'edited')
            or 'base'
        list[#list + 1] = vehicleData
    end

    for model, row in pairs(rows) do
        if row.removed and baseVehicles[model] then
            local vehicleData = pickFields(baseVehicles[model])
            vehicleData.model = model
            vehicleData.stock = row.stock
            vehicleData.status = 'removed'
            list[#list + 1] = vehicleData
        end
    end

    watchers[source] = true
    return { success = true, vehicles = list }
end)

lib.callback.register('mri_Qbox:vehicles:save', function(source, payload)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    if type(payload) ~= 'table' then return { success = false, message = 'invalid_data' } end

    local model = cleanString(payload.model)
    if not model then return { success = false, message = 'invalid_model' } end
    model = model:lower()

    if rows[model] and rows[model].removed then
        return { success = false, message = 'vehicle_removed' }
    end

    local price = tonumber(payload.price)
    local data = {
        name = cleanString(payload.name),
        brand = cleanString(payload.brand) or '',
        price = price and math.max(0, math.floor(price)) or nil,
        category = cleanString(payload.category) or '',
        type = cleanString(payload.type),
    }

    local base = baseVehicles[model]

    -- a game car gets the full values (a field back to the original must go back in the core too)
    local ok, err = exports.qbx_core:UpsertVehicleData(model, data)
    if not ok then return { success = false, message = err } end

    local row = getRow(model)
    row.fields = {}
    for i = 1, #FIELDS do
        local field = FIELDS[i]
        if data[field] ~= nil and not (base and base[field] == data[field]) then
            row.fields[field] = data[field]
        end
    end

    local stock = tonumber(payload.stock)
    if stock then row.stock = math.max(0, math.floor(stock)) end

    saveRow(model)
    return { success = true }
end)

lib.callback.register('mri_Qbox:vehicles:remove', function(source, model)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    if type(model) ~= 'string' then return { success = false, message = 'invalid_model' } end

    local ok, err = exports.qbx_core:RemoveVehicleData(model)
    if not ok then return { success = false, message = err } end

    if baseVehicles[model] then
        local row = getRow(model)
        row.removed = true
        saveRow(model)
    else
        deleteRow(model)
    end

    return { success = true }
end)

lib.callback.register('mri_Qbox:vehicles:restore', function(source, model)
    if not isAdmin(source) then return { success = false, message = 'no_permission' } end
    local base = type(model) == 'string' and baseVehicles[model]
    if not base then return { success = false, message = 'not_base_vehicle' } end

    local ok, err = exports.qbx_core:UpsertVehicleData(model, pickFields(base))
    if not ok then return { success = false, message = err } end

    local row = getRow(model)
    row.fields = {}
    row.removed = false
    saveRow(model)

    return { success = true }
end)

-- Own tab in mri_Qadmin, same id and permission the mri_Qvehicles used
local function registerPlugin()
    if GetResourceState('mri_Qadmin') ~= 'started' then return end
    local ok, err = pcall(function()
        exports['mri_Qadmin']:RegisterPlugin({
            id = 'vehicles',
            label = 'Veículos',
            icon = 'car',
            resource = GetCurrentResourceName(),
            htmlPath = 'html/vehicles.html',
            requiredPerms = ADMIN_ACES,
            description = 'Cadastro, edição e estoque de veículos sem reiniciar',
        })
    end)
    if not ok then
        lib.print.warn(('[mri_Qbox] Falha ao registrar a aba Veículos no mri_Qadmin: %s'):format(tostring(err)))
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
