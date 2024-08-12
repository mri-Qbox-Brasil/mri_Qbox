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
            name = 'cargo',
            type = 'string',
            help = 'Cargo de vip',
            optional = true
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    if not args.id then
        sendNotification(source, "error", "Id não informado.")
        return
    end

    if not args.tipo then
        sendNotification(source, "error", "Tipo não informado.")
        return
    end

    if args.tipo == 'add' and not args.cargo then
        sendNotification(source, "error", "Cargo não informado.")
        return
    end

    local player = exports.qbx_core:GetPlayer(args.id)
    if not player then
        sendNotification(source, "error", "Nenhum player encontrado.")
        return
    end

    if args.tipo == 'add' then
        lib.addPrincipal(args.id, args.cargo)
        player.Functions.SetMetaData('vip', args.cargo)
        sendNotification(args.id, "success", string.format("Recebeu o cargo: %s", args.cargo))
    elseif args.tipo == 'rem' and player.PlayerData.metadata['vip'] then
        lib.removePrincipal(args.id, player.PlayerData.metadata['vip'])
        player.Functions.SetMetaData('vip', nil)
        sendNotification(args.id, "info", string.format("Cargo: %s removido", player.PlayerData.metadata['vip']))
    end
    sendNotification(source, "success",
        string.format("Permissão %s %s a: %d", args.cargo or player.PlayerData.metadata['vip'],
            (args.tipo == 'add' and "concedida") or "revogada", args.id))
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local player = exports.qbx_core:GetPlayer(source)
    if player and player.PlayerData.metadata['vip'] then
        lib.addPrincipal(source, player.PlayerData.metadata['vip'])
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
