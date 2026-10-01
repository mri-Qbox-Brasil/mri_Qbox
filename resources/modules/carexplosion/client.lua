-- Carro explode ao cair de uma altura (motos, helicópteros e aviões fora).

local controlGround = false

CreateThread(function()
    while true do
        local sleep = 2000
        local cfg = Mri.cfg('carexplosion')
        local ped = PlayerPedId()
        if cfg.enabled and IsPedInAnyVehicle(ped, false) then
            local coords = GetEntityCoords(ped)
            local veh = GetVehiclePedIsIn(ped, false)
            local seat = GetPedInVehicleSeat(veh, -1)
            local class = GetVehicleClass(veh)
            local excluded = class == 15 or class == 16 or class == 8
            if not excluded and seat then
                sleep = 1000
                local vehHeight = GetEntityHeightAboveGround(veh)
                if vehHeight >= 1 then
                    if not controlGround then
                        if vehHeight >= (cfg.height or 40) and IsEntityInAir(veh) then
                            local found, groundz = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
                            if not found or GetEntityCoords(veh).z > groundz then
                                controlGround = true
                            end
                        end
                    else
                        sleep = 1
                        if GetEntityHeightAboveGround(veh) < 2 then
                            controlGround = false
                            SetVehicleEngineHealth(veh, 0)
                            SetVehiclePetrolTankHealth(veh, 0)
                            DetachVehicleWindscreen(veh)
                            SmashVehicleWindow(veh, 0)
                            AddExplosion(GetEntityCoords(veh), 7, 50.0, true, false, 5.0)
                            sleep = 500
                        end
                    end
                end
            end
        else
            controlGround = false
        end
        Wait(sleep)
    end
end)
