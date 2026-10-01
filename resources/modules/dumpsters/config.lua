Mri.module({
    id = 'dumpsters',
    label = 'Lixeiras',
    category = 'interaction',
    description = 'Pelo olhinho: esconder dentro da lixeira e vasculhar (abre o inventário dela).',
    defaults = {
        enabled = true,
        hideModels = { 218085040, 666561306, -58485588, -206690185, 1511880420, 682791951 },
        searchModels = {
            218085040,
            666561306,
            -58485588,
            -206690185,
            1511880420,
            682791951,
            -1426008804,
        },
    },
    fields = {
        {
            key = 'hideModels',
            type = 'list',
            itemType = 'number',
            label = 'Lixeiras pra se esconder',
            help = 'Hash do modelo',
        },
        {
            key = 'searchModels',
            type = 'list',
            itemType = 'number',
            label = 'Lixeiras pra vasculhar',
            help = 'Hash do modelo',
        },
    },
})
