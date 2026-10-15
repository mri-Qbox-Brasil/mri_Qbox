local BURGER_STRESS = { min = 1, max = 4 }

Mri.module({
    id = 'consumables',
    label = 'Consumíveis',
    category = 'inventory',
    description = 'O qbx_consumables no painel: comida, bebida e álcool (fome, sede e estresse sorteados entre o mínimo e o máximo), drogas, lockpick e a garrafa vazia depois da água.',
    defaults = {
        enabled = true,
        drugs = true,
        lockpick = true,
        emptyBottle = true,
        defaultStressRelief = { min = 0, max = 4 },
        food = {
            sandwich = { min = 35, max = 54, stressRelief = BURGER_STRESS },
            tosti = { min = 40, max = 50, stressRelief = BURGER_STRESS },
            twerks_candy = { min = 35, max = 54, stressRelief = BURGER_STRESS },
            snikkel_candy = { min = 40, max = 50, stressRelief = BURGER_STRESS },
        },
        drink = {
            water_bottle = { min = 35, max = 54, stressRelief = BURGER_STRESS },
            kurkakola = { min = 35, max = 54, stressRelief = BURGER_STRESS },
            coffee = {
                min = 40,
                max = 50,
                anim = { clip = 'idle_c', dict = 'amb@world_human_drinking@coffee@male@idle_a', flag = 49 },
                prop = { model = 'p_amb_coffeecup_01', bone = 28422, pos = { x = 0.0, y = 0.0, z = 0.0 }, rot = { x = 0.0, y = 0.0, z = 0.0 } },
                stressRelief = { min = -10, max = -1 },
            },
        },
        alcohol = {
            whiskey = { min = 20, max = 30, stressRelief = BURGER_STRESS },
            beer = { min = 30, max = 40, stressRelief = BURGER_STRESS, alcoholLevel = 0.25 },
            vodka = { min = 20, max = 40, stressRelief = BURGER_STRESS },
        },
    },
    fields = {
        { key = 'food', type = 'json', label = 'Comidas', help = 'Item: { min, max, stressRelief = { min, max }, anim?, prop? }. Fome sorteada entre min e max; estresse negativo aumenta.' },
        { key = 'drink', type = 'json', label = 'Bebidas', help = 'Item: { min, max, stressRelief = { min, max }, anim?, prop? }. Sede sorteada entre min e max.' },
        { key = 'alcohol', type = 'json', label = 'Bebidas alcoólicas', help = 'Item: { min, max, stressRelief, alcoholLevel? }. alcoholLevel soma no contador de álcool (padrão 1).' },
        { key = 'defaultStressRelief', type = 'json', label = 'Alívio de estresse padrão', help = '{ min, max } usado quando o item não diz.' },
        { key = 'drugs', type = 'boolean', label = 'Drogas', help = 'Baseado, cocaína, crack, ecstasy, oxy e metanfetamina.' },
        { key = 'lockpick', type = 'boolean', label = 'Lockpick', help = 'Usar o lockpick ou o lockpick avançado dispara o evento lockpicks:UseLockpick (mri_Qcarkeys, qbx_houserobbery).' },
        { key = 'emptyBottle', type = 'boolean', label = 'Garrafa vazia', help = 'Beber a garrafa de água devolve uma garrafa vazia.' },
    },
})
