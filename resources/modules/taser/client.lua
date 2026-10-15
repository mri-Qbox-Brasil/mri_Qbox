-- The ground time is a ped setting read on the next stun, so it is drawn again after every hit taken.
local function roll(ped)
    local cfg = Mri.cfg('taser')
    local low = math.floor((tonumber(cfg.minSeconds) or 4) * 1000)
    local high = math.max(low, math.floor((tonumber(cfg.maxSeconds) or 7) * 1000))
    SetPedMinGroundTimeForStungun(ped, math.random(low, high))
end

lib.onCache('ped', function(ped)
    if Mri.enabled('taser') then roll(ped) end
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' or args[1] ~= cache.ped or not Mri.enabled('taser') then return end
    roll(cache.ped)
end)

-- the game has no getter for its default, so turning the module off keeps the last value until the ped changes
Mri.lifecycle('taser', function()
    roll(cache.ped)
end, function() end)
