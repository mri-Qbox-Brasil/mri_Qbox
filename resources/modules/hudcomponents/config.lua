Mri.module({
    id = 'hudcomponents',
    label = 'Esconder HUD nativa',
    category = 'combat',
    description = 'Esconde partes da HUD do GTA: dinheiro, área e rua, nome e classe do veículo, roda e ícone da arma e, opcional, a mira.',
    defaults = {
        enabled = true,
        hideCash = true,
        hideLocation = true,
        hideVehicleInfo = true,
        hideWeapon = true,
        hideCrosshair = false,
    },
    fields = {
        { key = 'hideCash', type = 'boolean', label = 'Esconder dinheiro', help = 'O dinheiro do GTA e o aviso de quanto entrou ou saiu.' },
        { key = 'hideLocation', type = 'boolean', label = 'Esconder área e rua' },
        { key = 'hideVehicleInfo', type = 'boolean', label = 'Esconder nome e classe do veículo' },
        { key = 'hideWeapon', type = 'boolean', label = 'Esconder roda e ícone da arma', help = 'A tecla da roda (TAB) quem bloqueia é o ox_inventory.' },
        { key = 'hideCrosshair', type = 'boolean', label = 'Esconder a mira', help = 'Só em terceira pessoa; mirando em primeira pessoa a mira continua.' },
    },
})
