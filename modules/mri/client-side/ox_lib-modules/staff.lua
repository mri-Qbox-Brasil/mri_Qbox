ColorScheme = GlobalState.UIColors or {}
local staffPeople = {}

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

local function addStaff(args)
    if args.staffData.offline then
        TriggerServerEvent("mri_Qbox:server:manageStaff", {
            citizenId = args.staffData.citizenId,
            name = args.staffData.name,
            role = args.newRole,
            action = 'add'
        })
    else
        ExecuteCommand(string.format("staff %d add %s", args.staffData.source, args.newRole))
    end
    if args['callback'] then
        args.callback()
    end
end

local function addNewStaff(args)
    local input = lib.inputDialog('Adicionar Staff', { {
        type = 'input',
        label = 'Id',
        description = 'Id do Jogador',
        disabled = args['nearby'],
        default = (args['staffData'] and args.staffData['source']),
        required = true
    }, {
        type = 'input',
        label = 'Cargo',
        description = 'Cargo do Jogador(admin, mod, support)',
        placeholder = 'admin',
        required = true
    } })
    if input then
        if ConfirmationDialog(string.format("Adicionar '%s' a '%s'?", input[1], input[2])) == 'confirm' then
            addStaff({
                staffData = {
                    offline = args['staffData'] and args.staffData.offline,
                    name = (args['staffData'] and args.staffData.name) or input[2],
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

local function addNearbyStaff(args)
    local hireMenu = {}
    local players = findPlayers()
    for _, player in pairs(players) do
        hireMenu[#hireMenu + 1] = {
            title = player.name,
            description = string.format("CitizenId: %s, Source: %s", player.citizenid, player.source),
            onSelect = addNewStaff,
            args = {
                staffData = {
                    offline = false,
                    source = player.source
                },
                nearby = true,
                callback = addNearbyStaff
            }
        }
    end

    lib.registerContext({
        id = 'hireMenu',
        title = 'Recrutar',
        menu = 'menu_staff',
        options = hireMenu
    })

    lib.showContext('hireMenu')
end

local function removeStaff(args)
    if ConfirmationDialog(string.format("Remover '%s' de '%s'?", args.staffData.name, args.staffData.role)) == 'confirm' then
        if args.staffData.offline then
            TriggerServerEvent("mri_Qbox:server:manageStaff", {
                citizenId = args.staffData.citizenId,
                action = 'remove',
                name = args.staffData.name,
                role = args.staffData.role
            })
            Wait(500)
        else
            ExecuteCommand(string.format("staff %d rem %s", args.staffData.source, args.staffData.role))
        end
    end
    if args['callback'] then
        args.callback()
    end
end

local function changeRole(args)
    local input = lib.inputDialog("Alterar Cargo de Staff", { {
        type = 'input',
        label = 'Novo cargo',
        description = 'Cargo do Jogador(admin, mod, support)',
        placeholder = 'admin',
        required = true
    } })
    if input then
        if ConfirmationDialog(string.format("Mudar '%s' de '%s' para '%s'?", args.staffData.name, args.staffData.role, input[1])) == 'confirm' then
            addStaff({
                staffData = {
                    source = args.staffData.source,
                    citizenId = args.staffData.citizenId,
                    offline = args.staffData.offline,
                    name = args.staffData.name
                },
                newRole = input[1]
            })
        end
    end
    args.callback(args.staffData)
end

local function manageStaff(staffData)
    local ctx = {
        id = 'manage_staff',
        menu = 'menu_staff',
        title = staffData.name,
        description = string.format("Source: %s, Cargo: %s", staffData.source or '(offline)', staffData.role),
        options = { {
            title = "Mudar Cargo",
            description = "Promover ou rebaixar o cargo.",
            icon = "retweet",
            iconAnimation = "fade",
            onSelect = changeRole,
            args = {
                staffData = staffData,
                callback = manageStaff
            }
        }, {
            title = "Remover da Staff",
            description = "Remove da Staff e todas as permissões",
            icon = "trash",
            iconAnimation = "fade",
            iconColor = ColorScheme.danger,
            onSelect = removeStaff,
            args = {
                staffData = staffData,
                callback = ListStaff
            }
        } }
    }
    lib.registerContext(ctx)
    lib.showContext(ctx.id)
end

function ListStaff()
    staffPeople = lib.callback.await('mri_Qbox:server:getStaff')
    local ctx = {
        id = 'list_staff',
        menu = 'menu_staff',
        title = 'Staffs',
        description = string.format("Online: %d/%d", staffPeople.onlineStaff,
            staffPeople.onlineStaff + staffPeople.offlineStaff),
        options = {}
    }
    for k, v in pairs(staffPeople.staff) do
        ctx.options[#ctx.options + 1] = {
            title = v.displayName,
            description = string.format("Source: %s, Cargo: %s", v.source or '(offline)', v.role),
            onSelect = function()
                manageStaff(v)
            end
        }
    end
    lib.registerContext(ctx)
    lib.showContext(ctx.id)
end

local function openStaffMenu()
    local ctx = {
        id = 'menu_staff',
        menu = 'menu_admin',
        title = 'Staff',
        description = 'Gerenciamento da Staff',
        options = { {
            title = 'Adicionar Staff por ID',
            description = 'Adiciona uma pessoa pelo ID',
            icon = 'square-plus',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = addNewStaff,
            args = {
                callback = ListStaff
            }
        }, {
            title = 'Adicionar pessoas por proximidade',
            description = 'Adicionar pessoas que estão por perto',
            icon = 'bullseye',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = addNearbyStaff,
            args = {
                callback = ListStaff
            }
        }, {
            title = 'Ver membros',
            description = 'Lista os membros da Staff',
            icon = 'list-ul',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = ListStaff
        }
        }
    }
    lib.registerContext(ctx)
    lib.showContext(ctx.id)
end

exports['mri_Qbox']:AddItemToMenu('f10',
    {
        title = 'Staff',
        description = 'Gerencie a staff do servidor.',
        icon = 'users-viewfinder',
        iconAnimation = 'fade',
        arrow = true,
        onSelectFunction = openStaffMenu,
    }
)
