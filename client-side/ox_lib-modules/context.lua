
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
    
    local imageUrl = 'https://media.discordapp.net/attachments/1227489601925550150/1236525641973764096/Brasil_96_x_96_px_2.png?ex=663853be&is=6637023e&hm=5cd23b016faf02f1b3fc70018f603562ef88526e3a21deeffecfc6f2f4e2c2ab&=&format=webp&quality=lossless&width=24&height=24'
    lib.registerContext({
        id = 'menu_jogador',
        title = '![logo]('..imageUrl..') mri Qbox Brasil',
        options = {
            {
                title = 'Identificação',
                icon = 'fas fa-address-card',
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
                description = jobData.label..' | '..jobData.grade,
                onSelect = function()
                    ExecuteCommand('job')
                end
            },
            {
                title = 'Gangue',
                icon = 'gun',
                description = gangData.label..' | '..gangData.grade,
                onSelect = function()
                    ExecuteCommand('gang')
                end
            },
            {
                title = 'Ver Habilidades',
                description = 'Exibir seu progresso em habilidades do servidor.',
                icon = 'book-tanakh',
                menu = 'skill_menu',
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
        title = 'Administração',
        options = {
            {
                title = 'Abrir Painel',
                description = 'Painel da Administração do Servidor',
                icon = 'fa-solid fa-user-tie',

                onSelect = function()
                    ExecuteCommand('adm')
                end
            },
            {
                title = 'Customizar Veículo',
                description = 'Tune seu veículo atual',
                icon = 'palette',
                onSelect = function()
                    ExecuteCommand('customs')
                end
            },
            {
                title = 'Gerenciamento',
                description = 'Acesso a opções de gerenciamento do servidor',
                icon = 'fa-solid fa-cogs',
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
                title = 'Criar Portas',
                description = 'Gerencie as Portas criadas',
                icon = 'door-closed',
                onSelect = function()
                    ExecuteCommand('doorlock')
                end
            },
            {
                title = 'Criar Blips',
                description = 'Gerencie os blips criados',
                icon = 'location-dot',
                onSelect = function()
                    ExecuteCommand('blip')
                end
            },
            {
                title = 'Criar Baú',
                description = 'Gerencie os baús criados',
                icon = 'box',
                onSelect = function()
                    ExecuteCommand('bau')
                end
            },
            {
                title = 'Criar NPC',
                description = 'Gerencie os NPCs criados',
                icon = 'users-gear',
                onSelect = function()
                    ExecuteCommand('npc')
                end
            },
            {
                title = 'Criar Props',
                description = 'Gerencie os props criados',
                icon = 'tree',
                onSelect = function()
                    ExecuteCommand('objectspawner')
                end
            },
            {
                title = 'Criar Elevador',
                description = 'Gerencie os elevadores criados',
                icon = 'elevator',
                onSelect = function()
                    ExecuteCommand('elevador')
                end
            },
            {
                title = 'Criar Outdoors/Posters',
                description = 'Gerencie as imagens criadas',
                icon = 'panorama',
                onSelect = function()
                    ExecuteCommand('poster')
                end
            }
        }
    })
end)

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