-- Blocked models are cancelled before the entity exists (needs the bucket lockdown off, as the base ships).
local blocked = {}

AddEventHandler('entityCreating', function(entity)
    if blocked[GetEntityModel(entity)] then CancelEvent() end
end)

Mri.lifecycle('anticheat', function(cfg)
    blocked = {}
    for _, name in ipairs(cfg.blockedModels or {}) do blocked[joaat(name)] = true end
end, function()
    blocked = {}
end)
