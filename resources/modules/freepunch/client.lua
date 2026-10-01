-- Sem soco/tiro sem estar mirando (evita soco sem querer usando o olhinho)

CreateThread(function()
    while true do
        local delay = 1000
        if Mri.enabled('freepunch') and not IsAimCamActive() then
            DisablePlayerFiring(PlayerId(), true)
            delay = 0
        end
        Wait(delay)
    end
end)
