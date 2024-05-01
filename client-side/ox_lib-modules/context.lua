-- Função para abrir o menu do jogador
function AbrirMenuJogador()
    -- Registro do menu "Jogador"
    lib.registerContext({
        id = 'menu_jogador',
        title = 'Jogador',
        options = {
            {
                title = 'Ver ID',
                icon = 'id-badge',
                description = 'Exibir seu ID de jogador.',
                onSelect = function()
                    ExecuteCommand('id')
                end
            },
            {
                title = 'Ver Emprego',
                icon = 'user-shield',
                description = 'Exibir dados do seu emprego.',
                onSelect = function()
                    ExecuteCommand('job')
                end
            },
            {
                title = 'Ver Facção',
                icon = 'gun',
                description = 'Exibir dados da sua facção.',
                onSelect = function()
                    ExecuteCommand('gang')
                end
            },
            {
                title = 'Ver Habilidades',
                description = 'Exibir seu progresso em habilidades do servidor.',
                icon = 'book-tanakh',
                onSelect = function()
                    ExecuteCommand('rep')
                end
            }
        }
    })

    -- Exibe o menu do jogador
    lib.showContext('menu_jogador')
end

-- Função para abrir o menu de opções de administração
function AbrirMenuAdmin()
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

    -- Exibe o menu do jogador
    lib.showContext('menu_admin')
end

lib.callback.register('AbrirMenuAdmin', function()
    AbrirMenuAdmin()
end)

-- Registro do keybind para abrir o menu do jogador ao pressionar F9
local menuKeybind = lib.addKeybind({
    name = 'menu_jogador_keybind',
    description = 'Pressione F9 para abrir o menu do jogador',
    defaultKey = 'F9',
    onPressed = AbrirMenuJogador
})

-- Registro do keybind para abrir o menu da administração ao pressionar F10
local menuKeybind = lib.addKeybind({
    name = 'menu_admin_keybind',
    description = 'Pressione F10 para abrir o menu de admin',
    defaultKey = 'F10',
    onPressed = function()
        ExecuteCommand('menu_admin')
    end
})