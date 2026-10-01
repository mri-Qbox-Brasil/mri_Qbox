-- Sem rolamento de combate mirando armado (contribuição: .reiffps)

CreateThread(function()
    while true do
        if not Mri.enabled('combatroll') then
            Wait(1000)
        else
            Wait(5)
            if IsPedArmed(PlayerPedId(), 4 | 2) and IsControlPressed(0, 25) then
                DisableControlAction(0, 22, true)
            end
        end
    end
end)
