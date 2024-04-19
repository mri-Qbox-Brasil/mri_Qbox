local function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local categoryNames = {
    [0] = 'compacts',
    [1] = 'sedans',
    [2] = 'suvs',
    [3] = 'coupes',
    [4] = 'muscle',
    [5] = 'sportsclassics',
    [6] = 'sports',
    [7] = 'super',
    [8] = 'motorcycles',
    [9] = 'offroad',
    [10] = 'industrial',
    [11] = 'utility',
    [12] = 'vans',
    [13] = 'cycles',
    [14] = 'boats',
    [15] = 'helicopters',
    [16] = 'planes',
    [17] = 'service',
    [18] = 'emergency',
    [19] = 'military',
    [20] = 'commercial',
    [21] = 'trains',
    [22] = 'openwheel'
}


local vehicleFormat = [[
{
    model = %q,
    name = %q,
    brand = %q,
    price = %s,
    category = %q,
    type = %q,
    shop = %q,
},
]]

local function insertPdm(vType)
    return vType == 'automobile' or vType == 'bike' or vType == 'bicycle'
end

local QBCore = exports['qb-core']:GetCoreObject()

lib.callback.register('Renewed-Vehicleparser:client:parsevehicles', function(processAll)
    local models = GetAllVehicleModels()
    local numModels = #models
    local numParsed = 0
    local coords = GetEntityCoords(cache.ped)
    local vehicleData = {}
    local topStats = {}

    SetPlayerControl(cache.playerId, false, 1 << 8)

    lib.notify({
        title = 'Generating vehicle data',
        description = ('%d models loaded.'):format(numModels),
        type = 'info'
    })

    for i = 1, numModels do
        local model = models[i]:lower()

        if processAll or not QBCore.Shared.Vehicles[model] then
            local success, hash = pcall(lib.requestModel, model)

            if success and hash then
                local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z + 10, 0.0, false, false)
                local make = GetMakeNameFromVehicleModel(hash)

                if make == '' then
                    local make2 = GetMakeNameFromVehicleModel(model:gsub('%A', ''))

                    if make2 ~= 'CARNOTFOUND' then
                        make = make2
                    end
                end

                SetPedIntoVehicle(cache.ped, vehicle, -1)

                local class = GetVehicleClass(vehicle)
                local vType

                if IsThisModelACar(hash) then
                    vType = 'automobile'
                elseif IsThisModelABicycle(hash) then
                    vType = 'bicycle'
                elseif IsThisModelABike(hash) then
                    vType = 'bike'
                elseif IsThisModelABoat(hash) then
                    vType = 'boat'
                elseif IsThisModelAHeli(hash) then
                    vType = 'heli'
                elseif IsThisModelAPlane(hash) then
                    vType = 'plane'
                elseif IsThisModelAQuadbike(hash) then
                    vType = 'quadbike'
                elseif IsThisModelATrain(hash) then
                    vType = 'train'
                else
                    vType = (class == 5 and 'submarinecar') or (class == 14 and 'submarine') or (class == 16 and 'blimp') or 'trailer'
                end

                local data = {
                    name = GetLabelText(GetDisplayNameFromVehicleModel(hash)),
                    make = make == '' and make or GetLabelText(make),
                    class = class,
                    seats = GetVehicleModelNumberOfSeats(hash),
                    weapons = DoesVehicleHaveWeapons(vehicle) or nil,
                    doors = GetNumberOfVehicleDoors(vehicle),
                    type = vType,
                }

                local stats = {
                    braking = round(GetVehicleModelMaxBraking(hash), 4),
                    acceleration = round(GetVehicleModelAcceleration(hash), 4),
                    speed = round(GetVehicleModelEstimatedMaxSpeed(hash), 4),
                    handling = round(GetVehicleModelEstimatedAgility(hash), 4),
                }

                local math = lib.math

                if vType ~= 'trailer' and vType ~= 'train' then
                    local vGroup = (vType == 'heli' or vType == 'plane' or vType == 'blimp') and 'air' or (vType == 'boat' or vType == 'submarine') and 'sea' or
                        'land'
                    local topTypeStats = topStats[vGroup]

                    if not topTypeStats then
                        topStats[vGroup] = {}
                        topTypeStats = topStats[vGroup]
                    end

                    for k, v in pairs(stats) do
                        if not topTypeStats[k] or v > topTypeStats[k] then
                            topTypeStats[k] = v
                        end

                        data[k] = v
                    end
                end

                -- super arbitrary and unbalanced vehicle pricing algorithm
                local price = stats.braking + stats.acceleration + stats.speed + stats.handling

                local banned = false

                if GetVehicleHasKers(vehicle) then price *= 1.2 banned = true end
                if GetCanVehicleJump(vehicle) then price *= 1.5 banned = true end
                if GetVehicleHasParachute(vehicle) then price *= 1.5 banned = true end
                if GetHasRocketBoost(vehicle) then price *= 3 banned = true end
                if data.weapons then price *= 5 banned = true end

                if vType == 'automobile' then
                    price *= 1600
                elseif vType == 'bicycle' then
                    price *= 150
                elseif vType == 'bike' then
                    price *= 500
                elseif vType == 'boat' then
                    price *= 6000
                elseif vType == 'heli' then
                    price *= 90000
                elseif vType == 'plane' then
                    price *= 16000
                elseif vType == 'quadbike' then
                    price *= 600
                elseif vType == 'train' then
                    price *= 6000
                elseif vType == 'submarinecar' then
                    price *= 18000
                elseif vType == 'submarine' then
                    price *= 17200
                elseif vType == 'blimp' then
                    price *= 12000
                elseif vType == 'trailer' then
                    price *= 10000
                end

                if IsThisModelAnAmphibiousCar(hash) then
                    data.type = 'amphibious_automobile'
                    price *= 4
                elseif IsThisModelAnAmphibiousQuadbike(hash) then
                    data.type = 'amphibious_quadbike'
                    price *= 4
                end

                local itemStr = vehicleFormat:format(model, data.name, data.make, math.floor(price), categoryNames[GetVehicleClass(vehicle)] or "none", vType, not banned and insertPdm(vType) and 'pdm' or 'none' )

                numParsed += 1
                vehicleData[numParsed] = itemStr

                SetVehicleAsNoLongerNeeded(vehicle)
                DeleteEntity(vehicle)
                SetModelAsNoLongerNeeded(hash)
                SetEntityCoordsNoOffset(cache.ped, coords.x, coords.y, coords.z, false, false, false)

                print(model)
            end
        end
    end

    lib.notify({
        title = 'Generated vehicle data',
        description = ('Generated new vehicle data for %d/%d models'):format(numParsed, numModels),
        type = 'success'
    })

    SetPlayerControl(cache.playerId, true, 0)

    return vehicleData, topStats
end)
