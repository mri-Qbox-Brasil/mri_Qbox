-- Pegar as prostitutas da rua com o carro, como o pb_prostitute do modo história.
local ANIM_DICT <const> = 'mini@prostitutes@sexnorm_veh'
local SPEECH_PARAM <const> = 'SPEECH_PARAMS_FORCE_SHOUTED_CLEAR'
local STOPPED_SPEED <const> = 0.1
local PASSENGER_SEAT <const> = 0
local HORN_CONTROL <const> = 86
local EMERGENCY_CLASS <const> = 18
local ANIMAL_PED_TYPE <const> = 28

-- bikes, boats, aircraft, military, trains and open wheel have no usable front passenger seat
local BLOCKED_CLASSES <const> = { [8] = true, [13] = true, [14] = true, [15] = true, [16] = true, [19] = true, [21] = true, [22] = true }
local VEHICLE_CONTROLS <const> = { 59, 60, 61, 62, 63, 64, 71, 72, 73, 86 }

local SERVICES <const> = {
    { id = 'oral', locale = 'hookers.service_oral', price = 'priceOral' },
    { id = 'sex', locale = 'hookers.service_sex', price = 'priceSex' },
}

local SCENES <const> = {
    oral = { anim = 'BJ', speech = 'SEX_ORAL', loops = 4 },
    sex = { anim = 'sex', speech = 'SEX_GENERIC', loops = 8, bounce = true },
}

local function Config() return Mri.cfg('hookers') end

local searching = false
local current -- { hooker, vehicle } while a hooker is with the player
local testPed -- local ped from the panel test button
local controlsLocked = false
local menuPromise

local shownHint

-- Key shown on the NUI hint: the player's real horn binding ("t_E" -> "E").
local function hornKey()
    local button = GetControlInstructionalButton(0, HORN_CONTROL, true) or ''
    return button:match('^t_(.+)$') or 'E'
end

-- Key hint on the mri_Qbox NUI, sent only when it changes (nil hides it).
local function hint(key)
    if shownHint == key then return end
    shownHint = key
    if not key then return SendNUIMessage({ action = 'hookersHint', data = false }) end
    SendNUIMessage({
        action = 'hookersHint',
        data = { label = locale('hookers.' .. key), key = key == 'invite' and hornKey() or nil },
    })
end

local function speak(hooker, speech)
    if not IsAnySpeechPlaying(hooker) then
        PlayPedAmbientSpeechNative(hooker, speech, SPEECH_PARAM)
    end
end

local function waitSpeech(hooker)
    while DoesEntityExist(hooker) and IsAnySpeechPlaying(hooker) do Wait(100) end
end

local function modelSet(names)
    local set = {}
    for _, name in ipairs(names or {}) do set[joaat(name)] = true end
    return set
end

local function isHooker(ped, models)
    return models[GetEntityModel(ped)]
        and not IsPedAPlayer(ped)
        and not IsPedInjured(ped)
        and not IsPedInAnyVehicle(ped, true)
        and not (IsPedWalking(ped) or IsPedRunning(ped) or IsPedSprinting(ped))
end

local function vehicleAllowed(vehicle, cfg)
    if not IsVehicleDriveable(vehicle, false) then return false end
    local class = GetVehicleClass(vehicle)
    if BLOCKED_CLASSES[class] then return false end
    if class == EMERGENCY_CLASS and not cfg.allowEmergency then return false end
    return not modelSet(cfg.blockedVehicles)[GetEntityModel(vehicle)]
end

local function findHooker(vehicle, cfg)
    local models = modelSet(cfg.models)
    local origin = GetEntityCoords(vehicle)
    local nearest, nearestDist
    for _, ped in ipairs(GetGamePool('CPed')) do
        if isHooker(ped, models) then
            local dist = #(GetEntityCoords(ped) - origin)
            if dist <= cfg.maxDistance and (not nearestDist or dist < nearestDist) then
                nearest, nearestDist = ped, dist
            end
        end
    end
    return nearest
end

local function inRange(hooker, vehicle)
    return cache.vehicle == vehicle
        and DoesEntityExist(hooker)
        and GetEntitySpeed(vehicle) <= STOPPED_SPEED
        and #(GetEntityCoords(hooker) - GetEntityCoords(vehicle)) <= Config().maxDistance
