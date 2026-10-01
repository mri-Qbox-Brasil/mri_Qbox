-- Só duas câmeras a pé (primeira e terceira pessoa); V alterna.

local firstPerson = false

CreateThread(function()
    while true do
        if not Mri.enabled('twopov') then
            Wait(1000)
        else
            SetFollowPedCamViewMode(firstPerson and 4 or 0)
            if IsControlJustReleased(0, 0) then
                firstPerson = not firstPerson
            end
            Wait(5)
        end
    end
end)
