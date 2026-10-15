-- Same as qbx_tackle, keybind and event names included.
local DICT, CLIP = 'swimming@first_person@diving', 'dive_run_fwd_-45_loop'

lib.addKeybind({
    name = 'tackle',
    description = 'Tackle',
    defaultKey = Mri.cfg('tackle').key or 'E',
    onReleased = function(self)
        if not Mri.enabled('tackle') or cache.vehicle or QBX.PlayerData.metadata.ishandcuffed then return end
        if not IsPedSprinting(cache.ped) and not IsPedRunning(cache.ped) then return end
        local target, targetPed = lib.getClosestPlayer(GetEntityCoords(cache.ped), 1.6, false)
        if not targetPed or IsPedInAnyVehicle(targetPed, true) then return end

        self:disable(true)
        TriggerServerEvent('tackle:server:TacklePlayer', GetPlayerServerId(target))
        lib.requestAnimDict(DICT)
        TaskPlayAnim(cache.ped, DICT, CLIP, 3.0, 3.0, -1, 49, 0, false, false, false)
        Wait(250)
        ClearPedTasks(cache.ped)
        SetPedToRagdoll(cache.ped, 150, 150, 0, false, false, false)
        RemoveAnimDict(DICT)
        SetTimeout(1000, function() self:disable(false) end)
    end,
})

RegisterNetEvent('tackle:client:GetTackled', function()
    local ms = math.floor((tonumber(Mri.cfg('tackle').seconds) or 7) * 1000)
    SetPedToRagdoll(cache.ped, ms, ms, 0, false, false, false)
end)
