Mri.module({
    id = 'clearparking',
    label = 'Áreas sem carro estacionado',
    category = 'world',
    description = 'O GTA não estaciona carro nessas áreas (hospitais, delegacias e outros pontos onde carro parado atrapalha).',
    defaults = {
        enabled = true,
        clearGenerators = {
            { label = 'Hospital central', x = 335.26, y = -1432.46, z = 46.51, radius = 300 },
            { label = 'Delegacia Mission Row', x = 441.85, y = -987.99, z = 30.68, radius = 500 },
            { label = 'Pillbox', x = 316.79, y = -592.36, z = 43.28, radius = 300 },
            { label = 'Praia de nudismo', x = -1108.35, y = 4920.64, z = 217.2, radius = 300 },
            { label = 'Delegacia Paleto', x = -458.24, y = 6019.81, z = 31.34, radius = 300 },
            { label = 'Delegacia Sandy', x = 1854.82, y = 3679.4, z = 33.82, radius = 300 },
            { label = 'Helicópteros de Vespucci', x = -724.46, y = -1444.03, z = 5.0, radius = 300 },
        },
    },
    fields = {
        { key = 'clearGenerators', type = 'json', label = 'Áreas sem carro estacionado', help = 'Lista de { label, x, y, z, radius }: o GTA não estaciona carro nessas áreas.' },
    },
})
