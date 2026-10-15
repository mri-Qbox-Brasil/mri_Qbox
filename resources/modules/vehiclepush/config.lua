Mri.module({
    id = 'vehiclepush',
    label = 'Empurrar veículo',
    category = 'vehicles',
    description = 'Como no qbx_vehiclepush: a pé, segurando Shift e E perto de um veículo sem motorista, empurra; A e D viram as rodas e soltar o Shift para.',
    defaults = {
        enabled = true,
        damageNeeded = 1000.0,
        blacklistedClasses = { 13, 14, 15, 16 },
    },
    fields = {
        { key = 'damageNeeded', type = 'number', label = 'Vida do motor pra poder empurrar', help = '0 a 1000. 1000 = qualquer veículo; sem gasolina sempre pode.', min = 0, max = 1000, step = 10 },
        { key = 'blacklistedClasses', type = 'list', itemType = 'number', label = 'Classes que não empurram', help = '13 bicicleta, 14 barco, 15 helicóptero, 16 avião.' },
    },
})
