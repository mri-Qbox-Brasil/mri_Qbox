Mri.module({
    id = 'drift',
    label = 'Drift no Shift',
    category = 'vehicles',
    description = 'Segurando Shift o carro perde aderência pra driftar, até a velocidade máxima.',
    defaults = {
        enabled = true,
        speed = 80,
    },
    fields = {
        {
            key = 'speed',
            type = 'number',
            label = 'Velocidade máxima',
            min = 0,
            max = 400,
            unit = 'km/h',
        },
    },
})
