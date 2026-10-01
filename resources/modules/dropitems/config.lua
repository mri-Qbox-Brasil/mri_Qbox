Mri.module({
    id = 'dropitems',
    label = 'Item no chão vira prop',
    category = 'inventory',
    description = 'Item largado no chão aparece como o prop dele.',
    defaults = {
        enabled = false,
        props = {
            money = 'prop_cash_pile_02',
            burger = 'prop_cs_burger_01',
            water = 'prop_ld_flow_bottle',
            speaker = 'gordela_boombox3',
            phone = 'prop_phone_ing_02_lod',
            WEAPON_MINISMG = 'w_sb_minismg',
            ['ammo-9'] = 'prop_ld_ammo_pack_01',
            ['ammo-rifle'] = 'prop_ld_ammo_pack_03',
            ['ammo-rifle2'] = 'prop_ld_ammo_pack_02',
        },
    },
    fields = {
        {
            key = 'props',
            type = 'map',
            itemType = 'text',
            label = 'Item e prop',
            help = 'Nome do item -> modelo do prop',
        },
    },
})
