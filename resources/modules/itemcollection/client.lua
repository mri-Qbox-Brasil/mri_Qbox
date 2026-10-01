-- Pegar do chão, pelo olhinho, o prop de um item do ox_inventory (e o export
-- itemPlace, que coloca o prop no chão ao usar o item).
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

Mri.lifecycle('itemcollection', function()
exports.ox_target:addGlobalObject({{
    name = "itemcollection:pickup",
    icon = "fa-solid fa-hand",
    label = "Pegar",
    distance = 1.5,
    canInteract = function(entity, distance, coords, name, bone)
        if entity and GetEntityType(entity) > 0 then
            local model = GetEntityModel(entity)
            return cfg_itemcollection[model]
        end
        return false
    end,
    onSelect = function(data)
        local mission = IsEntityAMissionEntity(data.entity)
        local netid = mission and NetworkGetNetworkIdFromEntity(data.entity) or false
        
        lib.requestAnimDict("anim@mp_snowball")
        TaskPlayAnim(cache.ped, "anim@mp_snowball", "pickup_snowball", 2.0, 2.0, -1, 50, 0, 0, 0, 0)
        Wait(900)
        StopAnimTask(cache.ped, "anim@mp_snowball", "pickup_snowball", 2.0)

        TriggerServerEvent("itemcollection:pickup", netid, not mission and GetEntityModel(data.entity))
        if not mission then
            SetEntityAsMissionEntity(data.entity)
            DeleteEntity(data.entity)
        end
    end
}})
end, function()
    exports.ox_target:removeGlobalObject('itemcollection:pickup')
end)

AddStateBagChangeHandler("vehiclesAvoidProp", nil, function(bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)
    if not DoesEntityExist(entity) or NetworkGetEntityOwner(entity) ~= cache.playerId then return end
    SetObjectForceVehiclesToAvoid(entity, value)
end)