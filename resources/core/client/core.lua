-- Exports do núcleo no client, usados por outros resources (contrato público:
-- não renomear). Request é chamado pelo qbx_management via callback.

local function colors()
    return GlobalState.UIColors or {}
end

--- Raycast da câmera até o jogador confirmar: E copia vec3, G copia vec4, Q cancela.
---@return vector3|vector4|false
local function GetRayCoords()
    while true do
        lib.notify({
            id = 'mri_Qbox:client:raycast',
            title = 'Selecionar coordenadas',
            type = 'info',
            duration = 1000,
            showDuration = false,
        })

        local hit, _, coords = lib.raycast.cam(1, 4)
        local heading = GetGameplayCamRot(2).z

        lib.showTextUI(('[E] Confirmar vec3  \n[G] Confirmar vec4  \n[Q] Cancelar  \n  \nX: %.2f  \nY: %.2f  \nZ: %.2f  \nH: %.2f')
            :format(coords.x, coords.y, coords.z, heading))

        if hit then
            DrawMarker(28, coords.x, coords.y, coords.z - 0.15, 0, 0, 0, 0, 0, 0, 0.25, 0.25, 0.25, 0, 0, 255, 100, false, true, 2, nil, nil, false)

            if IsControlJustReleased(1, 38) then
                lib.hideTextUI()
                lib.setClipboard(('vector3(%.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z))
                lib.notify({ title = 'Coordenadas copiadas', description = 'vector3 copiado pro clipboard!', type = 'success' })
                return vec3(coords.x, coords.y, coords.z)
            end

            if IsControlJustReleased(1, 47) then
                lib.hideTextUI()
                lib.setClipboard(('vector4(%.2f, %.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z, heading))
                lib.notify({ title = 'Coordenadas copiadas', description = 'vector4 copiado pro clipboard!', type = 'success' })
                return vec4(coords.x, coords.y, coords.z, heading)
            end
        end

        if IsControlJustReleased(0, 44) then
            lib.hideTextUI()
            lib.notify({ title = 'Cancelado', description = 'Seleção de coordenadas cancelada.', type = 'error' })
            return false
        end
        Wait(0)
    end
end

lib.callback.register('mri_Qbox:client:raycast', function()
    local coords = GetRayCoords()
    if coords then
        if coords.w then
            lib.setClipboard(('vector4(%.2f, %.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z, coords.w))
        else
            lib.setClipboard(('vector3(%.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z))
        end
    end
end)

exports('GetRayCoords', GetRayCoords)

--- Pergunta sim/não num menu do ox_lib e devolve a escolha.
---@param title string
---@param text string
---@param position? string
---@return boolean
local function Request(title, text, position)
    while lib.getOpenMenu() do Wait(100) end
    local ctx = {
        id = 'mriRequest',
        title = title,
        position = position or 'top-right',
        canClose = false,
        options = {
            { label = 'Sim', icon = 'fa-regular fa-circle-check', description = text },
            { label = 'Não', icon = 'fa-regular fa-circle-xmark', iconColor = colors().danger, description = text },
        },
    }
    local result = false
    lib.registerMenu(ctx, function(selected)
        result = selected == 1
    end)
    lib.showMenu(ctx.id)
    while lib.getOpenMenu() == ctx.id do Wait(100) end
    return result
end

lib.callback.register('mri_Qbox:client:request', function(title, text, position)
    return Request(title, text, position)
end)

exports('Request', Request)

--- O jogador aguenta mais `amount` de `itemName` no inventário (ox_inventory)?
---@param itemName string
---@param amount number
---@return boolean
local function CanCarryItem(itemName, amount)
    local itemWeight = exports.ox_inventory:Items(itemName).weight
    local currentWeight = exports.ox_inventory:GetPlayerWeight()
    local maxWeight = exports.ox_inventory:GetPlayerMaxWeight()
    return currentWeight + itemWeight * amount <= maxWeight
end

exports('CanCarryItem', CanCarryItem)
