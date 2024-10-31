if cfg.entervehicle.toggle then
    exports.ox_target:addGlobalVehicle(
        {
            {
                name = "ox_target:driverF_ENTER",
                icon = "fa-solid fa-right-to-bracket",
                label = "Porta dianteira do motorista",
                bones = {"seat_dside_f"},
                distance = 2,
                onSelect = function(data)
                    local vehicle = data.entity
                    local isVehicleShopEntity = Entity(vehicle).state.isVehicleShopEntity

                    if isVehicleShopEntity and isVehicleShopEntity ~= "" then
                        exports.qbx_core:Notify("Você não pode entrar em carros da concessionária")
                    else
                        TaskEnterVehicle(PlayerPedId(), vehicle, 10000, -1, 1.0, 1, 0)
                    end
                end
            },
            {
                name = "ox_target:passengerF_ENTER",
                icon = "fa-solid fa-right-to-bracket",
                label = "Porta dianteira do passageiro",
                bones = {"seat_pside_f"},
                distance = 2,
                onSelect = function(data)
                    local vehicle = data.entity
                    local isVehicleShopEntity = Entity(vehicle).state.isVehicleShopEntity

                    if isVehicleShopEntity and isVehicleShopEntity ~= "" then
                        exports.qbx_core:Notify("Você não pode entrar em carros da concessionária")
                    else
                        TaskEnterVehicle(PlayerPedId(), vehicle, 10000, -1, 1.0, 1, 0)
                    end
                end
            },
            {
                name = "ox_target:driverR_ENTER",
                icon = "fa-solid fa-right-to-bracket",
                label = "Porta traseira do motorista",
                bones = {"seat_dside_r"},
                distance = 2,
                onSelect = function(data)
                    local vehicle = data.entity
                    local isVehicleShopEntity = Entity(vehicle).state.isVehicleShopEntity

                    if isVehicleShopEntity and isVehicleShopEntity ~= "" then
                        exports.qbx_core:Notify("Você não pode entrar em carros da concessionária")
                    else
                        TaskEnterVehicle(PlayerPedId(), vehicle, 10000, -1, 1.0, 1, 0)
                    end
                end
            },
            {
                name = "ox_target:passengerR_ENTER",
                icon = "fa-solid fa-right-to-bracket",
                label = "Porta traseira do passageiro",
                bones = {"seat_pside_r"},
                distance = 2,
                onSelect = function(data)
                    local vehicle = data.entity
                    local isVehicleShopEntity = Entity(vehicle).state.isVehicleShopEntity

                    if isVehicleShopEntity and isVehicleShopEntity ~= "" then
                        exports.qbx_core:Notify("Você não pode entrar em carros da concessionária")
                    else
                        TaskEnterVehicle(PlayerPedId(), vehicle, 10000, -1, 1.0, 1, 0)
                    end
                end
            }
            -- {
            --     name = 'ox_target:trunk_ENTER',
            --     icon = 'fa-solid fa-car-rear',
            --     label = "Entrar no porta-malas",
            --     offset = vec3(0.5, 0, 0.5),
            --     distance = 2,
            --     onSelect = function(data)
            --         ExecuteCommand("getintrunk")
            --     end
            -- }
        }
    )
end

-- trunkchest

-- exports.ox_target:addModel(cfg.dumpsters.TrashCans.Model, {
--     icon = 'fas fa-dumpster',
--     label = "Vasculhar",
--     onSelect = function(data)
--         local entity = data.entity
--         local netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity)
--         if not netId then
--             local coords = GetEntityCoords(entity)
--             entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 0.1, GetEntityModel(entity), true, true, true)
--             netId = entity ~= 0 and NetworkGetNetworkIdFromEntity(entity)
--         end
--         if netId then

--             exports.ox_inventory:openInventory('dumpster', 'dumpster'..netId)
--         end
--     end,
--     distance = 1,
-- })

-- exports.ox_target:addGlobalVehicle({
--     icon = 'fa-solid fa-car-rear',
--     label = "Abrir/vasculhar porta-malas",
--     offset = vec3(0.5, 0, 0.5),
--     onSelect = function(data)
--         local entity = data.entity
--         local netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity)
--         if not netId then
--             local coords = GetEntityCoords(entity)
--             entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 0.1, GetEntityModel(entity), true, true, true)
--             netId = entity ~= 0 and NetworkGetNetworkIdFromEntity(entity)
--         end
--         if netId then
--             if GetVehicleDoorLockStatus(entity) > 1 then
--                 return lib.notify({ id = 'vehicle_locked', type = 'error', description = "Veículo trancado" })
--             end

