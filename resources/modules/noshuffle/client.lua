-- Same as qbx_noshuff, keybind name included so players keep the key they chose.
local NO_AUTO_SHUFFLE = 184
local SHUFFLE_TASK = 165

lib.onCache('seat', function(seatIndex)
    if not Mri.enabled('noshuffle') then return end
    SetPedConfigFlag(cache.ped, NO_AUTO_SHUFFLE, true)
    if cache.vehicle and not cache.seat then
        SetPedIntoVehicle(cache.ped, cache.vehicle, seatIndex)
    end
end)

lib.addKeybind({
    name = 'shuffleSeat',
    description = 'Troca de assento',
    defaultKey = Mri.cfg('noshuffle').key or 'O',
    onPressed = function(self)
        if not Mri.enabled('noshuffle') then return end
        if QBX.PlayerData.metadata.ishandcuffed then
            return exports.qbx_core:Notify('Você está algemado.', 'error')
        end
        if LocalPlayer.state.seatbelt then
            return exports.qbx_core:Notify('Você colocou o cinto de segurança.', 'error')
        end
        -- the next seat of the front passenger is the driver seat
        if cache.vehicle and cache.seat == 0 and not IsVehicleSeatFree(cache.vehicle, -1) then return end

        self:disable(true)
        if cache.vehicle and cache.seat then
            TaskShuffleToNextVehicleSeat(cache.ped, cache.vehicle)
            repeat Wait(0) until not GetIsTaskActive(cache.ped, SHUFFLE_TASK)
        end
        self:disable(false)
    end,
})

Mri.lifecycle('noshuffle', function()
    SetPedConfigFlag(cache.ped, NO_AUTO_SHUFFLE, true)
end, function()
    SetPedConfigFlag(cache.ped, NO_AUTO_SHUFFLE, false)
end)
