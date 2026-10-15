Mri.module({
    id = 'tackle',
    label = 'Derrubar correndo',
    category = 'combat',
    description = 'Correndo, a tecla tackle (padrão E) derruba quem está logo à frente, como no qbx_tackle. Quem derruba também cai, por um instante.',
    defaults = {
        enabled = true,
        seconds = 7,
        key = 'E',
    },
    fields = {
        { key = 'seconds', type = 'number', label = 'Tempo no chão de quem é derrubado', unit = 's', min = 1, max = 30, step = 1 },
        { key = 'key', type = 'text', label = 'Tecla padrão', help = 'Ex.: E. Só vale pra quem ainda não escolheu nas configurações do FiveM, depois de reiniciar o mri_Qbox.' },
    },
})
