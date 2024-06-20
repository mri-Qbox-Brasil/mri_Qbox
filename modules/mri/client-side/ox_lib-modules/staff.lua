local function addStaff(args)
    args.callback()
end

local function manageStaff(staffData)
end

local function listStaff()
    local staffPeople = lib.callback.await('mri_Qbox:server:getStaff')
    local ctx = {
        id = 'list_staff',
        menu = 'menu_staff',
        title = 'Staffs',
        options = {}
    }
    for k, v in pairs(staffPeople) do
        print(v.type)
        ctx.options[#ctx.options+1] = {
           title = v.name,
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
                callback = listStaff
            }
        },{
            title = 'Ver membros',
            description = 'Lista os membros da Staff',
            icon = 'list-ul',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = listStaff
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
