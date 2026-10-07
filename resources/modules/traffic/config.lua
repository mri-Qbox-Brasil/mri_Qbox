Mri.module({
    id = 'traffic',
    label = 'Trânsito',
    category = 'world',
    description = 'Escolhe quais carros e motos aparecem no trânsito da cidade, entre os do GTA e os das DLCs. Muda na hora.',
    defaults = {
        enabled = true,
        models = require 'resources.modules.traffic.defaults',
    },
    fields = {
        {
            key = 'models',
            type = 'traffic',
            label = 'Veículos no trânsito',
            help = 'Desligar um modelo tira ele de todos os grupos. Os que já estão na rua somem quando o jogo trocar o trânsito.',
            groups = require 'resources.modules.traffic.groups',
        },
    },
})
