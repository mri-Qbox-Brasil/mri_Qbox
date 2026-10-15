Mri.module({
    id = 'gtaweapons',
    label = 'Armas do GTA',
    category = 'combat',
    description = 'NPC morto não solta arma, ninguém pega do chão a arma que o GTA solta, sem coronhada e extintor e galão de gasolina sem acabar.',
    defaults = {
        enabled = true,
        noNpcDrops = true,
        blockPickups = true,
        noPistolWhip = true,
        infiniteUtility = true,
    },
    fields = {
        { key = 'noNpcDrops', type = 'boolean', label = 'NPC morto não solta arma' },
        { key = 'blockPickups', type = 'boolean', label = 'Bloquear arma do chão', help = 'Ninguém pega do chão a arma que o GTA solta.' },
        { key = 'noPistolWhip', type = 'boolean', label = 'Sem coronhada', help = 'Com arma de fogo na mão, o botão de soco não bate com a arma.' },
        { key = 'infiniteUtility', type = 'boolean', label = 'Extintor e galão sem acabar' },
    },
})
