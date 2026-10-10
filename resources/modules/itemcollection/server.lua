-- o export fica sempre registrado: o ox_inventory chama mri_Qbox.itemPlace nos itens
local cfg_itemcollection = {}
for _, data in pairs(exports.ox_inventory:Items()) do
    if data.prop and type(data.prop) == "table" then
        for i=1, #data.prop do
            local prop = data.prop[i]
            cfg_itemcollection[prop] = data.name
        end
    elseif data.prop then
        cfg_itemcollection[data.prop] = data.name
    end
end

local function getEntityCoordOffset(entity, offsetX, offsetY, offsetZ)
    local heading = GetEntityHeading(entity)
    local x = offsetX * math.cos(math.rad(heading)) - offsetY * math.sin(math.rad(heading))
    local y = offsetX * math.sin(math.rad(heading)) + offsetY * math.cos(math.rad(heading))
    local z = offsetZ
    local entityCoords = GetEntityCoords(entity)
    return vector3(entityCoords.x + x, entityCoords.y + y, entityCoords.z + z), heading
end

RegisterNetEvent("itemcollection:pickup", function(netid, entityModel)
    if not Mri.enabled('itemcollection') then return end
    local src = source
    local entity = not entityModel and NetworkGetEntityFromNetworkId(netid) or nil
    local model = entityModel or GetEntityModel(entity)

    if not cfg_itemcollection[model] then return end
    if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
    
    exports.ox_inventory:AddItem(src, cfg_itemcollection[model], 1)
end)

exports("itemPlace", function(event, item, inventory, slot, data)
    if event == "usingItem" then
        local ped = GetPlayerPed(inventory.id)
        local veh = GetVehiclePedIsIn(ped)
        if veh ~= 0 then
            TriggerClientEvent("ox_lib:notify", inventory.id, {description = "Este item não pode ser usado em um veículo.", position = "top", type = "error"})
            return false
        end
        return
    end

    if event == "usedItem" then
        local ped = GetPlayerPed(inventory.id)
        local coords, heading = getEntityCoordOffset(ped, 0.0, 0.5, -1.0)
        local entity = CreateObject(type(item.prop) == "table" and item.prop[1] or item.prop, coords.x, coords.y, coords.z, true, true, true)
        local time = os.time()
        while not DoesEntityExist(entity) and os.time()-time < 5 do Wait(0) end
        SetEntityHeading(entity, heading)
        FreezeEntityPosition(entity, true)
        if vehiclesWillAvoid then
            local state = Entity(entity).state
            state.vehiclesAvoidProp = true
        end
    end
end)