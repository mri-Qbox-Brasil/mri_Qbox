local ColorScheme = {
    success = '#51CF66',
    info = '#668CFF',
    warning = '#FFD700',
    danger = '#FF6347'
}
GlobalState:set('UIColors', ColorScheme, true)
local imageUrl = 'https://cfx-nui-mri_Qbox/web-side/icones/logo24.png'

local function GetPlayerInformation(data)
    return '**ID**: '..data.source..' | '..
    '**RG**: '..data.citizenid..'                                                                                                '..
    '**Nome**: '..data.name
end

local function AddPlayerMenuItem(table, title, icon, iconAnimation, description, onSelectFunction, onSelectArg)
    return {
        title = title,
        icon = icon,
        iconAnimation = iconAnimation,
        description = description,
        onSelect = function()
            onSelectFunction(onSelectArg)
        end
    }
end

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
    table.insert(options, AddPlayerMenuItem('Identificação', 'fas fa-address-card', 'fade', GetPlayerInformation(PlayerData), ExecuteCommand, 'id'))
    table.insert(options, AddPlayerMenuItem('Emprego', 'fas fa-briefcase', 'fade', jobData.label..' | '..jobData.grade, ExecuteCommand, 'job'))
    if PlayerData.job.isboss then
        table.insert(options, AddPlayerMenuItem('Gerenciar Emprego', 'users', 'fade', 'Configurações do Emprego.', ExecuteCommand, '+tablet:job'))
    end
    table.insert(options, AddPlayerMenuItem('Gangue', 'gun', 'fade', gangData.label..' | '..gangData.grade, ExecuteCommand, 'gang'))
    if PlayerData.gang.isboss then
        table.insert(options, AddPlayerMenuItem('Gerenciar Gangue', 'users', 'fade', 'Configurações da gangue.', ExecuteCommand, '+tablet:gang'))
    end
    table.insert(options, AddPlayerMenuItem('Ver Reputação', 'book', 'fade', 'Exibir o nível de reputação do seu personagem.', ExecuteCommand, 'rep'))
    table.insert(options, AddPlayerMenuItem('Ver Habilidades', 'book', 'fade', 'Exibir o nível de habilidades do seu personagem.', ExecuteCommand, 'skill'))
    table.insert(options, AddPlayerMenuItem('Waypoints', 'location-dot', 'fade', 'Configurações do sistema de waypoints (ponto de referência).', ExecuteCommand, 'waypointsettings'))

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

Citizen.CreateThread(function()
    -- Menu admin (F10)
    lib.registerContext({
        id = 'menu_admin',
        title = '![logo]('..imageUrl..') Administração',
        description = 'Gerenciamento do servidor',
        options = {
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
                menu = 'menu_gerencial'
            }
        }
    })

    -- Menu gerenciamento
    lib.registerContext({
        id = 'menu_gerencial',
        menu = 'menu_admin',
        title = 'Gerenciamento',
        options = {
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
                    ExecuteCommand('poster')
                end
            },
            {
                title = 'Garagens',
                description = 'Crie ou gerencie as garagens criadas do servidor, você pode definir todas as opções in game.',
                icon = 'warehouse',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    MenuGarages()
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
    })
end)

function MenuGarages()
    lib.registerContext({
        id = 'menu_garages',
        menu = 'menu_gerencial',
        title = 'Gerenciar Garagens',
        options = {
            {
                title = 'Criar garagem',
                description = 'Crie uma nova garagem.',
                icon = 'square-plus',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ExecuteCommand('creategarage')
                end
            },
            {
                title = 'Ver lista',
                description = 'Veja todas as garagens criadas.',
                icon = 'list',
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ExecuteCommand('listgarage')
                end
            },
        }
    })
    lib.showContext('menu_garages')
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
    lib.showContext('menu_admin')
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