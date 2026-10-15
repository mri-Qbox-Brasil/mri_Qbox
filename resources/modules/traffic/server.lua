-- Writes the popgroups the clients load from the next server start: the MRI list plus what the panel turned on, minus what it turned off.
-- Parked cars pick from these groups and ignore model suppression, so only this file keeps unlisted cars out of parking lots.

local BASE = 'resources/modules/traffic/popgroups.xml'
local OUT = 'data/popgroups.xml'
local GROUPS = require 'resources.modules.traffic.groups'
local VANILLA = require 'resources.modules.traffic.vanilla'
local ITEM = '        <Item>\n          <Name>%s</Name>\n          <Variations type="NULL" />\n        </Item>'

---@param on table<string, true>
local function write(on)
    local resource = GetCurrentResourceName()
    local xml = LoadResourceFile(resource, BASE)
    if not xml then return end
    for _, group in ipairs(GROUPS) do
        local items = {}
        for _, model in ipairs(group.models) do
            if on[model[1]] then items[#items + 1] = ITEM:format(model[1]) end
        end
        local _, nameEnd = xml:find(('<Name>%s</Name>'):format(group.id), 1, true)
        local _, open = nameEnd and xml:find('<models>', nameEnd, true)
        local close = open and xml:find('</models>', open, true)
        if close then
            local body = #items > 0 and '\n' .. table.concat(items, '\n') .. '\n      ' or '\n      '
            xml = xml:sub(1, open) .. body .. xml:sub(close)
        end
    end
    if LoadResourceFile(resource, OUT) ~= xml then SaveResourceFile(resource, OUT, xml, -1) end
end

Mri.lifecycle('traffic', function(cfg)
    local on = {}
    for _, model in ipairs(cfg.models or {}) do on[model] = true end
    write(on)
end, function()
    local on = {}
    for _, model in ipairs(VANILLA) do on[model] = true end
    write(on)
end)
