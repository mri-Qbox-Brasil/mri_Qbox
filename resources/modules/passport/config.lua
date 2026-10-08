Mri.module({
    id = 'passport',
    label = 'Passaporte',
    category = 'admin',
    page = 'passport',
    description = 'Número fixo de cada personagem, como o passaporte do creative e do vRP. Não muda quando o jogador reconecta e não é reaproveitado.',
    defaults = {
        enabled = false,
        commands = false,
        firstPassport = 1,
    },
    fields = {
        {
            key = 'firstPassport',
            type = 'number',
            label = 'Primeiro passaporte',
            help = 'Personagens novos começam neste número. Os números abaixo ficam reservados pra dar ou vender no botão Gerenciar.',
            min = 1,
            max = 1000000,
        },
        {
            key = 'commands',
            type = 'boolean',
            label = 'Comandos usam o passaporte',
            help = 'Os comandos com jogador (/tp, /revive, /kick, /ban...) passam a pedir o passaporte no lugar do id do servidor. "me" continua valendo.',
        },
    },
})
