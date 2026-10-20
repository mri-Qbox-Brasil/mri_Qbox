-- Cancelas do mapa no door system do GTA, abrindo sozinhas pro carro. Substitui o cfx-anes-gates.
-- A lista vem do painel: o admin adiciona mirando no portão (regras da mri-world-placement).

local Wait, DoorSystemGetIsPhysicsLoaded, DoorSystemSetAutomaticDistance, DoorSystemSetAutomaticRate =
    Wait, DoorSystemGetIsPhysicsLoaded, DoorSystemSetAutomaticDistance, DoorSystemSetAutomaticRate

local REFRESH_INTERVAL <const> = 100
local PHYSICS_CHECK_TICKS <const> = 20
-- Railway barriers were set once in the original; the parking ones lose the distance when physics reload.
local KINDS <const> = {
    [`prop_sec_barrier_ld_01a`] = 'Cancela de estacionamento',
    [`prop_sec_barrier_ld_02a`] = 'Cancela de estacionamento',
    [`prop_railway_barrier_01`] = 'Cancela de trem',
    [`prop_railway_barrier_02`] = 'Cancela de trem',
}
local NO_REFRESH <const> = { [`prop_railway_barrier_01`] = true, [`prop_railway_barrier_02`] = true }

-- Hashes compare as signed 32 bit: GetEntityModel and the backtick literals may disagree on the sign.
local function signed(hash)
    if hash and hash > 0x7FFFFFFF then return hash - 0x100000000 end
    return hash
end

local function modelHash(model)
    if type(model) == 'string' then return signed(math.tointeger(tonumber(model)) or joaat(model)) end
    return signed(math.tointeger(model))
end

-- Manual gates open for a vehicle this far past the distance, measured from the middle of the arm (the lane), not the pivot.
local REVERSE_REACH <const> = 3.5
local REVERSE_RANGE <const> = 80.0

---@type { hash: number, model: number, coords: vector3, kind: string, mode: 'game'|'reverse'|'both', ratio: number, target: number, object?: number }[]
local entries = {}
local reach = 1.5
local running = 0

-- Doors stay in the system across changes: one removed and added back only works again after the gate streams in anew.
local registered = {}

local function register(model, x, y, z)
    local key = ('%d_%.1f_%.1f_%.1f'):format(model, x, y, z)
    if registered[key] then return registered[key] end
    local found, hash = DoorSystemFindExistingDoor(x, y, z, model)
    if not found then
        hash = joaat('mri_gate_' .. key)
        AddDoorToSystem(hash, model, x, y, z, false, false, false)
    end
    registered[key] = hash
    return hash
end

local function apply(hash, distance, rate)
    DoorSystemSetAutomaticDistance(hash, distance, false, true)
    DoorSystemSetAutomaticRate(hash, rate, false, true)
end

-- Swings a manual gate towards its target a bit each frame; the target may change mid way.
local function animate(entry, speed, id)
    if entry.moving then return end
    entry.moving = true
    CreateThread(function()
        DoorSystemSetHoldOpen(entry.hash, true)
        while running == id and entry.ratio ~= entry.target do
            local step = speed * GetFrameTime()
            local diff = entry.target - entry.ratio
            entry.ratio = math.abs(diff) <= step and entry.target or entry.ratio + (diff > 0 and step or -step)
            DoorSystemSetOpenRatio(entry.hash, entry.ratio, false, true)
            Wait(0)
        end
        if entry.ratio == 0.0 then DoorSystemSetHoldOpen(entry.hash, false) end
        entry.moving = false
    end)
end

local function closestVehicle(vehicles, coords)
    local best, bestDist
    for i = 1, #vehicles do
        local dist = #(GetEntityCoords(vehicles[i]).xy - coords.xy)
        if not bestDist or dist < bestDist then best, bestDist = vehicles[i], dist end
    end
    return best, bestDist
end

