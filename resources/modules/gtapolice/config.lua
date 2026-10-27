Mri.module({
    id = 'gtapolice',
    label = 'Polícia NPC',
    category = 'world',
    description = 'Tudo da polícia que o GTA manda sozinho: viaturas, policiais a pé, barreiras, rádio, nível e estrelas de procurado. Desligue o módulo pra polícia do GTA voltar como no jogo normal.',
    defaults = {
        enabled = true,
        police = false,
        roadblock = true,
        parkedCars = false,
        maxWantedLevel = 0,
        hideWanted = true,
        respectPlayer = true,
    },
    fields = {
        { key = 'police', type = 'boolean', label = 'Polícia do GTA', help = 'Viaturas, helicópteros, SWAT, policiais a pé e rádio da polícia. Desligada, o GTA não cria policial nenhum. Policial de script (como a Polícia NPC da Cidade viva) continua aparecendo.' },
        { key = 'roadblock', type = 'boolean', label = 'Barreiras da polícia do GTA' },
        { key = 'parkedCars', type = 'boolean', label = 'Viaturas e motos paradas do GTA', help = 'As que o GTA deixa nas delegacias e na rua.' },
        { key = 'maxWantedLevel', type = 'number', label = 'Nível máximo de procurado', help = '0 = nunca fica procurado.', min = 0, max = 5, step = 1 },
        { key = 'hideWanted', type = 'boolean', label = 'Esconder estrelas de procurado' },
        { key = 'respectPlayer', type = 'boolean', label = 'Polícia do GTA não ataca o jogador' },
    },
})
