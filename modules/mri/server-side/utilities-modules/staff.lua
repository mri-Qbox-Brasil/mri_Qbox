local staffs = {}

lib.addCommand('staff', {
    help = 'Dar permissão ao staff permnanentemente',
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
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local player = exports.qbx_core:GetPlayer(args.id)
    local metadata = player.PlayerData.metadata
    if not player then
        lib.notify(source, {
            title = 'Staff',
            description = 'Nenhum player encontrado',
            type = 'error'
        })
        return
    end
    if args.tipo == 'add' and args.cargo then
        lib.addPrincipal(args.id, 'group.' .. args.cargo)
        player.Functions.SetMetaData('staff', 'group.' .. args.cargo)
        lib.notify(args.id, {
            title = 'Staff',
            description = 'Recebeu o cargo ' .. args.cargo,
            type = 'success'
        })
    elseif args.tipo == 'rem' and metadata.staff then
        lib.removePrincipal(args.id, metadata.staff)
        player.Functions.SetMetaData('staff', nil)
        lib.notify(args.id, {
            title = 'Staff',
            description = 'Perdeu o cargo ' .. args.cargo,
            type = 'success'
        })
    end
    lib.notify(source, {
        title = 'Staff',
        description = 'Permissão ' .. args.id .. ' ' .. args.tipo .. ' ' .. args.cargo,
        type = 'success'
    })
end)

lib.addCommand('staffs', {
    help = 'Verifica quantos players tem permissão para staff',
    restricted = 'group.admin'
}, function(source, args)
    lib.notify(source, {
        title = 'Staff',
        description = 'Tem ' .. CountStaff() .. ' players com permissão para staff',
        type = 'info'
    })
end)

local function logoutStaff(source)
    local player = exports.qbx_core:GetPlayer(source)
    for k, v in pairs(staffs) do
        print(k, v)
        if v == player.PlayerData.citizenid then
            table.remove(staffs, k)
            break
        end
    end
    print("[SAIU] Log de staff: " .. player.PlayerData.citizenid .. " - ID:" .. source)
end

RegisterNetEvent('playerDropped', function(reason)
    logoutStaff(source)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(source)
    logoutStaff(source)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local player = exports.qbx_core:GetPlayer(source)
    local metadata = player.PlayerData.metadata

    if metadata.staff ~= nil then
        print("[ENTROU] Log de staff: " .. metadata.staff .. " - ID:" .. source)
        lib.addPrincipal(source, metadata.staff)
        lib.notify(source, {
            title = 'Staff',
            description = 'Logou como staff: ' .. metadata.staff .. ' - ID:' .. source,
            type = 'success'
        })
        staffs[#staffs + 1] = player.PlayerData.citizenid
    end
end)

function CountStaff()
    return #staffs
end exports('CountStaff', CountStaff)
