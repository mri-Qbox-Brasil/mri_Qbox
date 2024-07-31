local ColorScheme = GlobalState.UIColors

local function GetRayCoords()
    lib.notify({
        title = "Selecionar coordenadas",
        description = "Confirme pressionando [E]",
        type = "info",
        duration = 10000
    })
    while true do
        local hit, entity, coords = lib.raycast.cam(1, 4)
        lib.showTextUI(
            string.format('PARA  \nCONFIRMAR  \n**LOCAL**  \n  \nX: %.2f  \nY: %.2f  \nZ: %.2f', coords.x, coords.y, coords.z),
            {
                icon = "e"
            })

        if hit then
            DrawSphere(coords.x, coords.y, coords.z, 0.2, 0, 0, 255, 0.2)
            if IsControlJustReleased(1, 38) then -- E
                lib.hideTextUI()
                return coords
            end
        end
    end
end

lib.callback.register('mri_Qbox:client:raycast', function()
    local coords = GetRayCoords()
    lib.setClipboard(string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z))
end)

exports('GetRayCoords', GetRayCoords)

local function Request(title, text, position)
    if not position then
        position = 'top-right'
    end
    local ctx = {
        id = 'mriRequest',
        title = title,
        position = position,
        canClose = false,
        options = {{
            label = 'Sim',
            icon = 'fa-regular fa-circle-check',
            description = text
        },{
            label = 'Não',
            icon = 'fa-regular fa-circle-xmark',
            iconColor = ColorScheme.danger,
            description = text
        }}
    }
    local result = false
    lib.registerMenu(ctx, function(selected, scrollIndex, args)
        result = selected == 1
    end)
    lib.showMenu(ctx.id)
    while lib.getOpenMenu() == ctx.id do
        Wait(100)
    end
    return result
end

lib.callback.register('mri_Qbox:client:request', function(title, text, position)
    return Request(title, text, position)
end)

exports('Request', Request)
