-- Same as qbx_vehiclepush: E + Shift, the entity owner moves the car (statebag pushVehicle), keybind and event names included.

---@alias PushDirection 'right'|'left'|'front'|'back'|nil

local DICT, CLIP = 'missfinale_c2ig_11', 'pushcar_offcliff_m'
local pressed = { e = false, shift = false }
---@type PushDirection
local pushingControl

local function allowedClass(vehicle)
    local class = GetVehicleClass(vehicle)
    for _, blocked in ipairs(Mri.cfg('vehiclepush').blacklistedClasses or {}) do
        if class == blocked then return false end
    end
    return true
end

local function isVehicleValid(vehicle)
    local engineHealth = GetVehicleEngineHealth(vehicle)
    local damageNeeded = tonumber(Mri.cfg('vehiclepush').damageNeeded) or 1000.0
    return ((engineHealth >= 0 and engineHealth <= damageNeeded) or (Entity(vehicle).state.fuel or 100) < 3)
        and IsVehicleSeatFree(vehicle, -1) and allowedClass(vehicle)
end

-- runs on the entity owner; hands over to the new owner if it changes mid push
local function vehicleControl(vehicle, value)
    if not pushingControl then
        local oldDirection = value
        CreateThread(function()
            local ped, playerId = cache.ped, cache.playerId
            pushingControl = value
            while DoesEntityExist(vehicle) and pushingControl and NetworkGetEntityOwner(vehicle) == playerId do
                Wait(0)
                if pushingControl == 'left' then
                    TaskVehicleTempAction(ped, vehicle, 11, 1)
                elseif pushingControl == 'right' then
                    TaskVehicleTempAction(ped, vehicle, 10, 1)
                end
                SetVehicleForwardSpeed(vehicle, value == 'front' and -1.0 or 1.0)
                if HasEntityCollidedWithAnything(vehicle) then SetVehicleOnGroundProperly(vehicle) end
            end
            if DoesEntityExist(vehicle) and NetworkGetEntityOwner(vehicle) ~= playerId and pushingControl then
                TriggerServerEvent('qbx_vehiclepush:server:push', { direction = oldDirection, netId = VehToNet(vehicle) })
            end
        end)
    end
    pushingControl = value
end

local function validityThread(vehicle)
    CreateThread(function()
        while pressed.e and pressed.shift do
            Wait(500)
            if not isVehicleValid(vehicle) then
                pressed.e, pressed.shift = false, false
            end
        end
    end)
end

local function taskControlVehicle(vehicle, direction)
    if NetworkGetEntityOwner(vehicle) == cache.playerId then
        vehicleControl(vehicle, direction)
    else
        TriggerServerEvent('qbx_vehiclepush:server:push', { direction = direction, netId = VehToNet(vehicle) })
    end
end

local function pushVehicle()
    if not Mri.enabled('vehiclepush') or cache.vehicle then return end
    local ped = cache.ped
    local vehicle, vehicleCoords = lib.getClosestVehicle(GetEntityCoords(ped), 3.0)
    if not vehicle or IsEntityAttachedToEntity(ped, vehicle) or not isVehicleValid(vehicle) then return end

    validityThread(vehicle)
    if not pressed.e or not pressed.shift then return end

    local pedCoords = GetEntityCoords(ped)
    local bone = GetPedBoneIndex(ped, 6286)
    local min = GetModelDimensions(GetEntityModel(vehicle))
    local forward = GetEntityForwardVector(vehicle)
    local isInFront = #(vehicleCoords - pedCoords + forward) < #(vehicleCoords - pedCoords - forward)

    if isInFront then
        AttachEntityToEntity(ped, vehicle, bone, 0.0, min.y * -1 + 0.1, min.z + 1.0, 0.0, 0.0, 180.0, false, false, false, true, 0, true)
    else
        AttachEntityToEntity(ped, vehicle, bone, 0.0, min.y - 0.3, min.z + 1.0, 0.0, 0.0, 0.0, false, false, false, true, 0, true)
    end
    lib.playAnim(ped, DICT, CLIP, 2.0, -8.0, -1, 35, 0, false, false, false)
    taskControlVehicle(vehicle, isInFront and 'front' or 'back')

    CreateThread(function()
        local wheels = ''
        while pressed.shift and not cache.vehicle do
            local direction
            if IsDisabledControlPressed(0, 34) then
                direction = 'left'
            elseif IsDisabledControlPressed(0, 9) then
                direction = 'right'
            end
            if direction and wheels ~= direction then
                wheels = direction
                taskControlVehicle(vehicle, wheels)
            end
            Wait(0)
        end
        DetachEntity(ped, false, false)
        StopAnimTask(ped, DICT, CLIP, 2.0)
        FreezeEntityPosition(ped, false)
        taskControlVehicle(vehicle)
        pushingControl = nil
    end)

    return vehicle
end

AddStateBagChangeHandler('pushVehicle', nil, function(bagName, _, value)
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 or NetworkGetEntityOwner(entity) ~= cache.playerId then return end
    if not value then
        pushingControl = nil
        return
    end
    vehicleControl(entity, value)
end)

lib.addKeybind({
    name = 'push_vehicle_e',
    description = 'first keybind to push vehicle',
    defaultKey = 'E',
    onPressed = function()
        pressed.e = true
        if pressed.shift then pushVehicle() end
    end,
    onReleased = function()
        pressed.e = false
    end,
})

lib.addKeybind({
    name = 'push_vehicle',
    description = 'second keybind to push vehicle',
    defaultKey = 'LSHIFT',
    onPressed = function(self)
        pressed.shift = true
        if pressed.e then self.vehicle = pushVehicle() end
    end,
    onReleased = function(self)
        pressed.shift = false
        if self.vehicle then taskControlVehicle(self.vehicle) end
    end,
})
