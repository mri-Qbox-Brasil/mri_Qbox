-- Sem tiro cego pela cobertura (--mur4i)

CreateThread(function()
    while true do
        if not Mri.enabled('blindfire') then
            Wait(1000)
        else
            local ped = PlayerPedId()
            if IsPedArmed(ped, 4) then
                if IsPedInCover(ped, true) and not IsPedAimingFromCover(ped) then
                    DisableControlAction(2, 24, true)
                    DisableControlAction(2, 142, true)
                    DisableControlAction(2, 257, true)
                end
                Wait(5)
            else
                Wait(500)
            end
        end
    end
end)
