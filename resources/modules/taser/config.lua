Mri.module({
    id = 'taser',
    label = 'Tempo no chão do taser',
    category = 'combat',
    description = 'Quanto tempo quem leva taser fica no chão, sorteado entre o mínimo e o máximo a cada choque.',
    defaults = {
        enabled = true,
        minSeconds = 4,
        maxSeconds = 7,
    },
    fields = {
        { key = 'minSeconds', type = 'number', label = 'Mínimo', unit = 's', min = 0, max = 60, step = 1 },
        { key = 'maxSeconds', type = 'number', label = 'Máximo', unit = 's', min = 0, max = 60, step = 1 },
    },
})
