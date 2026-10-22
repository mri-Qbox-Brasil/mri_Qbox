-- Enter through the door you aim at, into that door's seat; dealership cars (isVehicleShopEntity) refuse
local DOORS = {
    { name = 'driverF', seat = -1, index = 0, bones = { 'handle_dside_f', 'door_dside_f', 'seat_dside_f' } },
    { name = 'passengerF', seat = 0, index = 1, bones = { 'handle_pside_f', 'door_pside_f', 'seat_pside_f' } },
    { name = 'driverR', seat = 1, index = 2, bones = { 'handle_dside_r', 'door_dside_r', 'seat_dside_r' } },
    { name = 'passengerR', seat = 2, index = 3, bones = { 'handle_pside_r', 'door_pside_r', 'seat_pside_r' } },
}

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

-- same spot as mri_Qinteract's door options: the handle, the hinge without one; the seat when the door is open, torn off or missing
local function anchorOf(vehicle, door)
    local seat = door.bones[3]
    local open = GetVehicleDoorAngleRatio(vehicle, door.index) > 0.0 or IsVehicleDoorDamaged(vehicle, door.index)
    if open and hasBone(vehicle, seat) then return seat end
    for _, bone in ipairs(door.bones) do
        if hasBone(vehicle, bone) then return bone end
    end
end

local function enter(vehicle, seat)
    local isVehicleShopEntity = Entity(vehicle).state.isVehicleShopEntity
    if isVehicleShopEntity and isVehicleShopEntity ~= "" then
        exports.qbx_core:Notify("Você não pode entrar em carros da concessionária")
        return
    end
    TaskEnterVehicle(cache.ped, vehicle, 10000, seat, 1.0, 1, 0)
end

local options, OPTIONS = {}, {}
for _, door in ipairs(DOORS) do
    for i, bone in ipairs(door.bones) do
        local name = ('mri_enter_%s_%d'):format(door.name, i)
        OPTIONS[#OPTIONS + 1] = name
        options[#options + 1] = {
            name = name,
            icon = 'fa-solid fa-right-to-bracket',
            label = 'Entrar',
            bones = { bone },
            distance = 2,
            canInteract = function(vehicle)
                if cache.vehicle or anchorOf(vehicle, door) ~= bone then return false end
                return door.seat < GetVehicleMaxNumberOfPassengers(vehicle) and IsVehicleSeatFree(vehicle, door.seat)
            end,
            onSelect = function(data)
                enter(data.entity, door.seat)
            end,
        }
    end
end

Mri.lifecycle('entervehicle', function()
    exports.ox_target:addGlobalVehicle(options)
end, function()
    exports.ox_target:removeGlobalVehicle(OPTIONS)
end)
