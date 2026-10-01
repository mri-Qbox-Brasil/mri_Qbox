Mri.module({
    id = 'vehiclefirstperson',
    label = 'Primeira pessoa armado no carro',
    category = 'combat',
    description = 'O motorista armado vai pra primeira pessoa.',
    defaults = {
        enabled = false,
        holdOnly = false,
    },
    fields = {
        {
            key = 'holdOnly',
            type = 'boolean',
            label = 'Só segurando a mira',
            help = 'Desligado: fica em primeira pessoa enquanto estiver armado',
        },
    },
})