--             local coords = GetEntityCoords(entity)
--             TaskTurnPedToFaceCoord(GetPlayerPed(-1), coords.x, coords.y, coords.z, 0)

--             local plate = GetVehicleNumberPlateText(entity)
--             local invId = 'trunk'..plate

--             TriggerEvent("ox_target:toggleEntityDoor", netId , 5)
--             exports.ox_inventory:openInventory('trunk', { id = invId, netid = NetworkGetNetworkIdFromEntity(entity), entityid = entity, door = true })
--         end
--     end,
--     distance = 2,
-- })

-- -- function Inventory.OpenTrunk(entity)
-- --     ---@type number | number[] | nil
-- --     local door = Inventory.CanAccessTrunk(entity)

-- --     if not door then return end

-- --     if GetVehicleDoorLockStatus(entity) > 1 then
-- --         return lib.notify({ id = 'vehicle_locked', type = 'error', description = locale('vehicle_locked') })
-- --     end

-- --     local plate = GetVehicleNumberPlateText(entity)
-- --     local invId = 'trunk'..plate
-- --     local coords = GetEntityCoords(entity)

-- --     TaskTurnPedToFaceCoord(cache.ped, coords.x, coords.y, coords.z, 0)

-- --     if not client.openInventory('trunk', { id = invId, netid = NetworkGetNetworkIdFromEntity(entity), entityid = entity, door = door }) then return end

-- --     if type(door) == 'table' then
-- --         for i = 1, #door do
-- --             SetVehicleDoorOpen(entity, door[i], false, false)
-- --         end
-- --     else
-- --         SetVehicleDoorOpen(entity, door --[[@as number]], false, false)
-- --     end
-- -- end

-- carexplosion

CreateThread(
    function()
        local playerdataLoaded = false
        local controlGround = false
        local inGround = false
        while cfg.carexplosion.toggle do
            local sleep = 2000
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local pedInVeh = IsPedInAnyVehicle(ped, false)
            if pedInVeh then
                local veh = GetVehiclePedIsIn(ped, false)
                local seat = GetPedInVehicleSeat(veh, -1)
                local vehArmor = GetVehicleMod(veh, 16)
                local vehClass =
                    GetVehicleClass(veh) == 15 and true or GetVehicleClass(veh) == 16 and true or
                    GetVehicleClass(veh) == 8 and true or
                    false
                if not vehClass then
                    if seat then
                        sleep = 1000
                        local vehHeight = GetEntityHeightAboveGround(veh)
                        if vehHeight >= 1 then
                            local vehFly = IsEntityInAir(veh)
                            if not controlGround then
                                if vehHeight >= cfg.carexplosion.height and vehFly then
                                    local retval, groundz = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, 0)
                                    local ground = GetEntityCoords(veh).z
                                    if retval then
                                        if ground > groundz then
                                            controlGround = true
                                        end
                                    else
                                        controlGround = true
                                    end
                                end
                            else
                                sleep = 1
                                vehHeight = GetEntityHeightAboveGround(veh)
                                vehFly = IsEntityInAir(veh)
                                inGround = vehHeight < 2 and true or false

                                if inGround then
                                    controlGround = false
                                    SetVehicleEngineHealth(veh, 0)
                                    SetVehiclePetrolTankHealth(veh, 0)
                                    DetachVehicleWindscreen(veh)
                                    SmashVehicleWindow(veh, 0)
                                    AddExplosion(GetEntityCoords(veh), 7, 50.0, true, false, 5.0)
                                    sleep = 500
                                end
                            end
                        else
                            sleep = 2000
                        end
                    end
                end
            else
                controlGround = false
                inGround = false
            end
            Wait(sleep)
        end
    end
)

-- Otimização em cima do RealisticAirControl by .mur4i
-- contriubição: .reiffps