end

local function isSecluded(hooker, vehicle)
    local radius = Config().secludedRadius
    local origin = GetEntityCoords(vehicle)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if ped ~= cache.ped and ped ~= hooker
            and GetPedType(ped) ~= ANIMAL_PED_TYPE
            and GetVehiclePedIsIn(ped, false) ~= vehicle
            and #(GetEntityCoords(ped) - origin) < radius
            and HasEntityClearLosToEntity(ped, vehicle, 17) then
            return false
        end
    end
    return true
end

local function lockControls(state)
    if controlsLocked == state then return end
    controlsLocked = state
    if not state then return end
    CreateThread(function()
        while controlsLocked do
            for _, control in ipairs(VEHICLE_CONTROLS) do DisableControlAction(0, control, true) end
            Wait(0)
        end
    end)
end

local function setCalm(hooker, state)
    if state then
        local _, group = AddRelationshipGroup('MRI_HOOKER')
        SetRelationshipBetweenGroups(1, group, `PLAYER`)
        SetPedRelationshipGroupHash(hooker, group)
    end
    SetPedConfigFlag(hooker, 26, state)  -- DontDragMeOutCar
    SetPedConfigFlag(hooker, 115, state) -- FallOutOfVehicleWhenKilled
    SetPedConfigFlag(hooker, 229, state) -- DisablePanicInVehicle
    SetBlockingOfNonTemporaryEvents(hooker, state)
end

local function playPair(hooker, hookerAnim, playerAnim, flag, wait)
    local duration = GetAnimDuration(ANIM_DICT, hookerAnim) * 1000
    TaskPlayAnim(hooker, ANIM_DICT, hookerAnim, 2.0, 2.0, duration, flag, 0.0, false, false, false)
    TaskPlayAnim(cache.ped, ANIM_DICT, playerAnim, 2.0, 2.0, duration, flag, 0.0, false, false, false)
    if wait then Wait(duration) end
end

local function playScene(id, hooker, vehicle)
    local scene = SCENES[id]
    local female = GetEntityModel(cache.ped) == `mp_f_freemode_01`
    local speech = female and scene.speech .. '_FEM' or scene.speech
    local anim = scene.anim

    playPair(hooker, ('proposition_to_%s_p1_prostitute'):format(anim), ('proposition_to_%s_p1_male'):format(anim), 2, true)
    playPair(hooker, ('proposition_to_%s_p2_prostitute'):format(anim), ('proposition_to_%s_p2_male'):format(anim), 2, true)

    local loopAnim = ('%s_loop_prostitute'):format(anim)
    local loopWait = GetAnimDuration(ANIM_DICT, loopAnim) * 1000 / 2
    playPair(hooker, loopAnim, ('%s_loop_male'):format(anim), 1, false)

    local playing = true
    if scene.bounce then
        CreateThread(function()
            Wait(250)
            while playing do
                ApplyForceToEntity(vehicle, 1, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, 0, true, true, true, true, false)
                Wait(780)
            end
        end)
    end

    for _ = 1, scene.loops do
        if not DoesEntityExist(hooker) then break end
        speak(hooker, speech)
        Wait(loopWait)
    end
    playing = false
    if not DoesEntityExist(hooker) then return end

    playPair(hooker, ('%s_to_proposition_p1_prostitute'):format(anim), ('%s_to_proposition_p1_male'):format(anim), 2, true)
    playPair(hooker, ('%s_to_proposition_p2_prostitute'):format(anim), ('%s_to_proposition_p2_male'):format(anim), 2, true)
    playPair(hooker, 'proposition_loop_prostitute', 'proposition_loop_male', 1, false)
end

