Mri.module({
    id = 'vip',
    label = 'VIP',
    category = 'admin',
    description = 'Tiers de VIP com permissão ACE, peso do inventário e salário periódico. Gerência pelo F10 e pelo /vipadm.',
    defaults = {
        enabled = false,
        paycheckInterval = 30,
        cashType = 'bank',
        coinType = 'R$',
        roles = {
            nenhum = {
                label = 'Sem vip',
                payment = 0,
                inventory = 100,
            },
            tier1 = {
                label = 'Tier 1',
                payment = 5000,
                inventory = 200,
            },
        },
    },
    fields = {
        {
            key = 'paycheckInterval',
            type = 'number',
            label = 'Intervalo do salário',
            min = 0,
            max = 1440,
            unit = 'min',
            help = '0 desliga o salário',
        },
        {
            key = 'cashType',
            type = 'select',
            label = 'Conta do salário',
            options = {
                {
                    value = 'money',
                    label = 'Dinheiro',
                },
                {
                    value = 'bank',
                    label = 'Banco',
                },
                {
                    value = 'crypto',
                    label = 'Crypto',
                },
            },
        },
        {
            key = 'coinType',
            type = 'text',
            label = 'Símbolo da moeda',
        },
        {
            key = 'roles',
            type = 'json',
            label = 'Tiers',
            help = 'id do tier -> { label, payment (salário), inventory (kg) }. O tier "nenhum" é quem não tem VIP.',
        },
    },
})
