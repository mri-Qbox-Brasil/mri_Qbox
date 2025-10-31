local ColorScheme = GlobalState.UIColors

local function GetRayCoords()
    while true do
        lib.notify({
            id = "mri_Qbox:client:raycast",
            title = "Selecionar coordenadas",
            type = "info",
            duration = 1000,
            showDuration = false
        })

        local hit, entity, coords = lib.raycast.cam(1, 4)
        local camRot = GetGameplayCamRot(2)
        local heading = camRot.z

        lib.showTextUI(
            string.format(
                "[E] Confirmar vec3  \n[G] Confirmar vec4  \n[Q] Cancelar  \n  \nX: %.2f  \nY: %.2f  \nZ: %.2f  \nH: %.2f",
                coords.x,
                coords.y,
                coords.z,
                heading
            )
        )

        if hit then
        DrawMarker(28, coords.x, coords.y, coords.z - 0.15, 0, 0, 0, 0, 0, 0, 0.25, 0.25, 0.25, 0, 0, 255, 100, false, true, 2, nil, nil, false)

            if IsControlJustReleased(1, 38) then
                lib.hideTextUI()
                lib.setClipboard(string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z))
                lib.notify({
                    title = "Coordenadas copiadas",
                    description = "vector3 copiado pro clipboard!",
                    type = "success"
                })
                return vec3(coords.x, coords.y, coords.z)
            end

            if IsControlJustReleased(1, 47) then
                lib.hideTextUI()
                lib.setClipboard(string.format("vector4(%.2f, %.2f, %.2f, %.2f)", coords.x, coords.y, coords.z, heading))
                lib.notify({
                    title = "Coordenadas copiadas",
                    description = "vector4 copiado pro clipboard!",
                    type = "success"
                })
                return vec4(coords.x, coords.y, coords.z, heading)
            end
        end

        if IsControlJustReleased(0, 44) then
            lib.hideTextUI()
            lib.notify({
                title = "Cancelado",
                description = "Seleção de coordenadas cancelada.",
                type = "error"
            })
            return false
        end
        Wait(0)
    end
end


lib.callback.register('mri_Qbox:client:raycast', function()
    local coords = GetRayCoords()
    if coords then
        if coords.w then
            lib.setClipboard(string.format("vector4(%.2f, %.2f, %.2f, %.2f)", coords.x, coords.y, coords.z, coords.w))
        else
            lib.setClipboard(string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z))
        end
    end
end)


exports('GetRayCoords', GetRayCoords)

local function Request(title, text, position)
    while lib.getOpenMenu() do
        Wait(100)
    end
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
