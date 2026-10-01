-- A roda fica virada no ângulo em que o carro foi desligado (from
-- md_savewheelpos, contribuição: .reiffps).

CreateThread(function()
    local angle = 0.0
    while true do
        if not Mri.enabled('savewheelpos') then
            Wait(1000)
        else
            Wait(0)
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsUsing(ped)
            if DoesEntityExist(veh) then
                local current = GetVehicleSteeringAngle(veh)
                if current > 10.0 or current < -10.0 then
                    angle = current
                end
                local last = GetVehiclePedIsIn(ped, true)
                if GetEntitySpeed(veh) < 0.1 and DoesEntityExist(last) and not GetIsTaskActive(ped, 151) and not GetIsVehicleEngineRunning(last) then
                    SetVehicleSteeringAngle(last, angle)
                end
            else
                Wait(1000)
            end
        end
    end
end)
