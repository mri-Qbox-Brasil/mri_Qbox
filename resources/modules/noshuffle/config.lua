Mri.module({
    id = 'noshuffle',
    label = 'Sem pular de banco',
    category = 'vehicles',
    description = 'Quem entra no banco do passageiro não pula sozinho pro do motorista. Pra trocar de banco de propósito, a tecla shuffleSeat (padrão O), menos algemado ou de cinto.',
    defaults = {
        enabled = true,
        key = 'O',
    },
    fields = {
        { key = 'key', type = 'text', label = 'Tecla padrão', help = 'Ex.: O. Só vale pra quem ainda não escolheu nas configurações do FiveM, depois de reiniciar o mri_Qbox.' },
    },
})
