ColorScheme = GlobalState.UIColors or {}
local vipPeople = {}

local function ConfirmationDialog(content)
    return lib.alertDialog({
        header = "Confirmação",
        content = content,
        centered = true,
        cancel = true,
        labels = {
            cancel = "Cancelar",
            confirm = "Confirmar"
        }
    })
end

local function findPlayers()
    local coords = GetEntityCoords(cache.ped)
    local closePlayers = lib.getNearbyPlayers(coords, 10, false)
    for _, v in pairs(closePlayers) do
        v.id = GetPlayerServerId(v.id)
    end
    return lib.callback.await('qbx_management:server:getPlayers', false, closePlayers)
end

local function addVip(args)
    print(json.encode(args))
    if args.vipData.offline then
        TriggerServerEvent("mri_Qbox:server:manageVip", {
            citizenId = args.vipData.citizenId,
            name = args.vipData.name,
            role = args.newRole,
            action = 'add'
        })
    else
        ExecuteCommand(string.format("vipadm %d add %s", args.vipData.source, args.newRole))
    end
    if args['callback'] then
        args.callback()
    end
end

exports("addVip", addVip)

local function addNewVip(args)
    local input = lib.inputDialog('Adicionar Vip', { {
        type = 'input',
        label = 'Id',
        description = 'Id do Jogador',
        disabled = args['nearby'],
        default = (args['vipData'] and args.vipData['source']),
        required = true
    }, {
        type = 'select',
        label = 'Cargo',
        description = 'Cargo do Vip',
        placeholder = 'admin',
        required = true,
        options = {
            {
                label = 'Tier 1',
                value = 'tier1',
            },
            {
                label = 'Tier 2',
                value = 'tier2',
            },
            {
                label = 'Tier 3',
                value = 'tier3',
            },
            {
                label = 'Tier 4',
                value = 'tier4',
            },
            {
                label = 'Tier 5',
                value = 'tier5',
            },
            {
                label = 'Tier 6',
                value = 'tier6',
            },
            {
                label = 'MRI QBOX',
                value = 'mriqbox',
            }  
        }
    } })
    if input then
        if ConfirmationDialog(string.format("Adicionar '%s' a '%s'?", input[1], input[2])) == 'confirm' then
            addVip({
                vipData = {
                    offline = args['vipData'] and args.vipData.offline,
                    name = (args['vipData'] and args.vipData.name) or input[2],
                    source = tonumber(input[1])
                },
                newRole = input[2]
            })
        end
    end
    if args['callback'] then
        args.callback(args)
    end
end

local function addNearbyVip(args)
    local hirevipMenu = {}
    local players = findPlayers()
    for _, player in pairs(players) do
        hirevipMenu[#hirevipMenu + 1] = {
            title = player.name,
            description = string.format("CitizenId: %s, Source: %s", player.citizenid, player.source),
            onSelect = addNewVip,
            args = {
                vipData = {
                    offline = false,
                    source = player.source
                },
                nearby = true,
                callback = addNearbyVip
            }
        }
    end

    lib.registerContext({
        id = 'hirevipMenu',
        title = 'Setar VIP',
        menu = 'menu_vip',
        options = hirevipMenu
    })

    lib.showContext('hirevipMenu')
end

local function removeVip(args)
    if ConfirmationDialog(string.format("Remover '%s' de '%s'?", args.vipData.name, args.vipData.role)) == 'confirm' then
        if args.vipData.offline then
            TriggerServerEvent("mri_Qbox:server:manageVip", {
                citizenId = args.vipData.citizenId,
                action = 'remove',
                name = args.vipData.name,
                role = args.vipData.role
            })
            Wait(500)
        else
            ExecuteCommand(string.format("vipadm %d rem %s", args.vipData.source, args.vipData.role))
        end
    end
    if args['callback'] then
        args.callback()
    end
end

exports("removeVip", removeVip)

