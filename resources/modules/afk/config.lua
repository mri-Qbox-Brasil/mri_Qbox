Mri.module({
    id = 'afk',
    label = 'Expulsar AFK',
    category = 'admin',
    description = 'Expulsa quem fica parado no mesmo ponto por tempo demais, com avisos antes. Os grupos da lista não são expulsos.',
    defaults = {
        enabled = false,
        seconds = 1000,
        exemptGroups = { 'mod', 'admin' },
    },
    fields = {
        { key = 'seconds', type = 'number', label = 'Tempo parado até expulsar', unit = 's', min = 60, max = 14400, step = 10 },
        { key = 'exemptGroups', type = 'list', itemType = 'text', label = 'Grupos que não são expulsos', help = 'Permissões do qbx_core, ex.: mod, admin.' },
    },
})
