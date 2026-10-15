Mri.module({
    id = 'flipvehicle',
    label = 'Desvirar veículo',
    category = 'vehicles',
    description = 'Desvira um veículo capotado, com barra de progresso: pelo olhinho, a pé, ou pelo export FlipVehicle do qbx_smallresources.',
    defaults = {
        enabled = true,
        seconds = 15,
        maxDistance = 2,
    },
    fields = {
        { key = 'seconds', type = 'number', label = 'Tempo pra desvirar', unit = 's', min = 1, max = 120, step = 1 },
        { key = 'maxDistance', type = 'number', label = 'Distância máxima do veículo', unit = 'm', min = 1, max = 10, step = 0.5 },
    },
})
