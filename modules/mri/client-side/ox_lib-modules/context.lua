local color = '#51CF66'
-- local imageUrl = 'https://media.discordapp.net/attachments/1227489601925550150/1236525641973764096/Brasil_96_x_96_px_2.png?ex=663f93fe&is=663e427e&hm=afd1c2a4814d090fd4312d39aaf90bc71991a38be3450f5b0c532743e19bec7f&=&format=webp&quality=lossless&width=24&height=24'
local imageUrl = 'https://cfx-nui-mri_Qbox/web-side/icones/logo24.png'

-- Função para abrir o menu do jogador
function AbrirMenuJogador()
    -- Registro do menu "Jogador"
    local PlayerData = QBX.PlayerData

    local playerData = {
        name = PlayerData.charinfo.firstname..' '..PlayerData.charinfo.lastname,
        id = PlayerData.citizenid,
        source = cache.serverId
    }
    local jobData = {
        label = PlayerData.job.label,
        grade = PlayerData.job.grade.name
    }
    local gangData = {
        label = PlayerData.gang.label,
        grade = PlayerData.gang.grade.name
    }

    lib.registerContext({
        id = 'menu_jogador',
        title = '![logo]('..imageUrl..') **mri Qbox Brasil**',
        options = {
            {
                title = 'Identificação',
                icon = 'fas fa-address-card',
                iconColor = color,
                iconAnimation = 'fade',
                description =   '**ID**: '..PlayerData.source..' | '..
                                '**RG**: '..PlayerData.citizenid..'                                                                                                '..
                                '**Nome**: '..playerData.name,
                onSelect = function()
                    ExecuteCommand('id')
                end
            },
            {
                title = 'Emprego',
                icon = 'fas fa-briefcase',
                iconColor = color,
                iconAnimation = 'fade',
                description = jobData.label..' | '..jobData.grade,
                onSelect = function()
                    ExecuteCommand('job')
                end
            },
            {
                title = 'Gangue',
                icon = 'gun',
                iconColor = color,
                iconAnimation = 'fade',
                description = gangData.label..' | '..gangData.grade,
                onSelect = function()
                    ExecuteCommand('gang')
                end
            },
            {
                title = 'Ver Habilidades',
                description = 'Exibir seu progresso em habilidades do servidor.',
                icon = 'book-tanakh',
                iconColor = color,
                iconAnimation = 'fade',
                arrow = true,
                -- menu = 'skill_menu',
                onSelect = function()
                    ExecuteCommand('rep')
                end
            }
        }
    })

    -- Exibe o menu do jogador
    lib.showContext('menu_jogador')
end

Citizen.CreateThread(function()
    -- Menu admin (F10)
    lib.registerContext({
        id = 'menu_admin',
        title = '![logo]('..imageUrl..') **Administração**',
        options = {
            {
                title = 'Abrir Painel',
                description = 'Painel da Administração do Servidor',
                icon = 'fa-solid fa-user-tie',
                iconColor = color,
                iconAnimation = 'fade',
                onSelect = function()
                    ExecuteCommand('adm')
                end
            },
            {
                title = 'Customizar Veículo',
                description = 'Tune seu veículo atual',
                icon = 'palette',
                iconColor = color,
                iconAnimation = 'fade',
                onSelect = function()
                    ExecuteCommand('customs')
                end
            },
            {
                title = 'Gerenciamento',
                description = 'Acesso a opções de gerenciamento do servidor',
                icon = 'fa-solid fa-cogs',
                iconColor = color,
                iconAnimation = 'fade',
                menu = 'menu_gerencial'
            }
        }
    })

    -- Menu gerenciamento
    lib.registerContext({
        id = 'menu_gerencial',
        menu = 'menu_admin',
        title = '**Gerenciamento**',
        options = {
            {
                title = 'Portas',
                description = 'Crie ou gerencie as trancas de portas e portões do servidor.',
                icon = 'door-closed',
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    MenuCrafting()
                end
            },
            {
                title = 'Jobs',
                description = 'Crie ou gerencie jobs in game.',
                icon = 'briefcase',
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
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
        title = 'Gerenciar Jobs',
        options = {
            {
                title = 'Criar novo job',
                description = 'Crie um job.',
                icon = 'square-plus',
                iconColor = color,
                iconAnimation = 'fade',
                arrow = true,
                onSelect = function()
                    ExecuteCommand('createjob')
                end
            },
            {
                title = 'Ver lista',
                description = 'Veja todos jobs criados.',
                icon = 'list',
                iconColor = color,
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
                iconColor = color,
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
                iconColor = color,
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