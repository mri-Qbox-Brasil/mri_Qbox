-- exports.ox_target:addModel(cfg.dumpsters.TrashCans.Model, {
--     icon = 'fas fa-dumpster',
--     label = "Vasculhar",
--     onSelect = function(data)
--         local entity = data.entity
--         local netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity)
--         if not netId then
--             local coords = GetEntityCoords(entity)
--             entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 0.1, GetEntityModel(entity), true, true, true)
--             netId = entity ~= 0 and NetworkGetNetworkIdFromEntity(entity)
--         end
--         if netId then
            
--             exports.ox_inventory:openInventory('dumpster', 'dumpster'..netId)
--         end
--     end,
--     distance = 1,
-- })

-- exports.ox_target:addGlobalVehicle({
--     icon = 'fa-solid fa-car-rear',
--     label = "Abrir/vasculhar porta-malas",
--     offset = vec3(0.5, 0, 0.5),
--     onSelect = function(data)
--         local entity = data.entity
--         local netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity)
--         if not netId then
--             local coords = GetEntityCoords(entity)
--             entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 0.1, GetEntityModel(entity), true, true, true)
--             netId = entity ~= 0 and NetworkGetNetworkIdFromEntity(entity)
--         end
--         if netId then
--             if GetVehicleDoorLockStatus(entity) > 1 then
--                 return lib.notify({ id = 'vehicle_locked', type = 'error', description = "Veículo trancado" })
--             end

--             local coords = GetEntityCoords(entity)
--             TaskTurnPedToFaceCoord(GetPlayerPed(-1), coords.x, coords.y, coords.z, 0)

--             local plate = GetVehicleNumberPlateText(entity)
--             local invId = 'trunk'..plate

--             TriggerEvent("ox_target:toggleEntityDoor", netId , 5)
--             exports.ox_inventory:openInventory('trunk', { id = invId, netid = NetworkGetNetworkIdFromEntity(entity), entityid = entity, door = true })
--         end
--     end,
--     distance = 2,
-- })


-- -- function Inventory.OpenTrunk(entity)
-- --     ---@type number | number[] | nil
-- --     local door = Inventory.CanAccessTrunk(entity)

-- --     if not door then return end

-- --     if GetVehicleDoorLockStatus(entity) > 1 then
-- --         return lib.notify({ id = 'vehicle_locked', type = 'error', description = locale('vehicle_locked') })
-- --     end

-- --     local plate = GetVehicleNumberPlateText(entity)
-- --     local invId = 'trunk'..plate
-- --     local coords = GetEntityCoords(entity)

-- --     TaskTurnPedToFaceCoord(cache.ped, coords.x, coords.y, coords.z, 0)

-- --     if not client.openInventory('trunk', { id = invId, netid = NetworkGetNetworkIdFromEntity(entity), entityid = entity, door = door }) then return end

-- --     if type(door) == 'table' then
-- --         for i = 1, #door do
-- --             SetVehicleDoorOpen(entity, door[i], false, false)
-- --         end
-- --     else
-- --         SetVehicleDoorOpen(entity, door --[[@as number]], false, false)
-- --     end
-- -- end