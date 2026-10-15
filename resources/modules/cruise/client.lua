-- Same as qbx_cruise, keybind name included so players keep the key they chose.

-- vehicle classes with cruise control (no bicycles, boats, helicopters, planes or trains)
local CLASSES = {
    [0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true,
    [9] = true, [10] = true, [11] = true, [12] = true, [13] = false, [14] = false, [15] = false, [16] = false,
    [17] = true, [18] = true, [19] = true, [20] = true, [21] = false,
}

local cruisedSpeed = 0

local function disable()
    cruisedSpeed = 0
    TriggerEvent('seatbelt:client:ToggleCruise')
    exports.qbx_core:Notify('Controle de cruzeiro desativado', 'error')
end

local function trigger()
    if cruisedSpeed ~= 0 or cache.seat ~= -1 then return end
    cruisedSpeed = GetEntitySpeed(cache.vehicle)
    if cruisedSpeed <= 0 or GetVehicleCurrentGear(cache.vehicle) <= 0 then
        cruisedSpeed = 0
        return
    end

    TriggerEvent('seatbelt:client:ToggleCruise')
    exports.qbx_core:Notify('Controle de cruzeiro ativado', 'success')

    CreateThread(function()
        while cruisedSpeed > 0 and cache.vehicle do
            Wait(0)
            local speed = GetEntitySpeed(cache.vehicle)
            local turningOrBraking = IsControlPressed(2, 76) or IsControlPressed(2, 63) or IsControlPressed(2, 64)

            if not turningOrBraking and speed < cruisedSpeed - 1.5 then
                disable()
                Wait(500)
                break
            end

            if not turningOrBraking and IsVehicleOnAllWheels(cache.vehicle) and speed < cruisedSpeed then
                SetVehicleForwardSpeed(cache.vehicle, cruisedSpeed)
            end

            if IsControlJustPressed(1, 246) then
                disable()
                Wait(500)
                break
            end
        end
    end)
end

lib.addKeybind({
    name = 'toggle_cruise_control',
    description = 'Alternar controle de cruzeiro',
    defaultKey = Mri.cfg('cruise').key or 'Y',
    onPressed = function()
        if not Mri.enabled('cruise') or cache.seat ~= -1 then return end
        if CLASSES[GetVehicleClass(cache.vehicle)] then
            trigger()
        else
            exports.qbx_core:Notify('Controle de cruzeiro indisponível', 'error')
        end
    end,
})

Mri.lifecycle('cruise', function() end, function()
    cruisedSpeed = 0
end)
