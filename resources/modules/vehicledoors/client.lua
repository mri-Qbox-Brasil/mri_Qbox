-- Open and close doors, hood and trunk; "Ver itens" on the storage lid opens the ox_inventory trunk
local DOORS = {
    { bone = 'door_dside_f', handle = 'handle_dside_f', index = 0, name = 'front_driver_door', icon = 'fa-solid fa-car-side' },
    { bone = 'door_pside_f', handle = 'handle_pside_f', index = 1, name = 'front_passenger_door', icon = 'fa-solid fa-car-side' },
    { bone = 'door_dside_r', handle = 'handle_dside_r', index = 2, name = 'rear_driver_door', icon = 'fa-solid fa-car-side' },
    { bone = 'door_pside_r', handle = 'handle_pside_r', index = 3, name = 'rear_passenger_door', icon = 'fa-solid fa-car-side' },
    { lid = 'bonnet', front = true, index = 4, name = 'hood', icon = 'fa-solid fa-car', distance = 2.0 },
    { lid = 'boot', front = false, index = 5, name = 'trunk', icon = 'fa-solid fa-car-rear', distance = 2.0 },
}

-- locked (2) and the other lock states (4 and up) block
local function unlocked(vehicle)
    local status = GetVehicleDoorLockStatus(vehicle)
    return status == 0 or status == 1
end

local function setDoor(vehicle, index, open)
    if not NetworkHasControlOfEntity(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local timeout = GetGameTimer() + 500
        while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < timeout do Wait(0) end
    end
    if open then
        SetVehicleDoorOpen(vehicle, index, false, false)
    else
        SetVehicleDoorShut(vehicle, index, false)
    end
end

-- door state read once per scan refresh, shared by its open and close options
local doorCache, doorCacheAt = {}, 0

local function doorState(vehicle, index)
    local now = GetGameTimer()
    if now - doorCacheAt > 50 then doorCache, doorCacheAt = {}, now end
    local key = vehicle * 8 + index
    local door = doorCache[key]
    if not door then
        local ok = unlocked(vehicle) and not IsVehicleDoorDamaged(vehicle, index) and GetIsDoorValid(vehicle, index)
        door = { usable = ok, open = ok and GetVehicleDoorAngleRatio(vehicle, index) > 0.0 }
        doorCache[key] = door
    end
    return door
end

local boneCache = {}

local function hasBone(vehicle, bone)
    local key = ('%d:%s'):format(GetEntityModel(vehicle), bone)
    local found = boneCache[key]
    if found == nil then
        found = GetEntityBoneIndexByName(vehicle, bone) ~= -1
        boneCache[key] = found
    end
    return found
end

-- meters from the bottom of the model box to where a hatch or trunk lid usually closes
local LATCH_HEIGHT <const> = 0.9
local lidCache = {}

-- the lid bone is the hinge: it only tells which end the lid is on and how high it sits
local function lidAnchor(lid, front)
    return function(vehicle)
        local model = GetEntityModel(vehicle)
        local key = ('%d:%s'):format(model, lid)
        local offset = lidCache[key]
        if offset then return offset end

        local min, max = GetModelDimensions(model)
        local middle = (min + max) / 2
        local y, z = front and max.y or min.y, middle.z
        local bone = GetEntityBoneIndexByName(vehicle, lid)
        if bone ~= -1 then
            local world = GetWorldPositionOfEntityBone(vehicle, bone)
            local hinge = GetOffsetFromEntityGivenWorldCoords(vehicle, world.x, world.y, world.z)
            -- rear-engine cars carry the boot in front: follow the hinge, not the lid name
            local edge = hinge.y > middle.y and max.y or min.y
            local latch = math.min(hinge.z, min.z + LATCH_HEIGHT)
            y, z = (hinge.y + edge) / 2, (hinge.z + latch) / 2
        end

        offset = vec3(middle.x, y, z)
        lidCache[key] = offset
        return offset
    end
end

-- ox_inventory's own rules for which lid holds the storage, read once
local storageData

local function storageLid(vehicle)
    if GetResourceState('ox_inventory') ~= 'started' or not NetworkGetEntityIsNetworked(vehicle) then return end
    if storageData == nil then
        local ok, data = pcall(lib.load, '@ox_inventory.data.vehicles')
        storageData = ok and type(data) == 'table' and data or false
    end
    if not storageData then return end
    local model, class = GetEntityModel(vehicle), GetVehicleClass(vehicle)
    local storage = storageData.Storage[model]
    if storage == 0 or storage == 1 then return end
    if not storageData.trunk[class] and not storageData.trunk.models[model] then return end
    return storage and 4 or 5
end

local function openStorage(vehicle, index)
    local coords = GetEntityCoords(vehicle)
    TaskTurnPedToFaceCoord(cache.ped, coords.x, coords.y, coords.z, 0)
    local data = { netid = NetworkGetNetworkIdFromEntity(vehicle), entityid = vehicle, door = index }
    if exports.ox_inventory:openInventory('trunk', data) then setDoor(vehicle, index, true) end
end

local names = {}

local function build(cfg)
    local options = {}
    local function add(option)
        names[#names + 1] = option.name
        options[#options + 1] = option
    end

    for _, door in ipairs(DOORS) do
        -- the door bone is the hinge: anchor on the handle, hinge only for models without one
        local anchors = door.handle and { door.handle, door.bone } or { false }
        local anchor = door.lid and lidAnchor(door.lid, door.front)
        for _, open in ipairs({ true, false }) do
            for i, bone in ipairs(anchors) do
                local hingeFallback = door.handle and bone == door.bone
                add({
                    name = ('mri_%s_%s_%d'):format(open and 'open' or 'close', door.name, i),
                    label = open and 'Abrir' or 'Fechar',
                    icon = door.icon,
                    bones = bone and { bone } or nil,
                    anchor = anchor,
                    distance = door.distance or 1.5,
                    canInteract = function(vehicle)
                        if hingeFallback and hasBone(vehicle, door.handle) then return false end
                        local current = doorState(vehicle, door.index)
                        return current.usable and current.open ~= open
                    end,
                    onSelect = function(data)
                        setDoor(data.entity, door.index, open)
                    end,
                })
            end
        end
        if door.lid and cfg.trunkItems then
            add({
                name = ('mri_items_%s'):format(door.name),
                label = 'Ver itens',
                icon = 'fa-solid fa-box-open',
                anchor = anchor,
                -- ox_inventory only keeps the trunk open within 1.5 m of the car's end
                distance = 1.5,
                canInteract = function(vehicle)
                    return not cache.vehicle and storageLid(vehicle) == door.index and doorState(vehicle, door.index).usable
                end,
                onSelect = function(data)
                    openStorage(data.entity, door.index)
                end,
            })
        end
    end
    return options
end

Mri.lifecycle('vehicledoors', function(cfg)
    names = {}
    exports.ox_target:addGlobalVehicle(build(cfg))
end, function()
    exports.ox_target:removeGlobalVehicle(names)
end)
