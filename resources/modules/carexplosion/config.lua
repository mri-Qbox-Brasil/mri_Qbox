Mri.module({
    id = 'carexplosion',
    label = 'Explosão em queda',
    category = 'vehicles',
    description = 'O carro explode ao cair de uma altura.',
    defaults = {
        enabled = false,
        height = 40,
    },
    fields = {
        {
            key = 'height',
            type = 'number',
            label = 'Altura da queda',
            min = 5,
            max = 500,
            unit = 'm',
        },
    },
})
