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

local function addStaff(args)
    print(json.encode(args))
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
    local input = lib.inputDialog("Adicionar Staff", { {
        type = 'input',
        label = "Id",
        description = "Id do Jogador",
        required = true
    }, {
        type = 'input',
        label = 'Cargo',
        description = 'Cargo do Jogador(admin, mod, support)',
        placeholder = 'admin',
        required = true
    } })
    if input then
        if ConfirmationDialog(string.format("Adicionar '%s' a '%s'?", input[1], input[2])) then
            addStaff({
                staffData = {
                    offline = args.staffData.offline,
                    name = args.staffData.name,
                    source = tonumber(input[1])
                },
                newRole = input[2]
            })
        end
    end
end

local function removeStaff(args)
    if ConfirmationDialog(string.format("Remover '%s' de '%s'?", args.staffData.name, args.staffData.role)) then
        if args.staffData.offline then
            TriggerServerEvent("mri_Qbox:server:manageStaff", {
                citizenId = args.staffData.citizenId,
                action = 'remove'
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
        if ConfirmationDialog(string.format("Mudar '%s' de '%s' para '%s'?", args.staffData.name, args.staffData.role, input[1])) then
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
        description = string.format("Source: %s, Cargo: %s", staffData.source, staffData.role),
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
            description = string.format("Source: %s, Cargo: %s", v.source, v.role),
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
            title = 'Adicionar pessoas a Staff',
            description = 'Recrutar novos players',
            icon = 'square-plus',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = addNewStaff,
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
