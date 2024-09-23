-----------------------------------------------------------------------------------------
-- Desabilita Radio nativo do GTA do carro quando entra nele -- por DJOTABR
----------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        local playerPed = PlayerPedId() -- Obtém o ped do jogador no client-side
        local vehicle = GetVehiclePedIsIn(playerPed, false) -- Obtém o veículo em que o jogador está
        if cfg.radio then
            if vehicle ~= 0 then -- Verifica se o jogador está em um veículo
                -- Desativa o rádio, se estiver ligado
                if IsVehicleRadioOn(vehicle) then
                    SetVehRadioStation(vehicle, "OFF") -- Define o rádio como desligado
                    SetVehicleRadioEnabled(vehicle, false) -- Desativa completamente o rádio
                end
            end
        end
        Wait(1000) -- Aguarda 1 segundo antes de verificar novamente
    end
end)
