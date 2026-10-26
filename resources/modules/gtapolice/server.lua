-- Came from the anticheat list: while the GTA police is off nobody can create its cops, a cheat menu included.
local COP_PEDS = { 's_m_y_ranger_01', 's_m_y_sheriff_01', 's_m_y_cop_01', 's_f_y_sheriff_01', 's_f_y_cop_01', 's_m_y_hwaycop_01' }

local blocked = {}

AddEventHandler('entityCreating', function(entity)
    if blocked[GetEntityModel(entity)] then CancelEvent() end
end)

-- Own tab in mri_Qadmin, like Veículos; it stays while the module is off so it can be turned back on there
local function registerPlugin()
    if GetResourceState('mri_Qadmin') ~= 'started' then return end
    local ok, err = pcall(function()
        exports['mri_Qadmin']:RegisterPlugin({
            id = 'gtapolice',
            label = 'Polícia NPC',
            icon = 'siren',
            category = 'world',
            resource = GetCurrentResourceName(),
            htmlPath = 'html/police.html',
            requiredPerms = { 'mri_Qbox.admin', 'command' },
            description = 'Polícia do GTA: viaturas, policiais, barreiras, procurado e se ela ataca o jogador',
        })
    end)
    if not ok then
        lib.print.warn(('[mri_Qbox] Falha ao registrar a aba Polícia NPC no mri_Qadmin: %s'):format(tostring(err)))
    end
end

AddEventHandler('mri_Qadmin:server:pluginsReady', registerPlugin)

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'mri_Qadmin' then registerPlugin() end
end)

CreateThread(function()
    Wait(0)
    registerPlugin()
end)

Mri.lifecycle('gtapolice', function(cfg)
    blocked = {}
    if cfg.police == true then return end
    for _, name in ipairs(COP_PEDS) do blocked[joaat(name)] = true end
end, function()
    blocked = {}
end)
