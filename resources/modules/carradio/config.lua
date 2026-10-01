Mri.module({
    id = 'carradio',
    label = 'Rádio do carro',
    category = 'vehicles',
    description = 'O jogador liga e desliga o rádio do carro com /mri_carradio, e a escolha vale em todo veículo em que ele entrar.',
    defaults = {
        enabled = true,
        startMuted = false,
        key = '',
    },
    fields = {
        {
            key = 'startMuted',
            type = 'boolean',
            label = 'Começar com o rádio desligado',
            help = 'Vale pra quem entra no servidor depois de salvar',
        },
        {
            key = 'key',
            type = 'text',
            label = 'Tecla padrão',
            help = 'Ex.: F11. Vazio = sem tecla (cada jogador escolhe nas configurações do FiveM). Só vale pra quem ainda não escolheu, depois de reiniciar o mri_Qbox.',
        },
    },
})
