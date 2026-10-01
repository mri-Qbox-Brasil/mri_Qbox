-- Esconde componentes da HUD nativa: nome do veículo, área, classe do veículo e
-- nome da rua (6 a 9) e, opcional, a mira (14). Antes vivia dentro do recuo.

CreateThread(function()
    while true do
        local cfg = Mri.cfg('hudcomponents')
        if not cfg.enabled then
            Wait(1000)
        else
            Wait(0)
            HideHudComponentThisFrame(6)
            HideHudComponentThisFrame(7)
            HideHudComponentThisFrame(8)
            HideHudComponentThisFrame(9)
            if cfg.hideCrosshair then
                HideHudComponentThisFrame(14)
            end
        end
    end
end)
