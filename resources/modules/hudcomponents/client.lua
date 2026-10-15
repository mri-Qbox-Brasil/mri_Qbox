-- Components are hidden once by size; controls and the crosshair need every frame.

-- https://docs.fivem.net/natives/?_0x6806C51AD12B83B8
local COMPONENTS = {
    hideWanted = { 1 },
    hideCash = { 3, 4, 13 },
    hideLocation = { 7, 9 },
    hideVehicleInfo = { 6, 8 },
    hideWeapon = { 2, 19, 20, 21, 22 },
}

-- what the qbx_hudcomponents exports add and remove at runtime
local extraComponents = {}
local disableControls = { 37 }
local displayAmmo

local hidden = {}
local active

local function crosshair()
    local token = {}
    active = token
    CreateThread(function()
        while active == token do
            if not IsFirstPersonAimCamActive() then HideHudComponentThisFrame(14) end
            Wait(0)
        end
    end)
end

local function refreshCrosshair(weapon)
    if weapon and Mri.enabled('hudcomponents') and Mri.cfg('hudcomponents').hideCrosshair then
        crosshair()
    else
        active = nil
    end
end

lib.onCache('weapon', refreshCrosshair)

CreateThread(function()
    while true do
        if Mri.enabled('hudcomponents') then
            for i = 1, #disableControls do DisableControlAction(2, disableControls[i], true) end
            Wait(0)
        else
            Wait(1000)
        end
    end
end)

local function hide(id)
    SetHudComponentSize(id, 0.0, 0.0)
    hidden[#hidden + 1] = id
end

local function list(value)
    if type(value) == 'number' then return { value } end
    if type(value) == 'table' then return value end
    return {}
end

local function contains(tbl, value)
    for i = 1, #tbl do
        if tbl[i] == value then return i end
    end
end

Mri.lifecycle('hudcomponents', function(cfg)
    for key, ids in pairs(COMPONENTS) do
        if cfg[key] then
            for _, id in ipairs(ids) do hide(id) end
        end
    end
    for _, id in ipairs(extraComponents) do hide(id) end
    refreshCrosshair(cache.weapon)
end, function()
    for _, id in ipairs(hidden) do ResetHudComponentValues(id) end
    hidden = {}
    active = nil
end)

-- exports of qbx_hudcomponents, answered under the old resource name
local function addDisableHudComponents(value)
    for _, id in ipairs(list(value)) do
        extraComponents[#extraComponents + 1] = id
        if Mri.enabled('hudcomponents') then hide(id) end
    end
end

local function removeDisableHudComponents(value)
    for _, id in ipairs(list(value)) do
        local index = contains(extraComponents, id)
        if index then
            table.remove(extraComponents, index)
            ResetHudComponentValues(id)
        end
    end
end

local function addDisableControls(value)
    for _, control in ipairs(list(value)) do disableControls[#disableControls + 1] = control end
end

local function removeDisableControls(value)
    for _, control in ipairs(list(value)) do
        local index = contains(disableControls, control)
        if index then table.remove(disableControls, index) end
    end
end

local LEGACY = {
    AddDisableHudComponents = addDisableHudComponents,
    RemoveDisableHudComponents = removeDisableHudComponents,
    GetDisableHudComponents = function() return extraComponents end,
    AddDisableControls = addDisableControls,
    RemoveDisableControls = removeDisableControls,
    GetDisableControls = function() return disableControls end,
    SetDisplayAmmo = function(value) displayAmmo = value end,
    GetDisplayAmmo = function() return displayAmmo end,
}

for name, fn in pairs(LEGACY) do
    for _, exportName in ipairs({ name, name:sub(1, 1):lower() .. name:sub(2) }) do
        AddEventHandler(('__cfx_export_qbx_smallresources_%s'):format(exportName), function(setCB) setCB(fn) end)
    end
end
