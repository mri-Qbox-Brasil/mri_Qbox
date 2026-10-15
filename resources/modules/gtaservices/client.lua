-- EnableDispatchService indexes: https://docs.fivem.net/natives/?_0xDC0F817884CDD856
local SERVICES = {
    police = { 1, 2, 4, 6, 7, 9, 10, 12, 13 },
    roadblock = { 8 },
    fire = { 3 },
    ambulance = { 5 },
    gangs = { 11, 15 },
    army = { 14 },
}

local function apply(cfg)
    for key, list in pairs(SERVICES) do
        for _, index in ipairs(list) do EnableDispatchService(index, cfg[key] == true) end
    end
    local police = cfg.police == true
    SetCreateRandomCops(police)
    SetCreateRandomCopsNotOnScenarios(police)
    SetCreateRandomCopsOnScenarios(police)
    DistantCopCarSirens(police)
    SetAudioFlag('PoliceScannerDisabled', not police)
    SetMaxWantedLevel(math.floor(tonumber(cfg.maxWantedLevel) or 0))
end

Mri.lifecycle('gtaservices', apply, function()
    apply({ police = true, roadblock = true, fire = true, ambulance = true, gangs = true, army = true, maxWantedLevel = 5 })
end)