Citizen.CreateThread(
    function()
        local playerPed = -1
        local vehicle = nil
        local vehicleClass = nil
        local vehicleClassDisableControl = {
            [0] = true, --compacts
            [1] = true, --sedans
            [2] = true, --SUV's
            [3] = true, --coupes
            [4] = true, --muscle
            [5] = true, --sport classic
            [6] = true, --sport
            [7] = true, --super
            [8] = false, --motorcycle
            [9] = true, --offroad
            [10] = true, --industrial
            [11] = true, --utility
            [12] = true, --vans
            [13] = false, --bicycles
            [14] = false, --boats
            [15] = false, --helicopter
            [16] = false, --plane
            [17] = true, --service
            [18] = true, --emergency
            [19] = false --military
        }
        local disableIfFlying = true -- Enable/disable control disable while flying

        while cfg.disableaircontrol.toogle do
            if not IsPedInAnyVehicle(playerPed) then
                -- Player not in vehicle, reset variables
                playerPed = GetPlayerPed(-1)
                vehicle = nil
                vehicleClass = nil
                Citizen.Wait(1000)
            else
                if playerPed ~= GetPlayerPed(-1) or vehicle ~= GetVehiclePedIsIn(playerPed, false) then
                    -- Player or vehicle changed, update variables
                    playerPed = GetPlayerPed(-1)
                    vehicle = GetVehiclePedIsIn(playerPed, false)
                    if IsPedInAnyVehicle(playerPed) then
                        vehicleClass = GetVehicleClass(vehicle)
                    end
                end

                if
                    vehicleClass and vehicleClassDisableControl[vehicleClass] and
                        (GetPedInVehicleSeat(vehicle, -1) == playerPed)
                 then
                    if disableIfFlying and IsEntityInAir(vehicle) then
                        DisableControlAction(2, 59) -- Disable jump control
                        DisableControlAction(2, 60) -- Disable exit vehicle control
                    end
                end
            end

            Citizen.Wait(0) -- Wait for next frame without unnecessary delay
        end
    end
)

-- drift

local score = 0
local screenScore = 0
local tick
local idleTime
local driftTime
local tablemultiplier = {350, 1400, 4200, 11200}
local mult = 0.2
local previous = 0
local total = 0
local curAlpha = 0

local SaveAtEndOfDrift = nil
local SaveTime = nil

function round(number)
    number = tonumber(number)
    number = math.floor(number)

    if number < 0.01 then
        number = 0
    elseif number > 999999999 then
        number = 999999999
    end
    return number
end

function calculateBonus(previous)
    local points = previous
    local points = round(points)
    return points or 0
end

function angle(veh)
    if not veh then
        return false
    end
    local vx, vy, vz = table.unpack(GetEntityVelocity(veh))
    local modV = math.sqrt(vx * vx + vy * vy)

    local rx, ry, rz = table.unpack(GetEntityRotation(veh, 0))
    local sn, cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))

    if GetEntitySpeed(veh) * 3.6 < 30 or GetVehicleCurrentGear(veh) == 0 then
        return 0, modV
    end --speed over 30 km/h

    local cosX = (sn * vx + cs * vy) / modV
    if cosX > 0.966 or cosX < 0 then
        return 0, modV
    end
    return math.deg(math.acos(cosX)) * 0.5, modV
end

local stopped = false

Citizen.CreateThread(
    function()
        while cfg.drift.points do
            local sleep = 1000
            PlayerPed = PlayerPedId()
            tick = GetGameTimer()
            if
                not IsPedDeadOrDying(PlayerPed, 1) and GetVehiclePedIsUsing(PlayerPed) and
                    GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPed), -1) == PlayerPed and
                    IsVehicleOnAllWheels(GetVehiclePedIsUsing(PlayerPed)) and
                    not IsPedInFlyingVehicle(PlayerPed)
             then
                sleep = 1
                PlayerVeh = GetVehiclePedIsIn(PlayerPed, false)
                local angle, velocity = angle(PlayerVeh)
                local tempBool = tick - (idleTime or 0) < 1850

                if angle ~= 0 then
                    stopped = false
                    if score == 0 then
                        driftTime = tick
                    end
                    if tempBool then
                        score = score + math.floor(angle * velocity) * mult
                    else
                        score = math.floor(angle * velocity) * mult
                    end
                    screenScore = calculateBonus(score)

                    idleTime = tick
                else
                    if old and not stopped then
                        if old > 0 then
                            if old == screenScore then
                                SendNUIMessage({drift = 0})
                                stopped = true
                            end
                        end
                    end
                end
            end

            if tick - (idleTime or 0) < 3000 then
                if curAlpha < 255 and curAlpha + 10 < 255 then
                    curAlpha = curAlpha + 10
                elseif curAlpha > 255 then
                    curAlpha = 255
                elseif curAlpha == 255 then
                    curAlpha = 255
                elseif curAlpha == 250 then
                    curAlpha = 255
                end
            else
                if curAlpha > 0 and curAlpha - 10 > 0 then
                    curAlpha = curAlpha - 10
                elseif curAlpha < 0 then
                    curAlpha = 0
                elseif curAlpha == 5 then
                    curAlpha = 0
                end
            end

            if not stopped then
                if not screenScore then
                    screenScore = 0
                    SendNUIMessage({drift = 0})
                else
                    SendNUIMessage({drift = screenScore})
                end
                old = screenScore
            end

            Citizen.Wait(500)
        end
    end
)

