Mri.module({
    id = 'passport',
    label = 'Passaporte',
    category = 'admin',
    description = 'Número fixo de cada personagem, como o passaporte do creative e do vRP. Não muda quando o jogador reconecta e não é reaproveitado.',
    defaults = {
        enabled = true,
        commands = false,
    },
    fields = {
        {
            key = 'commands',
            type = 'boolean',
            label = 'Comandos usam o passaporte',
            help = 'Os comandos com jogador (/tp, /revive, /kick, /ban...) passam a pedir o passaporte no lugar do id do servidor. "me" continua valendo.',
        },
    },
})
