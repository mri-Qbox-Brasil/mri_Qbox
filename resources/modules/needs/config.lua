local RATE_HELP = 'Pontos que caem a cada ciclo do qbx_core (updateInterval, 5 minutos no padrão), de 0 a 100. Padrão do qbx_core: %s.'

Mri.module({
    id = 'needs',
    label = 'Necessidades',
    category = 'world',
    description = 'Liga e desliga fome, sede e estresse e ajusta quanto a fome e a sede caem. Desligada, a fome e a sede ficam cheias e o estresse fica em zero.',
    defaults = {
        enabled = true,
        hunger = true,
        hungerRate = 4.2,
        thirst = true,
        thirstRate = 3.8,
        stress = true,
    },
    fields = {
        { key = 'hunger', type = 'boolean', label = 'Fome', help = 'Desligada, a fome fica sempre cheia e nunca tira vida.' },
        { key = 'hungerRate', type = 'number', label = 'Quanto a fome cai', help = RATE_HELP:format('4,2'), min = 0, max = 50, step = 0.1 },
        { key = 'thirst', type = 'boolean', label = 'Sede', help = 'Desligada, a sede fica sempre cheia e nunca tira vida.' },
        { key = 'thirstRate', type = 'number', label = 'Quanto a sede cai', help = RATE_HELP:format('3,8'), min = 0, max = 50, step = 0.1 },
        { key = 'stress', type = 'boolean', label = 'Estresse', help = 'Desligado, o estresse fica em zero: sem ganho, sem aviso e sem tremor de tela.' },
    },
})
