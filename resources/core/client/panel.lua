-- Painel de config no client: abre a NUI (/mriqbox) e repassa as chamadas dela
-- pro server. Embutido no mri_Qadmin, a NUI chama os mesmos callbacks pelo iframe.

local QADMIN_PLUGIN_ID = 'mriqbox'
local panelOpen = false

local function accentColor()
    local color = GetConvar('mri:color', '')
    return color ~= '' and color or '#00E699'
end

RegisterCommand('mriqbox', function()
    if panelOpen then return end
    if not lib.callback.await('mri_Qbox:panel:isAdmin', false) then
        lib.notify({ type = 'error', description = 'Você não tem permissão para o painel do mri_Qbox.' })
        return
    end
    panelOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openPanel' })
end, false)

RegisterNUICallback('panelGet', function(_, cb)
    local modules = lib.callback.await('mri_Qbox:panel:get', false)
    cb({ success = modules ~= false, modules = modules or {} })
end)

RegisterNUICallback('panelSave', function(data, cb)
    if type(data) ~= 'table' then return cb({ success = false }) end
    local ok, result = lib.callback.await('mri_Qbox:panel:save', false, data.id, data.values)
    cb({ success = ok == true, modules = ok and result or nil, message = not ok and result or nil })
end)

RegisterNUICallback('panelClose', function(data, cb)
    cb({ success = true })
    if type(data) == 'table' and data.embedded then
        if GetResourceState('mri_Qadmin') == 'started' then
            pcall(function() exports['mri_Qadmin']:ClosePlugin(QADMIN_PLUGIN_ID) end)
        end
        return
    end
    panelOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closePanel' })
end)

-- Tema da suíte (THEMING.md do @mriqbox/ui-kit): convars e /uiconfig do ox_lib.
RegisterNUICallback('getConfig', function(_, cb)
    cb({ accentColor = accentColor(), backgroundColor = GetConvar('mri:backgroundColor', '') })
end)

RegisterNUICallback('getUiConfig', function(_, cb)
    if GetResourceState('ox_lib') ~= 'started' then return cb(false) end
    local ok, cfg = pcall(function() return exports.ox_lib:getUiConfig() end)
    cb(ok and type(cfg) == 'table' and cfg or false)
end)

RegisterNetEvent('mri_Qbox:accentColorChanged', function(color)
    SendNUIMessage({ action = 'updateAccentColor', data = { accentColor = color } })
end)

RegisterNetEvent('mri_Qbox:backgroundColorChanged', function(color)
    SendNUIMessage({ action = 'updateBackgroundColor', data = { backgroundColor = color or '' } })
end)

RegisterNetEvent('ox_lib:uiConfigChanged', function(cfg)
    if type(cfg) ~= 'table' then return end
    SendNUIMessage({ action = 'applyUiConfig', data = cfg })
end)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() and panelOpen then
        SetNuiFocus(false, false)
    end
end)