Citizen.CreateThread(
    function()
        while cfg.drift.points do
            if not IsPedInAnyVehicle(PlayerPedId()) and stopped == false then
                SendNUIMessage({drift = 0})
                stopped = true
            end
            Citizen.Wait(1000)
        end
    end
)

----------------------------------------------------------------------------------------------------------------------------------------
-- DRIFT
-----------------------------------------------------------------------------------------------------------------------------------------
local kmh, mph = 3.6, 2.23693629
local carSpeed = 0
local speed = kmh
local speedLimit = cfg.drift.speed
Citizen.CreateThread(
    function()
        while cfg.drift.toggle do
            Citizen.Wait(500)
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                carSpeed = GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId())) * speed
                if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId() then
                    if (carSpeed <= speedLimit) then
                        if IsControlPressed(0, 21) then
                            SetVehicleReduceGrip(GetVehiclePedIsIn(PlayerPedId(), false), true)
                        else
                            SetVehicleReduceGrip(GetVehiclePedIsIn(PlayerPedId(), false), false)
                        end
                    end
                end
            end
        end
    end
)

-- forcefps
local forcefps = false

Citizen.CreateThread(
    function()
        while true do
            local delay = 1000

            if cfg.forcedfirstperson.invehicle.ativar then
                local ped = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(ped, false)

                if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
                    local _, weapon = GetCurrentPedWeapon(ped)
                    local unarmed = GetHashKey("WEAPON_UNARMED")

                    if weapon ~= unarmed then
                        if cfg.forcedfirstperson.invehicle.hold then
                            if IsControlJustPressed(0, 25) then
                                SetFollowVehicleCamViewMode(3)
                            elseif IsControlJustReleased(0, 25) then
                                SetFollowVehicleCamViewMode(0)
                            end
                        else
                            SetFollowVehicleCamViewMode(3)
                        end
                        delay = 100
                    end
                end
            end

            if cfg.forcedfirstperson.twopov then
                if forcefps then
                    SetFollowPedCamViewMode(4)
                else
                    SetFollowPedCamViewMode(0)
                end

                if IsControlJustReleased(0, 0) then
                    forcefps = not forcefps
                end

                delay = 5
            end

            Citizen.Wait(delay)
        end
    end
)

-- -- CreateThread(function()
-- --     while cfg.forcedfirstperson.invehicle do
-- --         local ped = PlayerPedId()
-- --         local _, weapon = GetCurrentPedWeapon(ped)
-- --         local unarmed = `WEAPON_UNARMED`
-- --         local inVeh = GetVehiclePedIsIn(PlayerPedId(), false)
-- --         sleep = 1000
-- --         if IsPedInAnyVehicle(PlayerPedId()) and weapon ~= unarmed then
-- --             sleep = 1
-- --             if IsControlJustPressed(0, 25) then
-- --                 SetFollowVehicleCamViewMode(3)
-- --             elseif IsControlJustReleased(0, 25) then
-- --                 -- SetFollowVehicleCamViewMode(0)
-- --             end
-- --         end
-- --         Wait(sleep)
-- --     end
-- -- end)

-- mercosulPlates

