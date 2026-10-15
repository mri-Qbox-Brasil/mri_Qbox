-- Same checks as qbx_vehiclepush; the owner of the car applies the push through the statebag.
local DIRECTIONS = { left = true, right = true, front = true, back = true }

RegisterNetEvent('qbx_vehiclepush:server:push', function(data)
    if not Mri.enabled('vehiclepush') then return end
    if type(data) ~= 'table' or math.type(data.netId) ~= 'integer' then return end
    if data.direction ~= nil and not DIRECTIONS[data.direction] then return end

    local vehicle = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2 then return end

    local ped = GetPlayerPed(source)
    if ped == 0 or #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) > 5.0 then return end
    -- stopping must stay possible when a driver gets in
    if data.direction == nil then
        Entity(vehicle).state:set('pushVehicle', nil, true)
        return
    end
    if GetVehiclePedIsIn(ped, false) ~= 0 or GetPedInVehicleSeat(vehicle, -1) ~= 0 then return end

    Entity(vehicle).state:set('pushVehicle', data.direction, true)
end)
