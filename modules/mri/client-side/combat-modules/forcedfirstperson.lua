local forcefps = false

Citizen.CreateThread(function()
    while true do
        local delay = 1000

        if cfg.forcedfirstperson.invehicle.ativar then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)

            if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
                local _, weapon = GetCurrentPedWeapon(ped)
                local unarmed = GetHashKey("WEAPON_UNARMED")

                if weapon ~= unarmed then
                    if cfg.forcedfirstperson.invehicle.hold then
                        if IsControlJustPressed(0, 25) then
                            SetFollowVehicleCamViewMode(3)
                        elseif IsControlJustReleased(0, 25) then
                            SetFollowVehicleCamViewMode(0)
                        end
                    else
                        SetFollowVehicleCamViewMode(3)
                    end
                    delay = 100
                end
            end
        end

        if cfg.forcedfirstperson.twopov then
            if forcefps then
                SetFollowPedCamViewMode(4)
            else
                SetFollowPedCamViewMode(0)
            end

            if IsControlJustReleased(0, 0) then
                forcefps = not forcefps
            end

            delay = 5
        end

        Citizen.Wait(delay)
    end
end)



-- -- CreateThread(function()
-- --     while cfg.forcedfirstperson.invehicle do
-- --         local ped = PlayerPedId()
-- --         local _, weapon = GetCurrentPedWeapon(ped)
-- --         local unarmed = `WEAPON_UNARMED`
-- --         local inVeh = GetVehiclePedIsIn(PlayerPedId(), false)
-- --         sleep = 1000
-- --         if IsPedInAnyVehicle(PlayerPedId()) and weapon ~= unarmed then
-- --             sleep = 1
-- --             if IsControlJustPressed(0, 25) then
-- --                 SetFollowVehicleCamViewMode(3)
-- --             elseif IsControlJustReleased(0, 25) then
-- --                 -- SetFollowVehicleCamViewMode(0)
-- --             end
-- --         end
-- --         Wait(sleep)
-- --     end
-- -- end)