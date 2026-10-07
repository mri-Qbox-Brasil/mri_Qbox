local function density(key, label, help)
    return { key = key, type = 'number', label = label, help = help, min = 0, max = 1, step = 0.05 }
end

Mri.module({
    id = 'density',
    label = 'Densidade',
    category = 'world',
    description = 'Quantidade de carros e pedestres do GTA, NPCs que não atacam o jogador e veículos parados em aeroporto e base militar (ex qbx_density).',
    defaults = {
        enabled = true,
        empty = false,
        parked = 0.8,
        vehicle = 0.8,
        randomVehicles = 0.8,
        peds = 0.8,
        scenario = 0.8,
        npcRespect = true,
        blockGenerators = true,
    },
    fields = {
        { key = 'empty', type = 'boolean', label = 'Cidade vazia', help = 'Tira todos os carros e NPCs do GTA, sem mexer nos valores abaixo.' },
        density('parked', 'Carros estacionados', '0 tira todos, 1 é o padrão do GTA Online.'),
        density('vehicle', 'Carros no trânsito', '0 tira todos, 1 é o padrão do GTA Online.'),
        density('randomVehicles', 'Carros aleatórios', '0 tira todos, 1 é o padrão do GTA Online.'),
        density('peds', 'Pedestres', '0 tira todos, 1 é o padrão do GTA Online.'),
        density('scenario', 'NPCs de cenário', 'Motoqueiros, gangues e quem fica parado fazendo alguma coisa. 0 tira todos.'),
        { key = 'npcRespect', type = 'boolean', label = 'NPCs não atacam o jogador', help = 'Gangues, polícia, bombeiros, médicos e presos do GTA deixam o jogador em paz.' },
        { key = 'blockGenerators', type = 'boolean', label = 'Sem veículos parados em aeroporto e base militar', help = 'O GTA não deixa aviões, veículos do aeroporto e da base militar parados pra qualquer um pegar.' },
    },
})
