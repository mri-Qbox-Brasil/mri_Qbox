local lastTackle = {}

RegisterNetEvent('tackle:server:TacklePlayer', function(target)
    local src = source
    if not Mri.enabled('tackle') or math.type(target) ~= 'integer' or target == src then return end

    local now = GetGameTimer()
    if lastTackle[src] and now - lastTackle[src] < 1000 then return end

    local ped, targetPed = GetPlayerPed(src), GetPlayerPed(target)
    if ped == 0 or targetPed == 0 then return end
    if GetVehiclePedIsIn(ped, false) ~= 0 or GetVehiclePedIsIn(targetPed, false) ~= 0 then return end
    if #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > 2.0 then return end

    lastTackle[src] = now
    TriggerClientEvent('tackle:client:GetTackled', target)
end)

AddEventHandler('playerDropped', function()
    lastTackle[source] = nil
end)
