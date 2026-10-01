-- Sem controle do carro no ar (otimização em cima do RealisticAirControl by
-- .mur4i, contribuição: .reiffps). Motos, bicicletas, barcos e aeronaves fora.

local DISABLE_CLASS = {
    [0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true,
    [7] = true, [9] = true, [10] = true, [11] = true, [12] = true, [17] = true, [18] = true,
}

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if not Mri.enabled('aircontrol') or not IsPedInAnyVehicle(ped, false) then
            Wait(1000)
        else
            local vehicle = GetVehiclePedIsIn(ped, false)
            if DISABLE_CLASS[GetVehicleClass(vehicle)] and GetPedInVehicleSeat(vehicle, -1) == ped and IsEntityInAir(vehicle) then
                DisableControlAction(2, 59, true) -- inclinar
                DisableControlAction(2, 60, true)
            end
            Wait(0)
        end
    end
end)
