ColorScheme = GlobalState.UIColors or {}
local staffPeople = {}

local function addStaff(args)
    ExecuteCommand(string.format("staff %d add %s", args.staffData.source, args.newRole))
    if args['callback'] then
        args.callback()
    end
end


local function removeStaff(args)
    ExecuteCommand(string.format("staff %d rem %s", args.staffData.source, args.staffData.role))
    if args['callback'] then
        args.callback()
    end
end

local function changeRole(args)
    removeStaff({source = args.staffData.source, role = args.staffData.role})
    addStaff({source = args.staffData.source, args.newRole})
    args.callback(args.staffData)
end

local function manageStaff(staffData)
    local ctx = {
        id = 'manage_staff',
        menu = 'menu_staff',
        title = staffData.name,
        description = string.format("Source: %s, Cargo: %s", staffData.source, staffData.role),
        options = {{
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
        }}
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
        description = string.format("Online: %d/%d", staffPeople.onlineStaff, staffPeople.onlineStaff + staffPeople.offlineStaff),
        options = {}
    }
    for k, v in pairs(staffPeople.staff) do
        print(v.type)
        ctx.options[#ctx.options+1] = {
           title = v.name,
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
        options = {{
            title = 'Adicionar pessoas a Staff',
            description = 'Recrutar novos players',
            icon = 'square-plus',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = addStaff,
            args = {
                callback = ListStaff
            }
        },{
            title = 'Ver membros',
            description = 'Lista os membros da Staff',
            icon = 'list-ul',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = ListStaff
        }
    }}
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
