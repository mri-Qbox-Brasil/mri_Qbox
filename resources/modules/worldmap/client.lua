local applied

local function each(list, fn)
    for _, value in ipairs(type(list) == 'table' and list or {}) do fn(value) end
end

local function apply(cfg, on)
    DisableIdleCamera(on and cfg.disableIdleCamera == true)
    DisableVehiclePassengerIdleCamera(on and cfg.disableIdleCamera == true)
    if on and cfg.disableAmbience then
        StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
    else
        StopAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
    end
    SetGarbageTrucks(not on or cfg.garbageTrucks == true)
    SetFarDrawVehicles(not on)
    each(cfg.scenarioTypes, function(name) SetScenarioTypeEnabled(name, not on) end)
    each(cfg.scenarioGroups, function(name) SetScenarioGroupEnabled(name, not on) end)
    each(cfg.suppressedModels, function(name) SetVehicleModelIsSuppressed(joaat(name), on) end)
    each(cfg.disabledEmitters, function(name) SetStaticEmitterEnabled(name, not on) end)
end

-- qbx_ignore set the scenarios and models again every 10 seconds
local function reapply(cfg)
    each(cfg.scenarioTypes, function(name) SetScenarioTypeEnabled(name, false) end)
    each(cfg.suppressedModels, function(name) SetVehicleModelIsSuppressed(joaat(name), true) end)
    each(cfg.scenarioGroups, function(name) SetScenarioGroupEnabled(name, false) end)
end

CreateThread(function()
    while true do
        Wait(10000)
        if applied then reapply(applied) end
    end
end)

Mri.lifecycle('worldmap', function(cfg)
    applied = cfg
    apply(cfg, true)
end, function()
    if applied then apply(applied, false) end
    applied = nil
end)

-- /staticemitters (from qbx_staticemitters): admin menu of the map sound emitters, by interior; picking one teleports there.
local EMITTERS = require 'resources.modules.worldmap.emitters'

local function emitterDisabled(name)
    for _, value in ipairs(applied and applied.disabledEmitters or {}) do
        if value == name then return true end
    end
    return false
end

local function drawLabel(coords, text)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z + 0.6)
    if not onScreen then return end
    SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function drawNearby()
    CreateThread(function()
        while lib.getOpenMenu() do
            local here = GetEntityCoords(cache.ped)
            for _, list in pairs(EMITTERS) do
                for i = 1, #list do
                    local name, pos = list[i][1], list[i][2]
                    if #(here - pos) < 200.0 then
                        local off = emitterDisabled(name)
                        DrawMarker(28, pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, off and 255 or 50, off and 50 or 255, 50, 100, false, false, 0, true, false, false, false)
                        drawLabel(pos, name)
                    end
                end
            end
            Wait(0)
        end
    end)
end

local menusBuilt = false
local function buildMenus()
    local groups = {}
    for group in pairs(EMITTERS) do groups[#groups + 1] = group end
    table.sort(groups)

    local options = {}
    for i, group in ipairs(groups) do
        options[i] = { label = group, description = ('%d sons'):format(#EMITTERS[group]), icon = 'folder' }
    end
    lib.registerMenu({ id = 'mri_static_emitters', title = 'Sons fixos do mapa', position = 'top-right', options = options }, function(selected)
        local group = groups[selected]
        if not group then return end
        local list = EMITTERS[group]
        local entries = {}
        for i = 1, #list do
            local pos = list[i][2]
            entries[i] = {
                label = list[i][1],
                description = ('%s | %.2f, %.2f, %.2f'):format(emitterDisabled(list[i][1]) and 'DESLIGADO' or 'ligado', pos.x, pos.y, pos.z),
                icon = emitterDisabled(list[i][1]) and 'toggle-off' or 'toggle-on',
            }
        end
        lib.registerMenu({
            id = 'mri_static_emitters_group',
            title = group,
            position = 'top-right',
            options = entries,
            onClose = function() lib.showMenu('mri_static_emitters') end,
        }, function(index)
            local pos = list[index] and list[index][2]
            if not pos then return end
            lib.setClipboard(('%.2f, %.2f, %.2f'):format(pos.x, pos.y, pos.z))
            SetEntityCoords(cache.ped, pos.x, pos.y, pos.z, true, false, false, false)
        end)
        lib.showMenu('mri_static_emitters_group')
    end)
    menusBuilt = true
end

RegisterCommand('staticemitters', function()
    if not Mri.enabled('worldmap') or not lib.callback.await('mri_Qbox:worldmap:isAdmin', false) then return end
    if not menusBuilt then buildMenus() end
    lib.showMenu('mri_static_emitters', 1)
    drawNearby()
end, false)
