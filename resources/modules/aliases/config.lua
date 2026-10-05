Mri.module({
    id = 'aliases',
    label = 'Atalhos de comando',
    category = 'admin',
    description = 'Outro nome pra um comando que já existe (ex.: /tpto chama o /tp). Quem vem do creative ou vRP digita o que já conhece.',
    defaults = {
        enabled = true,
        aliases = {
            tpto = 'tp',
            tpway = 'tpm',
            god = 'revive',
        },
    },
    fields = {
        {
            key = 'aliases',
            type = 'map',
            itemType = 'text',
            label = 'Atalho e comando',
            help = 'Atalho -> comando que ele chama, os dois sem a barra. Vale a permissão do comando original. Atalho com nome de um comando que já existe é ignorado.',
        },
    },
})
