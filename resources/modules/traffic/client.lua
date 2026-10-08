-- Ambient traffic: popgroups with the MRI list plus vanilla and DLC cars; the panel suppresses what is off.

local FILE = 'resources/modules/traffic/popgroups.xml'
-- Reloading popgroups wipes every car around, the one the player drives included: load once per session.
local STATE = 'mriTrafficPopgroups'

---@type string[]
local ALL = {}
for _, group in ipairs(require 'resources.modules.traffic.groups') do
    for _, model in ipairs(group.models) do ALL[#ALL + 1] = model[1] end
end

---@type table<string, true>
local VANILLA = {}
for _, model in ipairs(require 'resources.modules.traffic.vanilla') do VANILLA[model] = true end

-- nil until the first apply: flags set before a resource restart are unknown, so that one sets them all
---@type table<integer, boolean>?
local suppressed

---@param on table<string, true>
local function apply(on)
    local known = suppressed
    suppressed = {}
    for i = 1, #ALL do
        local hash = joaat(ALL[i])
        local off = not on[ALL[i]]
        if not known or known[hash] ~= off then SetVehicleModelIsSuppressed(hash, off) end
        suppressed[hash] = off
    end
end

Mri.lifecycle('traffic', function(cfg)
    if not LocalPlayer.state[STATE] then
        OverridePopGroups(FILE)
        LocalPlayer.state:set(STATE, true, false)
    end
    local on = {}
    for _, model in ipairs(cfg.models or {}) do on[model] = true end
    apply(on)
end, function()
    -- the MRI file stays loaded; off means only the cars GTA itself would spawn
    apply(VANILLA)
end)
