local ColorScheme = {
    success = '#51CF66',
    info = '#668CFF',
    warning = '#FFD700',
    danger = '#FF6347'
}
GlobalState:set('UIColors', ColorScheme, true)
local imageUrl = 'https://cfx-nui-mri_Qbox/web-side/icones/logo24.png'

local playerMenu = {}
local runTimePlayerMenu = {}
local managementMenu = {}
local f10Menu = {}

local function getSpaces(qtd)
    local result = ''
    for i = 1, qtd do
        result = result ..' '
    end
    return result
end

local function getPlayerInformation(data)
    return string.format(
        '**ID**: %s | **RG**: %s %s **Nome**: %s',
        data.source,
        data.citizenid,
        getSpaces(130),
        data.name
    )
end

local function addMenuItem(title, icon, iconAnimation, description, onSelectFunction, onSelectArg, arrow)
    return {
        title = title,
        icon = icon,
        iconAnimation = iconAnimation,
        description = description,
        arrow = arrow or false,
        onSelect = function()
            if onSelectArg then
                onSelectFunction(onSelectArg)
            else
                onSelectFunction()
            end
        end
    }
end

local function locateMenuItem(menu, title)
    for k, v in pairs(menu) do
        if v.title == title then
            return k
        end
    end
    return 0
end

local function locateMenu(menu)
    if menu == 'f10' then
        return f10Menu
    elseif menu == 'management' then
        return managementMenu
    elseif menu == 'player' then
        return runTimePlayerMenu
    else
        print(string.format("Menu: '%s' não encontrado."))
    end
end

local function addItemToMenu(menu, item)
    local menuToAdd = locateMenu(menu)
    if not menuToAdd then
        return
    end
    local index = locateMenuItem(menuToAdd, item.title)
    if index == 0 then
        index = #menuToAdd + 1
    end
    menuToAdd[index] = addMenuItem(item.title, item.icon, item.iconAnimation, item.description, item.onSelectFunction, item.onSelectArg, item.arrow)
end

exports('AddItemToMenu', addItemToMenu)

local function removeItemFromMenu(menu, title)
    local menuToRemove = locateMenu(menu)
    local index = locateMenuItem(menuToRemove, title)
    if index > 0 then
        menuToRemove[index] = nil
    end
end

exports('RemoveItemFromMenu', removeItemFromMenu)

local function addManageMenu(item)
    addItemToMenu('management', item)
end

exports('AddManageMenu', addManageMenu)

local function removeManageMenu(title)
    removeItemFromMenu('management', title)
end

exports('RemoveManageMenu', removeManageMenu)

local function addPlayerMenu(item)
    addItemToMenu('player', item)
end

exports('AddPlayerMenu', addPlayerMenu)

local function removePlayerMenu(title)
    removeItemFromMenu('player', title)
end

exports('RemovePlayerMenu', removePlayerMenu)

-- Função para abrir o menu do jogador
function AbrirMenuJogador()
    -- Registro do menu "Jogador"
    local PlayerData = QBX.PlayerData

    local jobData = {
        label = PlayerData.job.label,
        grade = PlayerData.job.grade.name
    }
    local gangData = {
        label = PlayerData.gang.label,
        grade = PlayerData.gang.grade.name
    }

    local options = {}
    table.insert(options, addMenuItem('Identificação', 'fas fa-address-card', 'fade', getPlayerInformation(PlayerData), ExecuteCommand, 'id'))
    table.insert(options, addMenuItem('Emprego', 'fas fa-briefcase', 'fade', jobData.label..' | '..jobData.grade, ExecuteCommand, 'job'))
    if PlayerData.job.isboss then
        table.insert(options, addMenuItem('Gerenciar Emprego', 'users', 'fade', 'Configurações do Emprego.', ExecuteCommand, '+tablet:job'))
    end
    table.insert(options, addMenuItem('Gangue', 'gun', 'fade', gangData.label..' | '..gangData.grade, ExecuteCommand, 'gang'))
    if PlayerData.gang.isboss then
        table.insert(options, addMenuItem('Gerenciar Gangue', 'users', 'fade', 'Configurações da gangue.', ExecuteCommand, '+tablet:gang'))
    end
    table.insert(options, addMenuItem('Ver Reputação', 'book', 'fade', 'Exibir o nível de reputação do seu personagem.', ExecuteCommand, 'rep'))
    table.insert(options, addMenuItem('Ver Habilidades', 'fa-solid fa-book-bookmark', 'fade', 'Exibir o nível de habilidades do seu personagem.', ExecuteCommand, 'skill'))
    table.insert(options, addMenuItem('Waypoints', 'location-dot', 'fade', 'Configurações do sistema de waypoints (ponto de referência).', AbrirMenuWaypoints, nil, true))

    for k, v in pairs(runTimePlayerMenu) do
        table.insert(options, v)
    end

    lib.registerContext({
        id = 'menu_jogador',
        title = '![logo]('..imageUrl..') Olá '..PlayerData.charinfo.firstname,
        description = 'BEM VINDO À MRI QBOX',
        options = options
    })

    -- Exibe o menu do jogador
    lib.showContext('menu_jogador')
