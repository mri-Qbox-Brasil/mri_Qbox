-- Drift segurando Shift abaixo de uma velocidade (km/h).

CreateThread(function()
    while true do
        Wait(500)
        local cfg = Mri.cfg('drift')
        local ped = PlayerPedId()
        if cfg.enabled and IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(vehicle, -1) == ped and GetEntitySpeed(vehicle) * 3.6 <= (cfg.speed or 80) then
                SetVehicleReduceGrip(vehicle, IsControlPressed(0, 21))
            end
        end
    end
end)
