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
            help = 'Desligar um modelo tira ele da rua na hora (os que já estão rodando somem quando o jogo trocar o trânsito). Ligar um modelo, e tirar um desligado dos estacionamentos, vale a partir do próximo reinício do servidor.',
            groups = require 'resources.modules.traffic.groups',
        },
    },
})
