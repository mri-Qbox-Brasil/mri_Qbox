-- EnableDispatchService indexes: https://docs.fivem.net/natives/?_0xDC0F817884CDD856
local POLICE_SERVICES = { 1, 2, 4, 6, 7, 9, 10, 12, 13 }
local ROADBLOCK_SERVICE = 8
local SCENARIOS = { 'WORLD_VEHICLE_POLICE_BIKE', 'WORLD_VEHICLE_POLICE_CAR', 'WORLD_VEHICLE_POLICE', 'WORLD_VEHICLE_POLICE_NEXT_TO_CAR' }
-- https://docs.fivem.net/natives/?_0x6806C51AD12B83B8
local WANTED_STARS = 1

local GTA_DEFAULTS = { police = true, roadblock = true, parkedCars = true, maxWantedLevel = 5, hideWanted = false, respectPlayer = false }

local scenariosOff = false

local function setScenarios(on)
    for _, name in ipairs(SCENARIOS) do SetScenarioTypeEnabled(name, on) end
end

local function apply(cfg)
    local police = cfg.police == true
    for _, index in ipairs(POLICE_SERVICES) do EnableDispatchService(index, police) end
    EnableDispatchService(ROADBLOCK_SERVICE, cfg.roadblock == true)
    SetCreateRandomCops(police)
    SetCreateRandomCopsNotOnScenarios(police)
    SetCreateRandomCopsOnScenarios(police)
    -- true loops a fake distant siren forever; real police cars still play their own
    DistantCopCarSirens(false)
    SetAudioFlag('PoliceScannerDisabled', not police)
    SetMaxWantedLevel(math.floor(tonumber(cfg.maxWantedLevel) or 0))

    scenariosOff = cfg.parkedCars ~= true
    setScenarios(not scenariosOff)

    if cfg.respectPlayer then
        SetRelationshipBetweenGroups(1, `COP`, `PLAYER`)
    else
        ClearRelationshipBetweenGroups(1, `COP`, `PLAYER`)
    end

    if cfg.hideWanted then
        SetHudComponentSize(WANTED_STARS, 0.0, 0.0)
    else
        ResetHudComponentValues(WANTED_STARS)
    end
end

-- same as the worldmap module: the scenarios are set off again every 10 seconds
CreateThread(function()
    while true do
        Wait(10000)
        if scenariosOff then setScenarios(false) end
    end
end)

Mri.lifecycle('gtapolice', apply, function()
    apply(GTA_DEFAULTS)
end)