if Config.mercosulPlates then
    imageUrl = "https://assets.mriqbox.com.br/dui/platebr_image.png"

    local textureDic = CreateRuntimeTxd("duiTxd")
    local object = CreateDui(imageUrl, 540, 300)
    local handle = GetDuiHandle(object)
    CreateRuntimeTextureFromDuiHandle(textureDic, "duiTex", handle)
    AddReplaceTexture("vehshare", "plate01", "duiTxd", "duiTex")
    AddReplaceTexture("vehshare", "plate02", "duiTxd", "duiTex")
    AddReplaceTexture("vehshare", "plate03", "duiTxd", "duiTex")
    AddReplaceTexture("vehshare", "plate04", "duiTxd", "duiTex")
    AddReplaceTexture("vehshare", "plate05", "duiTxd", "duiTex")

    local object = CreateDui("https://assets.mriqbox.com.br/dui/platebr_object.png", 540, 300)
    local handle = GetDuiHandle(object)
    CreateRuntimeTextureFromDuiHandle(textureDic, "duiTex2", handle)
    AddReplaceTexture("vehshare", "plate01_n", "duiTxd", "duiTex2")
    AddReplaceTexture("vehshare", "plate02_n", "duiTxd", "duiTex2")
    AddReplaceTexture("vehshare", "plate03_n", "duiTxd", "duiTex2")
    AddReplaceTexture("vehshare", "plate04_n", "duiTxd", "duiTex2")
    AddReplaceTexture("vehshare", "plate05_n", "duiTxd", "duiTex2")
end

-- from md_savewheelpos
-- contribuição: .reiffps

Citizen.CreateThread(
    function()
        local angle = 0.0
        local speed = 0.0
        while cfg.savewheelpos.toggle do
            Citizen.Wait(0)
            local veh = GetVehiclePedIsUsing(PlayerPedId())
            if DoesEntityExist(veh) then
                local tangle = GetVehicleSteeringAngle(veh)
                if tangle > 10.0 or tangle < -10.0 then
                    angle = tangle
                end
                speed = GetEntitySpeed(veh)
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                if
                    speed < 0.1 and DoesEntityExist(vehicle) and not GetIsTaskActive(PlayerPedId(), 151) and
                        not GetIsVehicleEngineRunning(vehicle)
                 then
                    SetVehicleSteeringAngle(GetVehiclePedIsIn(PlayerPedId(), true), angle)
                end
            else
                Citizen.Wait(1000)
            end
        end
    end
)

-- wheelbreak

local wheelBreakSpeed = cfg.wheelbreak.speed -- Speed at which the wheel breaks

--[[ Vehicle classes:
0: Compacts   1: Sedans   2: SUVs   3: Coupes   4: Muscle
5: Sports Classics   6: Sports   7: Super   8: Motorcycles   9: Off-road
10: Industrial   11: Utility   12: Vans   13: Cycles   14: Boats
15: Helicopters   16: Planes   17: Service   18: Emergency   19: Military
20: Commercial   21: Trains ]]
local excludedClasses = {
    [8] = true,
    [9] = true,
    [14] = true,
    [15] = true,
    [16] = true
}

---@param class string Vehicle class
---@return boolean
local function isVehicleClassValid(class)
    return not excludedClasses[class]
end

CreateThread(
    function()
        while cfg.wheelbreak.toogle do
            local waitLoop = 5000
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if GetPedInVehicleSeat(vehicle, -1) ~= 0 and isVehicleClassValid(GetVehicleClass(vehicle)) then
                    waitLoop = 10
                    local vehicleSpeed = math.ceil(GetEntitySpeed(vehicle) * 3.6)
                    if HasEntityCollidedWithAnything(vehicle) and vehicleSpeed >= wheelBreakSpeed then
                        local randomWheelIndex = math.random(0, 3) -- Wheel index to break off
                        ---@see https://github.com/citizenfx/fivem/commit/46205c9ff15bdc9e19d81dd126500a854c8547e9
                        BreakOffVehicleWheel(vehicle, randomWheelIndex, true, false, true, false)
                        waitLoop = 5000
                    end
                end
            end
            Wait(waitLoop)
        end
    end
)

