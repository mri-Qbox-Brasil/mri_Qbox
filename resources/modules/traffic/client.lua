-- Ambient traffic: popgroups with the MRI list plus vanilla and DLC cars; the panel suppresses what is off.

local FILE = 'resources/modules/traffic/popgroups.xml'

---@type string[]
local ALL = {}
for _, group in ipairs(require 'resources.modules.traffic.groups') do
    for _, model in ipairs(group.models) do ALL[#ALL + 1] = model[1] end
end

local running, overridden = false, false
---@type table<integer, true>
local suppressed = {}

local function restore()
    for hash in pairs(suppressed) do SetVehicleModelIsSuppressed(hash, false) end
    suppressed = {}
    if overridden then
        OverridePopGroups(nil)
        overridden = false
    end
end

Mri.lifecycle('traffic', function(cfg)
    running = true
    if not overridden then
        OverridePopGroups(FILE)
        overridden = true
    end
    local on = {}
    for _, model in ipairs(cfg.models or {}) do on[model] = true end
    for i = 1, #ALL do
        local hash = joaat(ALL[i])
        local off = not on[ALL[i]]
        if off ~= (suppressed[hash] == true) then
            SetVehicleModelIsSuppressed(hash, off)
            suppressed[hash] = off or nil
        end
    end
end, function()
    running = false
    if GetResourceState(GetCurrentResourceName()) == 'stopping' then return restore() end
    -- a field change runs start right after stop: keep the file loaded unless the module really went off
    SetTimeout(0, function()
        if not running then restore() end
    end)
end)
