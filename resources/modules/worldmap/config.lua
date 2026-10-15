Mri.module({
    id = 'worldmap',
    label = 'Mapa',
    category = 'world',
    description = 'Ajustes do mapa do GTA: câmera parada, som ambiente, caminhão de lixo, cenários, veículos do trânsito e sons fixos.',
    defaults = {
        enabled = true,
        disableIdleCamera = true,
        disableAmbience = true,
        garbageTrucks = false,
        scenarioTypes = {
            'WORLD_VEHICLE_AMBULANCE', 'WORLD_VEHICLE_FIRE_TRUCK', 'WORLD_VEHICLE_POLICE_BIKE', 'WORLD_VEHICLE_POLICE_CAR',
            'WORLD_VEHICLE_POLICE', 'WORLD_VEHICLE_POLICE_NEXT_TO_CAR', 'WORLD_VEHICLE_SECURITY_CAR',
            'WORLD_VEHICLE_HELI_LIFEGUARD', 'WORLD_VEHICLE_MILITARY_PLANES_BIG', 'WORLD_VEHICLE_MILITARY_PLANES_SMALL',
        },
        scenarioGroups = { 'LSA_Planes', 'SANDY_PLANES', 'GRAPESEED_PLANES', 'ng_planes' },
        suppressedModels = { 'SHAMAL', 'LUXOR', 'LUXOR2', 'JET', 'LAZER', 'TITAN', 'CRUSADER', 'RHINO', 'AIRTUG', 'RIPLEY', 'BLIMP' },
        disabledEmitters = {},
    },
    fields = {
        { key = 'disableIdleCamera', type = 'boolean', label = 'Sem câmera parada', help = 'A câmera não começa a girar sozinha quando o jogador fica parado.' },
        { key = 'disableAmbience', type = 'boolean', label = 'Sem som ambiente', help = 'Tira sirenes e alarmes de carro ao longe.' },
        { key = 'garbageTrucks', type = 'boolean', label = 'Caminhão de lixo do GTA' },
        { key = 'scenarioTypes', type = 'list', itemType = 'text', label = 'Cenários desligados', help = 'Tipos de cenário do GTA, ex.: WORLD_VEHICLE_POLICE_CAR.' },
        { key = 'scenarioGroups', type = 'list', itemType = 'text', label = 'Grupos de cenário desligados', help = 'Ex.: LSA_Planes (aviões do aeroporto).' },
        { key = 'suppressedModels', type = 'list', itemType = 'text', label = 'Veículos fora do trânsito', help = 'Modelos que o GTA não gera no trânsito, ex.: LAZER.' },
        { key = 'disabledEmitters', type = 'list', itemType = 'text', label = 'Sons fixos desligados', help = 'Nome do som fixo do mapa (rádio de bar, loja), ex.: se_ba_dlc_int_01_bars.' },
    },
})
