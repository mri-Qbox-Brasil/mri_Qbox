Mri.module({
    id = 'gtaservices',
    label = 'Serviços do GTA',
    category = 'world',
    description = 'Desliga os bombeiros, a ambulância, as gangues e o exército que o GTA manda sozinho. A polícia fica no módulo Polícia do GTA.',
    defaults = {
        enabled = true,
        fire = false,
        ambulance = false,
        gangs = false,
        army = false,
    },
    fields = {
        { key = 'fire', type = 'boolean', label = 'Bombeiros do GTA' },
        { key = 'ambulance', type = 'boolean', label = 'Ambulância do GTA' },
        { key = 'gangs', type = 'boolean', label = 'Gangues de reforço do GTA' },
        { key = 'army', type = 'boolean', label = 'Exército do GTA' },
    },
})
