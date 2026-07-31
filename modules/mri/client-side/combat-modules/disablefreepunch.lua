Citizen.CreateThread(function()
    while cfg.disablefreepunch.toggle do
        local delay = 1000

        -- Apenas bloqueia o soco/disparo se o Target (olhinho) estiver ativo
        if LocalPlayer.state.targetActive then
            -- Verifica se o jogador não está segurando o botão de mirar
            if not IsAimCamActive() then
                DisablePlayerFiring(PlayerId())
                delay = 0
            end
        end
        Citizen.Wait(delay)
    end
end)
