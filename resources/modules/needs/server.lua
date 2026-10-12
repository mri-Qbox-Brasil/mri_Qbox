-- Read by qbx_core (mri/server/needs.lua) and mri_Qhud; no state means their own defaults.
local KEY = 'mri:needs'

Mri.lifecycle('needs', function(cfg)
    GlobalState[KEY] = {
        hunger = cfg.hunger ~= false,
        hungerRate = tonumber(cfg.hungerRate),
        thirst = cfg.thirst ~= false,
        thirstRate = tonumber(cfg.thirstRate),
        stress = cfg.stress ~= false,
    }
end, function()
    GlobalState[KEY] = nil
end)
