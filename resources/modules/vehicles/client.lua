-- Bridge between the vehicles screen (Qadmin tab or /mriqbox) and the server; the server checks permission on every call.

RegisterNUICallback('vehiclesGet', function(_, cb)
    local result = lib.callback.await('mri_Qbox:vehicles:get', false)
    if result and result.vehicles then
        -- no model file in the game: the car pack is not running or the name is wrong
        for i = 1, #result.vehicles do
            local vehicle = result.vehicles[i]
            vehicle.inGame = IsModelInCdimage(joaat(vehicle.model))
        end
    end
    cb(result or { success = false })
end)

RegisterNUICallback('vehiclesSave', function(data, cb)
    cb(lib.callback.await('mri_Qbox:vehicles:save', false, data) or { success = false })
end)

RegisterNUICallback('vehiclesRemove', function(data, cb)
    cb(lib.callback.await('mri_Qbox:vehicles:remove', false, data.model) or { success = false })
end)

RegisterNUICallback('vehiclesRestore', function(data, cb)
    cb(lib.callback.await('mri_Qbox:vehicles:restore', false, data.model) or { success = false })
end)

RegisterNUICallback('vehiclesCheckModel', function(data, cb)
    cb({ inGame = type(data.model) == 'string' and IsModelInCdimage(joaat(data.model)) or false })
end)

---@param key string
---@return string?
local function label(key)
    if not key or key == '' or key == 'CARNOTFOUND' then return nil end
    local text = GetLabelText(key)
    if text == 'NULL' then return key:sub(1, 1) .. key:sub(2):lower() end
    return text
end

---@param hash integer
---@return string
local function typeOf(hash)
    if IsThisModelABike(hash) or IsThisModelABicycle(hash) or IsThisModelAQuadbike(hash) then return 'bike' end
    if IsThisModelABoat(hash) or IsThisModelAJetski(hash) then return 'boat' end
    if IsThisModelAHeli(hash) then return 'heli' end
    if IsThisModelAPlane(hash) then return 'plane' end
    if IsThisModelATrain(hash) then return 'train' end
    return 'automobile'
end

-- Game models (base game and streamed packs) missing from the qbx_core list, with the game's own name and brand
RegisterNUICallback('vehiclesMissing', function(_, cb)
    local known = exports.qbx_core:GetVehiclesByName()
    local missing = {}
    for _, model in ipairs(GetAllVehicleModels()) do
        model = model:lower()
        if not known[model] then
            local hash = joaat(model)
            missing[#missing + 1] = {
                model = model,
                name = label(GetDisplayNameFromVehicleModel(hash)) or model,
                brand = label(GetMakeNameFromVehicleModel(hash)) or '',
                type = typeOf(hash),
            }
        end
    end
    cb({ success = true, models = missing })
end)

-- A vehicle or the stock changed: the NUI page relays it to the open screen (iframes do not get SendNUIMessage)
RegisterNetEvent('mri_Qbox:vehicles:changed', function()
    SendNUIMessage({ action = 'vehiclesChanged' })
end)
