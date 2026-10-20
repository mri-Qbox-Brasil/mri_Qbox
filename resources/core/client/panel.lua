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
    Mri.focus('panel', true)
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

---@param embedded? boolean the panel is the mri_Qadmin tab
function Mri.closePanel(embedded)
    if embedded then
        if GetResourceState('mri_Qadmin') == 'started' then
            pcall(function() exports['mri_Qadmin']:ClosePlugin(QADMIN_PLUGIN_ID) end)
        end
        return
    end
    panelOpen = false
    Mri.focus('panel', false)
    SendNUIMessage({ action = 'closePanel' })
end

-- Hides the panel while a world tool runs and brings it back with the draft; returns what the tool returns.
---@param embedded? boolean
---@param tool fun(): any
function Mri.panelInWorld(embedded, tool)
    local fromAdmin = embedded == true and GetResourceState('mri_Qadmin') == 'started'
    if fromAdmin then
        pcall(function() exports['mri_Qadmin']:ClosePlugin(QADMIN_PLUGIN_ID) end)
    else
        Mri.focus('panel', false)
        SendNUIMessage({ action = 'placing', data = true })
    end
    local ok, result = pcall(tool)
    if fromAdmin then
        pcall(function() exports['mri_Qadmin']:OpenPlugin(QADMIN_PLUGIN_ID) end)
    else
        SendNUIMessage({ action = 'placing', data = false })
        if panelOpen then Mri.focus('panel', true) end
    end
    return ok and result or nil
end

RegisterNUICallback('panelClose', function(data, cb)
    cb({ success = true })
    Mri.closePanel(type(data) == 'table' and data.embedded == true)
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