local function chooseService()
    local cfg = Config()
    local options = {}
    for _, service in ipairs(SERVICES) do
        options[#options + 1] = {
            label = locale(service.locale),
            description = cfg.payment and locale('hookers.price', cfg[service.price]) or nil,
            icon = 'fa-solid fa-heart',
        }
    end
    options[#options + 1] = { label = locale('hookers.decline'), icon = 'fa-solid fa-xmark' }

    local p = promise.new()
    menuPromise = p
    local function resolve(value)
        if menuPromise ~= p then return end
        menuPromise = nil
        p:resolve(value)
    end
    lib.registerMenu({
        id = 'mri_Qbox:hookers',
        title = locale('hookers.menu_title'),
        position = 'top-left',
        options = options,
        onClose = function() resolve(nil) end,
    }, function(selected)
        resolve(SERVICES[selected] and SERVICES[selected].id or nil)
    end)
    lib.showMenu('mri_Qbox:hookers')
    return Citizen.Await(p)
end

local function stillWith(hooker, vehicle)
    return Mri.enabled('hookers') and DoesEntityExist(hooker) and not IsPedInjured(hooker) and cache.vehicle == vehicle
end

local function closeMenu()
    if menuPromise then lib.hideMenu(true) end
end

local function release(hooker, vehicle, speech)
    hint(nil)
    lockControls(false)
    if DoesEntityExist(hooker) then
        if speech then speak(hooker, speech) end
        ClearPedTasks(hooker)
        TaskLeaveVehicle(hooker, vehicle, 0)
    end
    if current and current.lightsOff then
        SetVehicleLights(vehicle, 0)
        current.lightsOff = false
    end
    if current and current.served and cache.vehicle == vehicle then ClearPedTasks(cache.ped) end
    RemoveAnimDict(ANIM_DICT)
    Wait(5000)
    if DoesEntityExist(hooker) then setCalm(hooker, false) end
    if hooker == testPed then
        SetPedAsNoLongerNeeded(hooker)
        testPed = nil
    end
    current = nil
end

-- Waits until the car is stopped somewhere nobody can see it; false = gave up.
local function driveToSecludedArea(hooker, vehicle)
    speak(hooker, 'HOOKER_SECLUDED')
    waitSpeech(hooker)

    local deadline = GetGameTimer() + (tonumber(Config().secludedTime) or 120) * 1000
    local stoppedSince
    while true do
        if not stillWith(hooker, vehicle) then
            hint(nil)
            return false
        end
        local now = GetGameTimer()
        if now > deadline then
            lib.notify({ description = locale('hookers.secluded_failed'), type = 'error' })
            release(hooker, vehicle, 'HOOKER_LEAVES_ANGRY')
            return false
        end
        if GetEntitySpeed(vehicle) <= STOPPED_SPEED then
            stoppedSince = stoppedSince or now
            if now - stoppedSince >= 500 then
                if isSecluded(hooker, vehicle) then
                    hint(nil)
                    return true
                end
                hint('find_secluded')
            end
        else
            stoppedSince = nil
            hint(nil)
        end
        Wait(250)
    end
end

local function serve(hooker, vehicle)
    SetVehicleLights(vehicle, 1)
    current.lightsOff = true
    current.served = true
    lockControls(true)
    lib.requestAnimDict(ANIM_DICT)

    Wait(500)
    speak(hooker, 'HOOKER_OFFER_SERVICE')
    playPair(hooker, 'proposition_loop_prostitute', 'proposition_loop_male', 1, false)
    waitSpeech(hooker)

    local done = 0
    while done < Config().maxServices and stillWith(hooker, vehicle) do
        if done > 0 then speak(hooker, 'HOOKER_OFFER_AGAIN') end
        local service = chooseService()
        if not service or not stillWith(hooker, vehicle) then break end
        if Config().payment and not lib.callback.await('mri_Qbox:hookers:pay', false, service) then
            lib.notify({ description = locale('hookers.no_money'), type = 'error' })
            break
        end
        playScene(service, hooker, vehicle)
        done += 1
    end

    if not DoesEntityExist(hooker) then return release(hooker, vehicle) end
    local speech = 'HOOKER_DECLINED'
    if done >= Config().maxServices then
        speech = 'HOOKER_HAD_ENOUGH'
    elseif done == 0 then
        speech = 'HOOKER_LEAVES_ANGRY'
    end
    release(hooker, vehicle, speech)
end

local function pickUp(hooker, vehicle)
    current = { hooker = hooker, vehicle = vehicle }
    setCalm(hooker, true)
    TaskEnterVehicle(hooker, vehicle, 10000, PASSENGER_SEAT, 1.0, 1, 0)

    while true do
        if not stillWith(hooker, vehicle) then return release(hooker, vehicle) end
        local status = GetScriptTaskStatus(hooker, `SCRIPT_TASK_ENTER_VEHICLE`)
        if status == 7 then
            if GetPedInVehicleSeat(vehicle, PASSENGER_SEAT) ~= hooker then return release(hooker, vehicle) end
            break
        end
        Wait(100)
    end

    if driveToSecludedArea(hooker, vehicle) then
        serve(hooker, vehicle)
    elseif current then
        release(hooker, vehicle)
    end
end

-- Shows the prompt while the hooker is in range; true = the player honked.
local function offer(hooker, vehicle)
    local allowed = vehicleAllowed(vehicle, Config())
    while Mri.enabled('hookers') and inRange(hooker, vehicle) do
        if not allowed then
            hint('vehicle_unsuitable')
        elseif not IsVehicleSeatFree(vehicle, PASSENGER_SEAT) then
            hint('seat_occupied')
        else
            hint('invite')
            if IsControlJustPressed(0, HORN_CONTROL) then
                hint(nil)
                return true
            end
        end
        Wait(0)
    end
    hint(nil)
    return false
end

local function search()
    if searching or current or not Mri.enabled('hookers') then return end
    searching = true
    CreateThread(function()
        while Mri.enabled('hookers') and not current and cache.vehicle and cache.seat == -1 do
            local vehicle = cache.vehicle
            if GetEntitySpeed(vehicle) <= STOPPED_SPEED then
                local hooker = findHooker(vehicle, Config())
                if hooker and offer(hooker, vehicle) then
                    searching = false
                    pickUp(hooker, vehicle)
                    return search()
                end
            end
            Wait(500)
        end
        searching = false
    end)
end

lib.onCache('seat', function(seat)
    if seat == -1 then
        SetTimeout(0, search)
    else
        closeMenu()
    end
end)

AddEventHandler('mri_Qbox:configChanged', function()
    if not Mri.enabled('hookers') then return closeMenu() end
    search()
end)
CreateThread(search)

local function removeTestPed()
    if testPed and DoesEntityExist(testPed) then DeleteEntity(testPed) end
    testPed = nil
end

-- Puts a hooker standing on the passenger side of the car (or in front of the player on foot).
local function spawnTestHooker()
    local models = Config().models or {}
    local model = models[math.random(math.max(#models, 1))]
    if not model or not IsModelInCdimage(joaat(model)) or not IsModelAPed(joaat(model)) then
        return lib.notify({ description = locale('hookers.test_no_model'), type = 'error' })
    end
    if current then
        return lib.notify({ description = locale('hookers.test_busy'), type = 'error' })
    end
    lib.requestModel(model)
    removeTestPed()

    local anchor = cache.vehicle or cache.ped
    local spot = cache.vehicle and GetOffsetFromEntityInWorldCoords(anchor, 3.5, 0.0, 0.0) or GetOffsetFromEntityInWorldCoords(anchor, 0.0, 3.0, 0.0)
    local found, safe = GetSafeCoordForPed(spot.x, spot.y, spot.z, true, 16)
    if found and #(safe - spot) < 5.0 then spot = safe end

    local origin = GetEntityCoords(anchor)
    local heading = GetHeadingFromVector_2d(origin.x - spot.x, origin.y - spot.y)
    testPed = CreatePed(4, joaat(model), spot.x, spot.y, spot.z, heading, false, false)
    SetModelAsNoLongerNeeded(joaat(model))
    TaskStartScenarioInPlace(testPed, 'WORLD_HUMAN_PROSTITUTE_HIGH_CLASS', 0, true)
    lib.notify({ description = locale('hookers.test_spawned'), type = 'success' })
end

RegisterNUICallback('hookersSpawn', function(data, cb)
    cb(true)
    if not Mri.enabled('hookers') or not lib.callback.await('mri_Qbox:panel:isAdmin', false) then return end
    Mri.closePanel(type(data) == 'table' and data.embedded == true)
    spawnTestHooker()
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    removeTestPed()
    if not current then return end
    controlsLocked = false
    if DoesEntityExist(current.hooker) then
        setCalm(current.hooker, false)
        ClearPedTasks(current.hooker)
        TaskLeaveVehicle(current.hooker, current.vehicle, 0)
    end
    if current.lightsOff then SetVehicleLights(current.vehicle, 0) end
    if current.served then ClearPedTasks(cache.ped) end
end)