end

function AbrirMenuWaypoints()
    lib.registerContext({
        id = 'menu_waypoints',
        menu = 'menu_jogador',
        title = 'Gerenciar Waypoints',
        options = {
            {
                title = 'Limpar Marcadores',
                description = 'Limpar todos os waypoints.',
                icon = 'trash',
                iconAnimation = 'fade',
                onSelect = function()
                    ExecuteCommand('clearwaypoints')
                end
            },
            {
                title = 'Configurações',
                description = 'Configurações do sistema de waypoints (ponto de referência).',
                icon = 'location-dot',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ExecuteCommand('waypointsettings')
                end
            },
        }
    })
    lib.showContext('menu_waypoints')
end

function AbrirMenuTime()
    local freezeTime = GlobalState.freezeTime or 0
    lib.registerContext({
        id = 'menu_time',
        title = 'Gerenciar Horário',
        menu = 'menu_admin',
        options = {
            {
                title = 'Alterar horário',
                description = 'Modificar a hora atual do servidor.                                         '
                ..'*/time [hh] [mm]*',
                icon = 'clock',
                iconAnimation = 'fade',
                onSelect = function()
                    local input = lib.inputDialog('Alterar horário',{
                        { type = "number", label = 'Hora', default = 12, min = 0, max = 24},
                        { type = "number", label = 'Minutos', default = 0, min = 0, max = 59},
                    })

                    ExecuteCommand('time '..input[1]..' '..input[2])
                end
            },
            {
                title = 'Escala do tempo',
                description = 'Modificar durará 1 minuto.                                                       '
                ..'**Valor atual: '..GlobalState.timeScale..'**                                                                 '
                ..'*/timescale [ms]*',
                icon = 'stopwatch',
                iconAnimation = 'fade',
                onSelect = function()
                    local input = lib.inputDialog('Escala do tempo',{
                        { type = "number", label = 'Modificar', description = 'Quanto será 1 minuto no jogo (Ex.: 3000, a cada 3 segundos irá passar 1 minuto no relógio do jogo)', default = 3000, min = 3000},
                    })

                    ExecuteCommand('timescale '..input[1])
                end
            },
            {
                title = 'Congelar/Descongelar',
                description = 'Congele ou descongele o tempo.                                                                '
                ..'**Valor atual: '..freezeTime..'**                                                                   '
                ..'*/freezetime [1 ou 0]*',
                icon = 'snowflake',
                iconAnimation = 'fade',
                onSelect = function()
                    if freezetime == 0 then freezetime = 1 else freezetime = 0 end
                    ExecuteCommand('freezetime '..freezeTime)
                end
            },

        }
    })

    lib.showContext('menu_time')
end

