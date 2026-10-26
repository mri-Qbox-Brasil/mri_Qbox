-- EnableDispatchService indexes: https://docs.fivem.net/natives/?_0xDC0F817884CDD856
-- The police ones are in the gtapolice module.
local SERVICES = {
    fire = { 3 },
    ambulance = { 5 },
    gangs = { 11, 15 },
    army = { 14 },
}

local function apply(cfg)
    for key, list in pairs(SERVICES) do
        for _, index in ipairs(list) do EnableDispatchService(index, cfg[key] == true) end
    end
end

Mri.lifecycle('gtaservices', apply, function()
    apply({ fire = true, ambulance = true, gangs = true, army = true })
end)
