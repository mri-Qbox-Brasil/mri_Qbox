if not cfg.vipmenu.Enable then return end

local QBCore = exports['qb-core']:GetCoreObject()

local function fetchPlayers()
    return MySQL.query.await("SELECT citizenid FROM players")
end

local function sendNotification(source, type, message)
    if tonumber(source) and tonumber(source) > 0 then
        lib.notify(source, {
            title = "VIPs",
            type = type,
            description = message
        })
    else
        print(string.format("[CMD] [VIP] %s: %s", type, message))
    end
end

local function getMenuEntries()
    local result = {}
    local onlineVip, offlineVip = 0, 0
    local players = fetchPlayers()
    for k, v in pairs(players) do
        local player = exports.qbx_core:GetPlayerByCitizenId(v.citizenid) or
            exports.qbx_core:GetOfflinePlayer(v.citizenid)
        local namePrefix = player.Offline and '❌' or '🟢'
        if player.PlayerData.metadata['vip'] then
            if player.Offline then
                offlineVip = offlineVip + 1
            else
                onlineVip = onlineVip + 1
            end
            result[#result + 1] = {
                source = player.PlayerData.source,
                citizenId = v.citizenid,
                displayName = string.format("%s %s %s", namePrefix, player.PlayerData.charinfo.firstname,
                    player.PlayerData.charinfo.lastname),
                name = string.format("%s %s", player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname),
                role = player.PlayerData.metadata['vip'],
                offline = player.Offline
            }
        end
    end
    return {
        vip = result,
        offlineVip = offlineVip,
        onlineVip = onlineVip
    }
end

lib.callback.register('mri_Qbox:server:getVip', function(source)
    return getMenuEntries()
end)

local function updateInventoryWeight(source)
    local player = exports.qbx_core:GetPlayer(source)

    if player then
        local vip = player.PlayerData.metadata['vip'] or 'nenhum'
        local invWeight = cfg.vipmenu.Roles[vip].inventory

        print(string.format("[VIP] atualizando tamanho do inventário para: '%s'", invWeight*1000))
        exports.ox_inventory:SetMaxWeight(source, invWeight*1000)
    end
end

local function executeVip(source, args)
    if not args.id then
        sendNotification(source, "error", "Id não informado.")
        return
    end

    if not args.tipo then
        sendNotification(source, "error", "Tipo não informado.")
        return
    end

    if args.tipo == 'add' and not args.tier then
        sendNotification(source, "error", "Vip não informado.")
        return
    end

    local player = exports.qbx_core:GetPlayer(args.id)
    if not player then
        sendNotification(source, "error", "Nenhum player encontrado.")
        return
    end

    if args.tipo == 'add' then
        lib.addPrincipal(args.id, args.tier)
        player.Functions.SetMetaData('vip', args.tier)
        sendNotification(args.id, "success", string.format("Recebeu o vip: %s", args.tier))
    elseif args.tipo == 'rem' and player.PlayerData.metadata['vip'] then
        lib.removePrincipal(args.id, player.PlayerData.metadata['vip'])
        player.Functions.SetMetaData('vip', nil)
        sendNotification(args.id, "info", string.format("Vip: %s removido", player.PlayerData.metadata['vip']))
    end
    sendNotification(source, "success",
        string.format("Permissão %s %s a: %d", args.tier or player.PlayerData.metadata['vip'],
            (args.tipo == 'add' and "concedida") or "revogada", args.id))

    updateInventoryWeight(args.id)
    return true
end

exports("VipAdm", executeVip)

lib.addCommand('vipadm', {
    help = 'Dar permissão ao vip permanentemente',
    params = {
        {
            name = 'id',
            type = 'playerId',
            help = 'Source ID do player',
        },
        {
            name = 'tipo',
            type = 'string',
            help = 'Tipo de permissão (add ou rem)',
        },
        {
            name = 'tier',
            type = 'string',
            help = 'Tier de vip',
            optional = true
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    executeVip(source, args)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local player = exports.qbx_core:GetPlayer(source)
    if player and player.PlayerData.metadata['vip'] then
        print(string.format("[VIP] setando vip: '%s', para: '%s'", player.PlayerData.charinfo.firstname, player.PlayerData.metadata['vip']))
        lib.addPrincipal(source, player.PlayerData.metadata['vip'])
        print(string.format("[VIP] setado vip: '%s', para: '%s'", player.PlayerData.charinfo.firstname, player.PlayerData.metadata['vip']))
        updateInventoryWeight(source)
    end
end)

RegisterNetEvent('mri_Qbox:server:manageVip', function(data)
    local source = source
    local player = exports.qbx_core:GetOfflinePlayer(data.citizenId)
    local identifier = player.PlayerData.license
    local targetSource = exports.qbx_core:GetSource(identifier)
    local targetPlayer = targetSource > 0 and exports.qbx_core:GetPlayer(targetSource)
    if player then
        if data.action == 'remove' then
            player.PlayerData.metadata['vip'] = nil
            if targetSource > 0 then
                lib.removePrincipal(targetSource, player.PlayerData.metadata['vip'])
                targetPlayer.Functions.SetMetaData('vip', nil)
            end
        elseif data.action == 'add' then
            player.PlayerData.metadata['vip'] = data.role
            if targetSource > 0 then
                lib.addPrincipal(targetSource, data.role)
                targetPlayer.Functions.SetMetaData('vip', data.role)
            end
        end
        exports.qbx_core:SaveOffline(player.PlayerData)
        sendNotification(source, "success",
            string.format("Permissão '%s' %s a: %s", data.role or player.PlayerData.metadata['vip'],
                (data.action == 'add' and "concedida") or "revogada", data.name))
    end
end)

local function sendPaycheck(player, payment)
    player.Functions.AddMoney(cfg.vipmenu.CashType, payment)
    sendNotification(player.PlayerData.source, "success", string.format("Você recebeu seu salário VIP de %s %s", cfg.vipmenu.CoinType, payment))
end

local function pay(player)
    local vip = player.PlayerData.metadata["vip"] or "nenhum"
    if vip == "nenhum" then return end
    local payment = cfg.vipmenu.Roles[vip].payment or 0
    if payment <= 0 then return end
    sendPaycheck(player, payment)
end

CreateThread(function()
    if cfg.vipmenu.PaycheckInterval <= 0 then return end
    local interval = 60000 * cfg.vipmenu.PaycheckInterval
    while true do
        Wait(interval)
        for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
            pay(player)
        end
    end
end)
