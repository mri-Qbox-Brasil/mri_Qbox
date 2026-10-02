-- Same 8 spots as ox_lib notify; bottom-left sits above the minimap.
SOUNDTRACK_POSITIONS = {
    { value = 'top-left', label = 'Em cima, à esquerda' },
    { value = 'top', label = 'Em cima, no meio' },
    { value = 'top-right', label = 'Em cima, à direita' },
    { value = 'center-left', label = 'No meio, à esquerda' },
    { value = 'center-right', label = 'No meio, à direita' },
    { value = 'bottom-left', label = 'Embaixo, à esquerda (acima do minimapa)' },
    { value = 'bottom', label = 'Embaixo, no meio' },
    { value = 'bottom-right', label = 'Embaixo, à direita' },
}

Mri.module({
    id = 'soundtrack',
    label = 'Trilha sonora',
    category = 'sound',
    description = 'Player de música do servidor: scripts pedem um momento (ou um link) com prioridade, por estado ou evento, e a trilha toca o mais importante, trocando com crossfade. Abaixa quando o jogador fala. O volume segue o slider de efeitos sonoros das configurações de áudio do GTA.',
    defaults = {
        enabled = true,
        volume = 30,
        crossfadeMs = 2200,
        duckOnTalk = true,
        duckLevel = 35,
        nowPlaying = true,
        toastPosition = 'bottom-left',
        playerPosition = 'bottom-left',
        moments = {},
        places = {},
    },
    fields = {
        { key = 'volume', type = 'number', label = 'Volume da trilha', min = 0, max = 100, step = 5, unit = '%', help = 'Calibra a trilha em relação ao resto do jogo. Multiplica o slider de efeitos sonoros das configurações de áudio do GTA, que é o volume que cada jogador escolhe' },
        { key = 'crossfadeMs', type = 'number', label = 'Tempo da troca de faixa', min = 0, max = 10000, step = 100, unit = 'ms' },
        { key = 'duckOnTalk', type = 'boolean', label = 'Abaixar quando o jogador fala', help = 'Voz e rádio' },
        { key = 'duckLevel', type = 'number', label = 'Volume falando', min = 0, max = 100, step = 5, unit = '%' },
        { key = 'nowPlaying', type = 'boolean', label = 'Mostrar a faixa que começou', help = 'Aviso com capa, título e artista quando a música não diz como aparecer (display)' },
        { key = 'toastPosition', type = 'select', label = 'Posição do aviso', options = SOUNDTRACK_POSITIONS },
        { key = 'playerPosition', type = 'select', label = 'Posição do player', help = 'Player com play e pause, quando a música pede display = player', options = SOUNDTRACK_POSITIONS },
        {
            key = 'moments',
            type = 'moments',
            label = 'Momentos',
            help = 'Cada momento tem um nome e uma ou mais faixas (com várias, sorteia uma). Os scripts e os locais pedem pelo nome.',
        },
        {
            key = 'places',
            type = 'places',
            label = 'Locais',
            help = 'Chegou no local, toca o momento; saiu, volta o que estava tocando. Vá até o lugar e use "Usar minha posição".',
        },
    },
})
