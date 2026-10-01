-- Primeira pessoa no carro quando o motorista está armado (sempre, ou só
-- segurando a mira).

CreateThread(function()
    while true do
        local delay = 1000
        if Mri.enabled('vehiclefirstperson') then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
                local _, weapon = GetCurrentPedWeapon(ped, true)
                if weapon ~= `WEAPON_UNARMED` then
                    if Mri.cfg('vehiclefirstperson').holdOnly then
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
        Wait(delay)
    end
end)