function OpenAdminMenu()
    -- Menu admin (F10)
    local options = {
        {
            title = 'Abrir Painel',
            description = 'Painel da Administração do Servidor',
            icon = 'fa-solid fa-user-tie',
            iconAnimation = 'fade',
            onSelect = function()
                ExecuteCommand('adm')
            end
        },
        {
            title = 'Customizar Veículo',
            description = 'Tune seu veículo atual',
            icon = 'palette',
            iconAnimation = 'fade',
            onSelect = function()
                ExecuteCommand('customs')
            end
        },
        {
            title = 'Relógio',
            description = 'Altere o horário do servidor',
            icon = 'clock',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                AbrirMenuTime()
            end
        },
        {
            title = 'Clima',
            description = 'Gerenciar o clima do Servidor',
            icon = 'cloud',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                ExecuteCommand('weather')
            end
        },
        {
            title = 'Gerenciamento',
            description = 'Acesso a opções de gerenciamento do servidor',
            icon = 'fa-solid fa-cogs',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                OpenManageMenu()
            end
        }
    }

    for _, v in pairs(f10Menu) do
        options[#options+1] = v
    end

    lib.registerContext({
        id = 'menu_admin',
        title = '![logo]('..imageUrl..') Administração',
        description = 'Gerenciamento do servidor',
        options = options
    })

    lib.showContext('menu_admin')
end

function OpenManageMenu()
    -- Menu gerenciamento
    local options = {
        {
            title = 'Portas',
            description = 'Crie ou gerencie as trancas de portas e portões do servidor.',
            icon = 'door-closed',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                ExecuteCommand('doorlock')
            end
        },
        {
            title = 'Blips',
            description = 'Crie ou gerencie todos os blips, você pode copiar as configurações de um já criado.  ',
            icon = 'location-dot',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                ExecuteCommand('blip')
            end
        },
        {
            title = 'Baús',
            description = 'Crie ou gerencie os baús do servidor, você pode restringir por permissões ou senha.',
            icon = 'box',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                ExecuteCommand('bau')
            end
        },
        {
            title = 'NPC',
            description = 'Crie ou gerencie os NPCs do servidor, você pode colocar animações nos NPCs.',
            icon = 'users-gear',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                ExecuteCommand('npc')
            end
        },
        {
            title = 'Props',
            description = 'Crie ou gerencie os props criados do servidor, você pode editar e criar cenários.',
            icon = 'tree',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                ExecuteCommand('objectspawner')
            end
        },
        {
            title = 'Elevador',
            description = 'Crie ou gerencie os elevadores criados, você pode criar quantos andares forem necessários.',
            icon = 'elevator',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                ExecuteCommand('elevador')
            end
        },
        {
            title = 'Outdoors/Posters',
            description = 'Crie ou gerencie os outdoors ou imagens criados do servidor, você pode adicionar ou remover.',
            icon = 'panorama',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                MenuPosters()
            end
        },
        {
            title = 'Garagens',
            description = 'Crie ou gerencie as garagens criadas do servidor, você pode definir todas as opções in game.',
            icon = 'warehouse',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                ExecuteCommand('garagelist')
            end
        },
        {
            title = 'Crafting',
            description = 'Crie ou gerencie mesas de fabricação do servidor, você pode usar props para a mesa.',
            icon = 'tools',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                MenuCrafting()
            end
        },
        {
            title = 'Grupos',
            description = 'Crie ou gerencie grupos, trabalhos e facções (Jobs e Gangs) in game.',
            icon = 'briefcase',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                MenuJobs()
            end
        },
        {
            title = 'Spotlight',
            description = 'Crie ou gerencie luzes in game',
            icon = 'lightbulb',
            iconAnimation = 'fade',
            arrow = true,
            onSelect = function()
                MenuSpotlight()
            end
        }
    }

    -- Verificar se o resource 'mri_Qvinewood' foi iniciado
    if GetResourceState('mri_Qvinewood') == 'started' then
        options[#options + 1] = {
            title = 'Vinewood',
            description = 'Edite a sua placa de vinewood in game!',
            icon = 'fa-solid fa-cogs',
            iconAnimation = 'fade',
            onSelect = function()
                ExecuteCommand('vinewood')
            end
        }
    end

    for _,v in pairs(managementMenu) do
        options[#options + 1] = v
    end

    lib.registerContext({
        id = 'menu_gerencial',
        menu = 'menu_admin',
        title = 'Gerenciamento',
        options = options
    })

    lib.showContext('menu_gerencial')
end

function MenuPosters()
    lib.registerContext({
        id = 'menu_posters',
        menu = 'menu_gerencial',
        title = 'Gerenciar Posters',
        options = {
            {
                title = 'Criar poster',
                description = 'Criar um novo Poster.',
                icon = 'square-plus',
                iconAnimation = 'fade',
                arrow = false,
                onSelect = function()
                    ExecuteCommand('poster')
                end
            },
            {
                title = 'Edite ou exclua posters ao seu redor',
                description = 'IMPORTANTE: Ative e aproxime-se do poster',
                icon = 'list-check',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ExecuteCommand('draw_dev on')
                end
            },
        }
    })
    lib.showContext('menu_posters')
end

function MenuCrafting()
    lib.registerContext({
        id = 'menu_crafting',
        menu = 'menu_gerencial',
        title = 'Gerenciar Craftings',
        options = {
            {
                title = 'Criar nova mesa',
                description = 'Crie uma mesa de fabricação nova.',
                icon = 'square-plus',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ExecuteCommand('craft:create')
                end
            },
            {
                title = 'Ver lista',
                description = 'Veja todas as mesas de fabricação criadas.',
                icon = 'list',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ExecuteCommand('craft:edit')
                end
            },
        }
    })
    lib.showContext('menu_crafting')
end

function MenuJobs()
    lib.registerContext({
        id = 'menu_jobs',
        menu = 'menu_gerencial',
        title = 'Gerenciar Grupos',
        options = {
            {
                title = 'Criar novo grupo',
                description = 'Crie um job ou gang',
                icon = 'square-plus',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ExecuteCommand('createjob')
                end
            },
            {
                title = 'Ver lista',
                description = 'Veja todos grupos criados.',
                icon = 'list',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ExecuteCommand('open_jobs')
                end
            },
        }
    })
    lib.showContext('menu_jobs')
end

function MenuSpotlight()
    lib.registerContext({
        id = 'menu_spotlight',
        menu = 'menu_gerencial',
        title = 'Gerenciar Spotlights',
        options = {
            {
                title = 'Criar novo spotlight',
                description = 'Crie um spotlight.',
                icon = 'square-plus',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ExecuteCommand('spotlight')
                end
            },
            {
                title = 'Deletar',
                description = 'Delete algum spotlight',
                icon = 'x',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ExecuteCommand('spotlight 1')
                end
            },
        }
    })
    lib.showContext('menu_spotlight')
end

-- Callbacks
lib.callback.register('AbrirMenuAdmin', function()
    OpenAdminMenu()
end)

-- Keybinds
lib.addKeybind({
    name = 'menu_jogador_keybind',
    description = 'Pressione F9 para abrir o menu do jogador',
    defaultKey = 'F9',
    onPressed = AbrirMenuJogador
})

lib.addKeybind({
    name = 'menu_admin_keybind',
    description = 'Pressione F10 para abrir o menu de admin',
    defaultKey = 'F10',
    onPressed = function()
        ExecuteCommand('menu_admin')
    end
})