-- RegisterNetEvent("vehtuning", function()
lib.callback.register(
    "vehtuning",
    function()
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped)
        if IsEntityAVehicle(vehicle) then
            SetVehicleModKit(vehicle, 0)
            -- SetVehicleMod(vehicle,0,GetNumVehicleMods(vehicle,0)-1,false) -- spoiler
            SetVehicleMod(vehicle, 1, GetNumVehicleMods(vehicle, 1) - 1, false)
            SetVehicleMod(vehicle, 2, GetNumVehicleMods(vehicle, 2) - 1, false)
            SetVehicleMod(vehicle, 3, GetNumVehicleMods(vehicle, 3) - 1, false)
            SetVehicleMod(vehicle, 4, GetNumVehicleMods(vehicle, 4) - 1, false)
            SetVehicleMod(vehicle, 5, GetNumVehicleMods(vehicle, 5) - 1, false)
            SetVehicleMod(vehicle, 6, GetNumVehicleMods(vehicle, 6) - 1, false)
            -- SetVehicleMod(vehicle,7,GetNumVehicleMods(vehicle,7)-1,false) -- bonnet
            SetVehicleMod(vehicle, 8, GetNumVehicleMods(vehicle, 8) - 1, false)
            SetVehicleMod(vehicle, 9, GetNumVehicleMods(vehicle, 9) - 1, false)
            -- SetVehicleMod(vehicle,10,GetNumVehicleMods(vehicle,10)-1,false) -- roof
            SetVehicleMod(vehicle, 11, GetNumVehicleMods(vehicle, 11) - 1, false)
            SetVehicleMod(vehicle, 12, GetNumVehicleMods(vehicle, 12) - 1, false)
            SetVehicleMod(vehicle, 13, GetNumVehicleMods(vehicle, 13) - 1, false)
            -- SetVehicleMod(vehicle,14,16,false) -- horn
            SetVehicleMod(vehicle, 15, GetNumVehicleMods(vehicle, 15) - 2, false)
            SetVehicleMod(vehicle, 16, GetNumVehicleMods(vehicle, 16) - 1, false)
            ToggleVehicleMod(vehicle, 17, true)
            ToggleVehicleMod(vehicle, 18, true)
            ToggleVehicleMod(vehicle, 19, true)
            ToggleVehicleMod(vehicle, 20, true)
            ToggleVehicleMod(vehicle, 21, true)
            ToggleVehicleMod(vehicle, 22, true)
            -- SetVehicleMod(vehicle,23,1,false) -- wheels
            -- SetVehicleMod(vehicle,24,1,false) -- bike wheels back
            SetVehicleMod(vehicle, 25, GetNumVehicleMods(vehicle, 25) - 1, false)
            -- SetVehicleMod(vehicle,27,GetNumVehicleMods(vehicle,27)-1,false)
            SetVehicleMod(vehicle, 28, GetNumVehicleMods(vehicle, 28) - 1, false)
            SetVehicleMod(vehicle, 30, GetNumVehicleMods(vehicle, 30) - 1, false)
            SetVehicleMod(vehicle, 33, GetNumVehicleMods(vehicle, 33) - 1, false)
            SetVehicleMod(vehicle, 34, GetNumVehicleMods(vehicle, 34) - 1, false)
            SetVehicleMod(vehicle, 35, GetNumVehicleMods(vehicle, 35) - 1, false)
            SetVehicleMod(vehicle, 38, GetNumVehicleMods(vehicle, 38) - 1, true)
            SetVehicleTyreSmokeColor(vehicle, 0, 0, 0)
            SetVehicleWindowTint(vehicle, 1)
            SetVehicleTyresCanBurst(vehicle, false)
            -- SetVehicleNumberPlateText(vehicle,"Fluxooo")
            SetVehicleNumberPlateTextIndex(vehicle, 5)
            SetVehicleModColor_1(vehicle, 0, 0, 0)
            SetVehicleModColor_2(vehicle, 0, 0)
            SetVehicleColours(vehicle, 0, 0)
            SetVehicleExtraColours(vehicle, 0, 0)
        -- SetVehicleNeonLightEnabled(vehicle,0,true)
        -- SetVehicleNeonLightEnabled(vehicle,1,true)
        -- SetVehicleNeonLightEnabled(vehicle,2,true)
        -- SetVehicleNeonLightEnabled(vehicle,3,true)
        -- SetVehicleNeonLightsColour(vehicle,255,255,255)
        end
    end
)
