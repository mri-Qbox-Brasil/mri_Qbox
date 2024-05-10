Citizen.CreateThread(function()
    while cfg.disablefreepunch.toggle do
        local delay = 1000

        -- Verifica se o jogador está segurando o botão direito do mouse
        if not IsAimCamActive() then -- Botão direito do mouse
            DisablePlayerFiring(PlayerId())
            delay = 0
        end
        Citizen.Wait(delay)
    end
end)
