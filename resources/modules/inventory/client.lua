-- Bridge between the inventory editor screen and the server; the server checks permission on every call.

RegisterNUICallback('inventoryGet', function(data, cb)
    cb(lib.callback.await('mri_Qbox:inventory:get', false, data.catalog) or { success = false })
end)

RegisterNUICallback('inventoryItemNames', function(_, cb)
    cb(lib.callback.await('mri_Qbox:inventory:itemNames', false) or { success = false })
end)

RegisterNUICallback('inventorySave', function(data, cb)
    cb(lib.callback.await('mri_Qbox:inventory:save', false, data.catalog, data.id, data.value) or { success = false })
end)

RegisterNUICallback('inventoryRemove', function(data, cb)
    cb(lib.callback.await('mri_Qbox:inventory:remove', false, data.catalog, data.id) or { success = false })
end)

RegisterNUICallback('inventoryRestore', function(data, cb)
    cb(lib.callback.await('mri_Qbox:inventory:restore', false, data.catalog, data.id) or { success = false })
end)

RegisterNUICallback('inventoryGive', function(data, cb)
    cb(lib.callback.await('mri_Qbox:inventory:give', false, data.name) or { success = false })
end)

-- where the admin stands, for locations
RegisterNUICallback('inventoryCoords', function(_, cb)
    local coords = GetEntityCoords(cache.ped)
    local round = function(n) return math.floor(n * 100 + 0.5) / 100 end
    local ground = coords.z - GetEntityHeightAboveGround(cache.ped)
    cb({ x = round(coords.x), y = round(coords.y), z = round(coords.z), w = round(GetEntityHeading(cache.ped)), ground = round(ground) })
end)

RegisterNUICallback('inventoryTeleport', function(data, cb)
    if type(data) ~= 'table' then return cb(false) end
    local x, y, z = tonumber(data.x), tonumber(data.y), tonumber(data.z)
    if not (x and y and z) or not lib.callback.await('mri_Qbox:inventory:canTeleport', false) then return cb(false) end
    cb(true)

    local ped = cache.ped
    FreezeEntityPosition(ped, true)
    SetPedCoordsKeepVehicle(ped, x, y, z)
    RequestCollisionAtCoord(x, y, z)
    -- far away the map collision is not loaded yet and the player falls through it
    local timeout = GetGameTimer() + 3000
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do Wait(0) end
    FreezeEntityPosition(ped, false)
end)
