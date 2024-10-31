local inside = false
local oldcoords = nil

-- Impede o capacete automático para motos
lib.onCache(
    "ped",
    function(value)
        if value then
            SetPedConfigFlag(value, 35, false)
        end
    end
)

-- Disable blind firing --mur4i
Citizen.CreateThread(
    function()
        while cfg.disableblindfiring.toggle do
            local ped = PlayerPedId()
            if IsPedArmed(ped, 4) then
                if IsPedInCover(ped, 1) and not IsPedAimingFromCover(ped, 1) then
                    DisableControlAction(2, 24, true)
                    DisableControlAction(2, 142, true)
                    DisableControlAction(2, 257, true)
                end
                Citizen.Wait(5)
            else
                Citizen.Wait(500)
            end
        end
    end
)

-- Desativar o rolar (Contribuição: .reiffps)
Citizen.CreateThread(
    function()
        while cfg.disablecombatroll.toggle do
            Citizen.Wait(5)
            if IsPedArmed(GetPlayerPed(-1), 4 | 2) and IsControlPressed(0, 25) then
                DisableControlAction(0, 22, true)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while cfg.disablefreepunch.toggle do
            local delay = 1000

            -- Verifica se o jogador está segurando o botão direito do mouse
            if not IsAimCamActive() then -- Botão direito do mouse
                DisablePlayerFiring(PlayerId())
                delay = 0
            end
            Citizen.Wait(delay)
        end
    end
)

-- dumpsters

CreateThread(function()
    App()
end)

function App()
    exports.ox_target:addModel(cfg.dumpsters.TrashCans.Model, {
        event = 'mri_Qhideintrash:enter',
        icon = "fa-sharp fa-solid fa-eye-low-vision",
        label ="Esconder",
        distance = 1
    })
    exports.ox_target:addModel(cfg.dumpsters.TrashCans.Model, {
        icon = 'fas fa-dumpster',
        label = "Abrir",
        onSelect = function(data)
            local entity = data.entity
            local netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity)
            if not netId then
                local coords = GetEntityCoords(entity)
                entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 0.1, GetEntityModel(entity), true, true, true)
                netId = entity ~= 0 and NetworkGetNetworkIdFromEntity(entity)
            end
            if netId then
                exports.ox_inventory:openInventory('dumpster', 'dumpster'..netId)
            end
        end,
        distance = 2
	})
end

RegisterNetEvent('mri_Qhideintrash:enter',function()
    Enter()
end)

RegisterNetEvent('mri_Qhideintrash:exit',function()
    Exit()
end)

local function listenForKeyPressToLeave()
    if IsControlJustReleased(0, 38) then
        lib.hideTextUI()
        Exit()
    end
end

function Enter()
    if inside then return end
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(PlayerPedId())
    for k,v in pairs(cfg.dumpsters.TrashCans.Model) do
        local objectId = GetClosestObjectOfType(pedCoords, 1.0, cfg.dumpsters.TrashCans.Model[k], false)
        if DoesEntityExist(objectId) then
            inside = true
            local objectcoords = GetEntityCoords(objectId)
            oldcoords = GetEntityCoords(ped)
            SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z, 0.0, 0.0, 0.0)
            FreezeEntityPosition(ped, true)
            SetEntityVisible(ped, false)
            lib.zones.sphere({
                coords = vector3(objectcoords.x, objectcoords.y, objectcoords.z),
                radius = 2.75,
                onEnter = function()
                    lib.showTextUI('[E] Sair ')
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = listenForKeyPressToLeave,
            })
            return
        end
    end
end

function Exit()
    local ped = PlayerPedId()
    inside = false
    SetEntityCoords(ped,oldcoords.x,oldcoords.y,oldcoords.z - 1)
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true)
end

RegisterNetEvent("mri_Qbox:ExecuteCommand", function(command,args)
    if not args then
        ExecuteCommand(command)
    else
        ExecuteCommand(command.." "..args)
    end
end)

RegisterCommand("addskill", function(source, args)
    exports["cw-rep"]:updateSkill(args[1], args[2])
end)

RegisterCommand("menu", function(source, args)
    if args and args[1] then
        exports.qbx_management:OpenBossMenu(args[1])
    end
end)

RegisterCommand("cutscene", function(source, args)
    local cutscene = args[1]
    TriggerEvent('Cutsceneplayer:Play', cutscene)
end)

TriggerEvent('chat:addSuggestion', '/cutscene', 'Play Cut Scene', {{name="cut scene name"}})

RegisterNetEvent("Cutsceneplayer:Play")
AddEventHandler("Cutsceneplayer:Play", function(cutscene)
    local playerId = PlayerPedId()

	if IsPedMale(playerId) then RequestCutsceneWithPlaybackList(cutscene, 31, 8)
    	else RequestCutsceneWithPlaybackList(cutscene, 103, 8) end

    	while not HasCutsceneLoaded() do Wait(10)
    end
    StartCutscene(4)
end)

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