-- The gate entity and the middle of its arm, taken while closed (open, the arm points up).
local function resolve(entry)
    if not entry.object or not DoesEntityExist(entry.object) then
        local object = GetClosestObjectOfType(entry.coords.x, entry.coords.y, entry.coords.z, 1.0, entry.model, false, false, false)
        entry.object = object ~= 0 and object or nil
    end
    if entry.object and not entry.center and entry.ratio == 0.0 then
        local min, max = GetModelDimensions(entry.model)
        entry.center = GetOffsetFromEntityInWorldCoords(entry.object, (min.x + max.x) / 2, (min.y + max.y) / 2, 0.0)
    end
end

-- Both ways: the arm swings away from the side the vehicle comes from, and keeps that way until it passes.
local function sideTarget(entry, vehicle)
    if not entry.object then return -1.0 end
    local forward = GetEntityForwardVector(entry.object)
    local offset = GetEntityCoords(vehicle) - (entry.center or entry.coords)
    return (offset.x * forward.x + offset.y * forward.y) >= 0 and -1.0 or 1.0
end

Mri.lifecycle('gates', function(cfg)
    local distance, rate = tonumber(cfg.distance) or 1.5, tonumber(cfg.rate) or 1.5
    reach = distance
    local direction = (cfg.direction == 'reverse' or cfg.direction == 'both') and cfg.direction or 'game'

    for _, gate in ipairs(type(cfg.gates) == 'table' and cfg.gates or {}) do
        local model, x, y, z = modelHash(gate.model), tonumber(gate.x), tonumber(gate.y), tonumber(gate.z)
        if model and x and y and z then
            local hash = register(model, x, y, z)
            local mode = direction
            if mode == 'game' and gate.reverse == true then mode = 'reverse' end
            -- manual gates are swung by the module, so the game's own opening stays off
            apply(hash, mode == 'game' and distance or 0.0, rate)
            entries[#entries + 1] = {
                hash = hash, model = model, coords = vec3(x, y, z), kind = KINDS[model] or 'Portão',
                mode = mode, ratio = 0.0, target = 0.0,
            }
        end
    end

    running += 1
    local id = running
    CreateThread(function()
        local loaded, tick = {}, 0
        while running == id do
            if tick % PHYSICS_CHECK_TICKS == 0 then
                table.wipe(loaded)
                for _, entry in ipairs(entries) do
                    if entry.mode == 'game' and not NO_REFRESH[entry.model] and DoorSystemGetIsPhysicsLoaded(entry.hash) then
                        loaded[#loaded + 1] = entry.hash
                    end
                end
            end
            for _, hash in ipairs(loaded) do apply(hash, distance, rate) end

            local me, vehicles = GetEntityCoords(cache.ped), nil
            for _, entry in ipairs(entries) do
                if entry.mode ~= 'game' and #(me - entry.coords) < REVERSE_RANGE then
                    vehicles = vehicles or GetGamePool('CVehicle')
                    resolve(entry)
                    local vehicle, dist = closestVehicle(vehicles, entry.center or entry.coords)
                    entry.vehicleDist = dist
                    local target = 0.0
                    if vehicle and dist < distance + REVERSE_REACH then
                        if entry.target ~= 0.0 then
                            target = entry.target
                        elseif entry.mode == 'both' then
                            target = sideTarget(entry, vehicle)
                        else
                            target = -1.0
                        end
                    end
                    if target ~= entry.target then
                        entry.target = target
                        animate(entry, rate * 0.5, id)
                    end
                end
            end

            tick += 1
            Wait(REFRESH_INTERVAL)
        end
    end)
end, function()
    running += 1
    for _, entry in ipairs(entries) do
        if entry.mode ~= 'game' then
            DoorSystemSetOpenRatio(entry.hash, 0.0, false, true)
            DoorSystemSetHoldOpen(entry.hash, false)
        end
        -- off or out of the list: still in the door system, but no longer opens by itself
        DoorSystemSetAutomaticDistance(entry.hash, 0.0, false, true)
    end
    table.wipe(entries)
end)

-- ===== debug: the opening area of each gate, only on this admin's screen ===

local DEBUG_RANGE <const> = 50.0
local MODE_LABELS <const> = { game = 'abre sozinha', reverse = 'abre pro outro lado', both = 'abre pros dois lados' }
local debugOn = false

local function drawLabel(coords, text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function startDebug()
    local near = {}
    CreateThread(function()
        while debugOn do
            local me = GetEntityCoords(cache.ped)
            local list = {}
            for _, entry in ipairs(entries) do
                if #(me - entry.coords) < DEBUG_RANGE then
                    local c = entry.center or entry.coords
                    local found, groundZ = GetGroundZFor_3dCoord(c.x, c.y, entry.coords.z + 1.0, false)
                    list[#list + 1] = {
                        entry = entry,
                        ok = DoorSystemGetIsPhysicsLoaded(entry.hash),
                        ground = vec3(c.x, c.y, found and groundZ or entry.coords.z - 1.0),
                    }
                end
            end
            near = list
            Wait(500)
        end
    end)
    CreateThread(function()
        while debugOn do
            for i = 1, #near do
                local item = near[i]
                local entry, g = item.entry, item.ground
                local radius = entry.mode == 'game' and reach or reach + REVERSE_REACH
                local r, gr, b = 230, 60, 60
                if item.ok then r, gr, b = 0, 230, 153 end
                DrawMarker(1, g.x, g.y, g.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius * 2, radius * 2, 0.4, r, gr, b, 70, false, false, 2, false, nil, nil, false)
                local status = item.ok and MODE_LABELS[entry.mode] or 'não abre: prop não achado ou não é porta'
                local car = entry.mode ~= 'game' and entry.vehicleDist and ('~n~carro a %.1f m (abre com %.1f m)'):format(entry.vehicleDist, radius) or ''
                drawLabel(g + vec3(0.0, 0.0, 1.5), ('%s~n~%s%s'):format(entry.kind, status, car))
            end
            Wait(0)
        end
    end)
end

-- ===== picking a gate in the world ========================================

local KEY <const> = { mark = 38, undo = 177, cancel = 200 }
local BLOCKED <const> = { 14, 15, 16, 17, 24, 25, 37, 44, 140, 141, 142, 200 }
local SCAN_EVERY <const> = 150

local picking = false

-- escBusy tells the MRI pause menu (it reads Esc even while blocked) that Esc belongs to the tool.
local function hud(data)
    SendNUIMessage({ action = 'placeHud', data = data })
    if (data ~= false) ~= (LocalPlayer.state.escBusy == true) then LocalPlayer.state:set('escBusy', data ~= false, false) end
end

local function releaseEsc()
    repeat
        DisableControlAction(0, KEY.cancel, true)
        Wait(0)
    until not IsDisabledControlPressed(0, KEY.cancel)
    DisableControlAction(0, KEY.cancel, true)
end

local function accent()
    local hex = GetConvar('mri:color', '#00E699'):match('^#(%x%x%x%x%x%x)') or '00E699'
    return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

-- Gates driven by the door system often have no collision for the raycast: take the object closest to the camera ray.
local function scanAlongCamera()
    local camPos = GetGameplayCamCoord()
    local rot = GetGameplayCamRot(2)
    local rx, rz = math.rad(rot.x), math.rad(rot.z)
    local dir = vec3(-math.sin(rz) * math.cos(rx), math.cos(rz) * math.cos(rx), math.sin(rx))
    local best, bestProj = nil, math.huge

    for _, object in ipairs(GetGamePool('CObject')) do
        local offset = GetEntityCoords(object) - camPos
        local proj = offset.x * dir.x + offset.y * dir.y + offset.z * dir.z
        if proj > 0.3 and proj < 15.0 and proj < bestProj and #(offset - dir * proj) < 1.5 then
            best, bestProj = object, proj
        end
    end

    return best
end

-- The ox_lib raycast waits a frame, so it runs apart and the draw loop keeps every frame.
local function trackAim(aim)
    CreateThread(function()
        local scanned = 0
        while picking do
            local hit, entity, coords = lib.raycast.fromCamera(1 | 16, 4, 15.0)
            if hit and entity > 0 and GetEntityType(entity) == 3 then
                aim.entity, aim.coords = entity, coords
            elseif GetGameTimer() - scanned > SCAN_EVERY then
                scanned = GetGameTimer()
                local object = scanAlongCamera()
                aim.entity = object
                aim.coords = object and GetEntityCoords(object) or (hit and coords or nil)
            end
        end
    end)
end

local function isListed(list, model, coords)
    for _, gate in ipairs(list) do
        if modelHash(gate.model) == model and #(coords - vec3(tonumber(gate.x) or 0, tonumber(gate.y) or 0, tonumber(gate.z) or 0)) < 1.0 then
            return true
        end
    end
    return false
end

---@param list table[] gates already on the panel draft (they can't be picked twice)
---@return { model: number, x: number, y: number, z: number }|nil
local function pick(list)
    if picking then return nil end
    picking = true

    local aim = {}
    local r, g, b = accent()
    local outlined, result

    hud({ mode = 'gate' })
    trackAim(aim)

    while picking do
        for i = 1, #BLOCKED do DisableControlAction(0, BLOCKED[i], true) end

        local entity = aim.entity
        local valid = entity and DoesEntityExist(entity) and not isListed(list, signed(GetEntityModel(entity)), GetEntityCoords(entity)) and entity or nil

        if outlined ~= valid then
            if outlined then SetEntityDrawOutline(outlined, false) end
            outlined = valid
            if outlined then SetEntityDrawOutline(outlined, true) end
        end

        local point = aim.coords
        if point then
            DrawMarker(28, point.x, point.y, point.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.1, r, g, b, 220, false, false, 2, false, nil, nil, false)
        end

        if IsControlJustPressed(0, KEY.mark) and valid then
            PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
            local coords = GetEntityCoords(valid)
            result = { model = signed(GetEntityModel(valid)), x = coords.x, y = coords.y, z = coords.z }
            break
        elseif IsControlJustPressed(0, KEY.undo) then
            PlaySoundFrontend(-1, 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
            break
        elseif IsDisabledControlJustPressed(0, KEY.cancel) then
            PlaySoundFrontend(-1, 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
            releaseEsc()
            break
        end

        Wait(0)
    end

    picking = false
    hud(false)
    if outlined then SetEntityDrawOutline(outlined, false) end
    return result
end

-- ===== panel callbacks ====================================================

RegisterNUICallback('gatesPick', function(data, cb)
    if type(data) ~= 'table' or picking then return cb(false) end
    local list = type(data.gates) == 'table' and data.gates or {}
    CreateThread(function()
        cb(Mri.panelInWorld(data.embedded, function() return pick(list) end) or false)
    end)
end)

-- Kind, area and distance of each gate, so the panel lists them without coordinates.
RegisterNUICallback('gatesDescribe', function(data, cb)
    local out = {}
    local me = GetEntityCoords(cache.ped)
    for i, gate in ipairs(type(data) == 'table' and type(data.gates) == 'table' and data.gates or {}) do
        local x, y, z = tonumber(gate.x) or 0.0, tonumber(gate.y) or 0.0, tonumber(gate.z) or 0.0
        out[i] = {
            kind = KINDS[modelHash(gate.model)] or 'Portão',
            area = GetLabelText(GetNameOfZone(x, y, z)),
            distance = math.floor(#(me - vec3(x, y, z)) + 0.5),
        }
    end
    cb(out)
end)

RegisterNUICallback('gatesGoto', function(data, cb)
    cb(true)
    local x, y, z = tonumber(data and data.x), tonumber(data and data.y), tonumber(data and data.z)
    if not x or not y or not z or not lib.callback.await('mri_Qbox:panel:isAdmin', false) then return end
    Mri.closePanel(data.embedded)
    local ok, spot = GetSafeCoordForPed(x, y, z, false, 32)
    local target = ok and spot or vec3(x, y, z)
    SetPedCoordsKeepVehicle(cache.ped, target.x, target.y, target.z)
end)

-- `toggle` flips it; without it the panel only asks the current state.
RegisterNUICallback('gatesDebug', function(data, cb)
    if type(data) == 'table' and data.toggle then
        debugOn = not debugOn
        if debugOn then startDebug() end
    end
    cb({ on = debugOn })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and LocalPlayer.state.escBusy then LocalPlayer.state:set('escBusy', false, false) end
end)
