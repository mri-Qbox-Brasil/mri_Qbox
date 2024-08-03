local function fetchPlayers()
    return MySQL.query.await("SELECT citizenid FROM players")
end

local function sendNotification(source, type, message)
    if source > 0 then
        lib.notify(source, {
            title = "Staff",
            type = type,
            description = message
        })
    else
        print(string.format("[CMD] [STAFF] %s: %s", type, message))
    end
end

local function getMenuEntries()
    local result = {}
    local onlineStaff, offlineStaff = 0, 0
    local players = fetchPlayers()
    for k, v in pairs(players) do
        local player = exports.qbx_core:GetPlayerByCitizenId(v.citizenid) or
            exports.qbx_core:GetOfflinePlayer(v.citizenid)
        local namePrefix = player.Offline and '❌' or '🟢'
        if player.PlayerData.metadata['staff'] then
            if player.Offline then
                offlineStaff = offlineStaff + 1
            else
                onlineStaff = onlineStaff + 1
            end
            result[#result + 1] = {
                source = player.PlayerData.source,
                citizenId = v.citizenid,
                displayName = string.format("%s %s %s", namePrefix, player.PlayerData.charinfo.firstname,
                    player.PlayerData.charinfo.lastname),
                name = string.format("%s %s", player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname),
                role = player.PlayerData.metadata['staff'],
                offline = player.Offline
            }
        end
    end
    return {
        staff = result,
        offlineStaff = offlineStaff,
        onlineStaff = onlineStaff
    }
end

lib.callback.register('mri_Qbox:server:getStaff', function(source)
    return getMenuEntries()
end)

lib.addCommand('staff', {
    help = 'Dar permissão ao staff permanentemente',
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
            help = 'Cargo de staff (admin, mod ou support)',
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
        lib.addPrincipal(args.id, 'group.' .. args.cargo)
        player.Functions.SetMetaData('staff', 'group.' .. args.cargo)
        sendNotification(args.id, "success", string.format("Recebeu o cargo: %s", args.cargo))
    elseif args.tipo == 'rem' and player.PlayerData.metadata['staff'] then
        lib.removePrincipal(args.id, player.PlayerData.metadata['staff'])
        player.Functions.SetMetaData('staff', nil)
        sendNotification(args.id, "info", string.format("Cargo: %s removido", player.PlayerData.metadata['staff']))
    end
    sendNotification(source, "success",
        string.format("Permissão %s %s a: %d", args.cargo or player.PlayerData.metadata['staff'],
            (args.tipo == 'add' and "concedida") or "revogada", args.id))
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local player = exports.qbx_core:GetPlayer(source)
    if player and player.PlayerData.metadata['staff'] then
        lib.addPrincipal(source, player.PlayerData.metadata['staff'])
    end
end)

RegisterNetEvent('mri_Qbox:server:manageStaff', function(data)
    local source = source
    local player = exports.qbx_core:GetOfflinePlayer(data.citizenId)
    if player then
        if data.action == 'remove' then
            player.PlayerData.metadata['staff'] = nil
        elseif data.action == 'add' then
            player.PlayerData.metadata['staff'] = data.role
        end
        exports.qbx_core:SaveOffline(player.PlayerData)
        sendNotification(source, "success",
            string.format("Permissão '%s' %s a: %s", data.role or player.PlayerData.metadata['staff'],
                (data.action == 'add' and "concedida") or "revogada", data.name))
    end
end)
