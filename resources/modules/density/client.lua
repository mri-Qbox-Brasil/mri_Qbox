-- Population density, NPC relationships and car generators (ex qbx_density, without its stream/).

local function oldResourceRunning()
    for i = 0, GetNumResources() - 1 do
        if GetResourceByFindIndex(i) == 'qbx_density' then
            local state = GetResourceState('qbx_density')
            return state == 'started' or state == 'starting'
        end
    end
    return false
end

if oldResourceRunning() then
    print('^1[mri_Qbox] o qbx_density está rodando: a densidade agora faz parte do mri_Qbox. Tire o qbx_density do servidor.^7')
    return
end

local RESPECT_GROUPS = {
    `AMBIENT_GANG_HILLBILLY`, `AMBIENT_GANG_BALLAS`, `AMBIENT_GANG_MEXICAN`, `AMBIENT_GANG_FAMILY`,
    `AMBIENT_GANG_MARABUNTE`, `AMBIENT_GANG_SALVA`, `AMBIENT_GANG_LOST`, `GANG_1`, `GANG_2`, `GANG_9`,
    `GANG_10`, `FIREMAN`, `MEDIC`, `COP`, `PRISONER`,
}

-- Boxes around the car generators the qbx_density ymaps replaced (min x, y, z, max x, y, z)
local GENERATOR_AREAS = {
    { -1627.0, -3543.0, -10.0, -907.0, -2349.0, 60.0 }, -- LSIA
    { -2475.0, 2816.0, 10.0, -1758.0, 3386.0, 60.0 },   -- Fort Zancudo
    { 2415.0, -446.0, 70.0, 2595.0, -247.0, 120.0 },    -- Palomino Highlands
    { 685.0, 4105.0, 10.0, 1033.0, 4226.0, 60.0 },      -- Alamo Sea, north shore
}

local EXPORT_KEYS = { parked = 'parked', vehicle = 'vehicle', randomvehicles = 'randomVehicles', peds = 'peds', scenario = 'scenario' }

---@type table<string, number>
local overrides = {}
local generation = 0

local function setGenerators(active)
    for i = 1, #GENERATOR_AREAS do
        local a = GENERATOR_AREAS[i]
        SetAllVehicleGeneratorsActiveInArea(a[1], a[2], a[3], a[4], a[5], a[6], active, false)
        if not active then RemoveVehiclesFromGeneratorsInArea(a[1], a[2], a[3], a[4], a[5], a[6], 0) end
    end
end

local function setRespect(on)
    for i = 1, #RESPECT_GROUPS do
        if on then
            SetRelationshipBetweenGroups(1, RESPECT_GROUPS[i], `PLAYER`)
        else
            ClearRelationshipBetweenGroups(1, RESPECT_GROUPS[i], `PLAYER`)
        end
    end
end

local blocked, respecting = false, false

Mri.lifecycle('density', function(cfg)
    generation = generation + 1
    local current = generation

    respecting = cfg.npcRespect == true
    if respecting then setRespect(true) end
    blocked = cfg.blockGenerators == true
    if blocked then setGenerators(false) end

    local empty = cfg.empty == true
    local function value(key) return empty and 0 or overrides[key] or cfg[key] end

    -- the multipliers only last one frame
    CreateThread(function()
        while generation == current do
            SetParkedVehicleDensityMultiplierThisFrame(value('parked'))
            SetVehicleDensityMultiplierThisFrame(value('vehicle'))
            SetRandomVehicleDensityMultiplierThisFrame(value('randomVehicles'))
            SetPedDensityMultiplierThisFrame(value('peds'))
            local scenario = value('scenario')
            SetScenarioPedDensityMultiplierThisFrame(scenario, scenario)
            Wait(0)
        end
    end)
end, function()
    generation = generation + 1
    if respecting then setRespect(false) end
    if blocked then setGenerators(true) end
    respecting, blocked = false, false
end)

-- qbx_density export; nil returns the value to the panel's
---@param kind 'parked'|'vehicle'|'randomvehicles'|'peds'|'scenario'
---@param value number?
local function setDensity(kind, value)
    local key = EXPORT_KEYS[kind]
    if key then overrides[key] = tonumber(value) end
end

exports('SetDensity', setDensity)
