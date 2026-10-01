Mri.module({
    id = 'hudcomponents',
    label = 'Esconder HUD nativa',
    category = 'combat',
    description = 'Esconde nome do veículo, área, classe e rua da HUD do GTA e, opcional, a mira.',
    defaults = {
        enabled = true,
        hideCrosshair = false,
    },
    fields = {
        {
            key = 'hideCrosshair',
            type = 'boolean',
            label = 'Esconder a mira',
        },
    },
})
