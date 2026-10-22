Mri.module({
    id = 'vehicledoors',
    label = 'Portas do veículo (olhinho)',
    category = 'vehicles',
    description = 'Pelo olhinho, abre e fecha as portas, o capô e o porta-malas de veículo destrancado. Na tampa da mala, "Ver itens" abre o porta-malas do ox_inventory.',
    defaults = {
        enabled = true,
        trunkItems = true,
    },
    fields = {
        {
            key = 'trunkItems',
            type = 'boolean',
            label = 'Ver itens na tampa da mala',
            help = 'Abre o inventário do porta-malas do ox_inventory pelo olhinho, junto do abrir e fechar.',
        },
    },
})