local function changeRole(args)
    local input = lib.inputDialog("Alterar Cargo de Vip", { {
        type = 'select',
        label = 'Novo cargo vip',
        description = 'Tier do vip',
            options = {
                {
                    label = 'Tier 1',
                    value = 'tier1',
                },
                {
                    label = 'Tier 2',
                    value = 'tier2',
                },
                {
                    label = 'Tier 3',
                    value = 'tier3',
                },
                {
                    label = 'Tier 4',
                    value = 'tier4',
                },
                {
                    label = 'Tier 5',
                    value = 'tier5',
                },
                {
                    label = 'Tier 6',
                    value = 'tier6',
                },
                {
                    label = 'Only Z',
                    value = 'onlyz',
                }  
            },
        placeholder = 'admin',
        required = true
    } })
    if input then
        if ConfirmationDialog(string.format("Mudar '%s' de '%s' para '%s'?", args.vipData.name, args.vipData.role, input[1])) == 'confirm' then
            addVip({
                vipData = {
                    source = args.vipData.source,
                    citizenId = args.vipData.citizenId,
                    offline = args.vipData.offline,
                    name = args.vipData.name
                },
                newRole = input[1]
            })
        end
    end
    args.callback(args.vipData)
end

local function manageVip(vipData)
    local ctx = {
        id = 'manage_vip',
        menu = 'menu_vip',
        title = vipData.name,
        description = string.format("Source: %s, Cargo: %s", vipData.source or '(offline)', vipData.role),
        options = { {
            title = "Mudar Cargo",
            description = "Promover ou rebaixar o cargo.",
            icon = "retweet",
            iconAnimation = "fade",
            onSelect = changeRole,
            args = {
                vipData = vipData,
                callback = manageVip
            }
        }, {
            title = "Remover do Vip",
            description = "Remove do Vip e todas as permissões",
            icon = "trash",
            iconAnimation = "fade",
            iconColor = ColorScheme.danger,
            onSelect = removeVip,
            args = {
                vipData = vipData,
                callback = ListVip
            }
        } }
    }
    lib.registerContext(ctx)
    lib.showContext(ctx.id)
end

function ListVip()
    vipPeople = lib.callback.await('mri_Qbox:server:getVip')
    local ctx = {
        id = 'list_vip',
        menu = 'menu_vip',
        title = 'Vips',
        description = string.format("Online: %d/%d", vipPeople.onlineVip,
            vipPeople.onlineVip + vipPeople.offlineVip),
        options = {}
    }
    for k, v in pairs(vipPeople.vip) do
        ctx.options[#ctx.options + 1] = {
            title = v.displayName,
            description = string.format("Source: %s, Cargo: %s", v.source or '(offline)', v.role),
            onSelect = function()
                manageVip(v)
            end
        }
    end
    lib.registerContext(ctx)
    lib.showContext(ctx.id)
end

local function openVipMenu()
    local ctx = {
        id = 'menu_vip',
        menu = 'menu_admin',
        title = 'Vip',
        description = 'Gerenciamento do Vip',
        options = { {
            title = 'Adicionar Vip por ID',
            description = 'Adiciona uma pessoa pelo ID',
            icon = 'square-plus',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = addNewVip,
            args = {
                callback = ListVip
            }
        }, {
            title = 'Adicionar pessoas por proximidade',
            description = 'Adicionar pessoas que estão por perto',
            icon = 'bullseye',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = addNearbyVip,
            args = {
                callback = ListVip
            }
        }, {
            title = 'Ver membros',
            description = 'Lista os membros do Vip',
            icon = 'list-ul',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = ListVip
        }
        }
    }
    lib.registerContext(ctx)
    lib.showContext(ctx.id)
end

exports['mri_Qbox']:AddItemToMenu('f10',
    {
        title = 'Vip',
        description = 'Gerencie o Vip do servidor.',
        icon = 'star',
        iconAnimation = 'fade',
        arrow = true,
        onSelectFunction = openVipMenu,
    }
)
