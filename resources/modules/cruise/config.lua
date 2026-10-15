Mri.module({
    id = 'cruise',
    label = 'Piloto automático',
    category = 'vehicles',
    description = 'Controle de cruzeiro do qbx_cruise: o motorista mantém a velocidade atual com a tecla toggle_cruise_control (padrão Y). Apertar de novo ou perder velocidade sem frear nem virar desliga.',
    defaults = {
        enabled = true,
        key = 'Y',
    },
    fields = {
        { key = 'key', type = 'text', label = 'Tecla padrão', help = 'Ex.: Y. Só vale pra quem ainda não escolheu nas configurações do FiveM, depois de reiniciar o mri_Qbox.' },
    },
})
