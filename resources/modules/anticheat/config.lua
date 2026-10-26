Mri.module({
    id = 'anticheat',
    label = 'Anticheat',
    category = 'admin',
    description = 'Veículos e peds proibidos: o servidor cancela na hora quem tentar criar, inclusive script de garagem. Proteção contra menu de cheat.',
    defaults = {
        enabled = true,
        blockedModels = {
            'SHAMAL', 'LUXOR', 'LUXOR2', 'JET', 'LAZER', 'BUZZARD', 'BUZZARD2', 'ANNIHILATOR', 'SAVAGE', 'TITAN', 'RHINO',
            'FIRETRUK', 'MULE', 'MAVERICK', 'BLIMP', 'AIRTUG', 'CAMPER', 'HYDRA', 'OPPRESSOR', 'technical3', 'insurgent3',
            'apc', 'tampa3', 'trailersmall2', 'halftrack', 'hunter', 'vigilante', 'akula', 'barrage', 'khanjali', 'caracara',
            'blimp3', 'menacer', 'oppressor2', 'scramjet', 'strikeforce', 'cerberus', 'cerberus2', 'cerberus3', 'scarab',
            'scarab2', 'scarab3', 'rrocket', 'ruiner2', 'deluxo',
        },
    },
    fields = {
        { key = 'blockedModels', type = 'list', itemType = 'text', label = 'Veículos e peds proibidos', help = 'O servidor cancela na hora quem tentar criar, inclusive script de garagem. Proteção contra menu de cheat.' },
    },
})
