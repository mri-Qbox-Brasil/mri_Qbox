import * as http from 'http';

// Definir as métricas que serão expostas
interface Metrics {
    players_online: number;
    total_resources: number;
}

let metrics: Metrics = {
    players_online: 0,
    total_resources: 0,
};

// Função para gerar as métricas no formato Prometheus
const generateMetrics = (): string => {
    return `
# HELP players_online Número de jogadores conectados
# TYPE players_online gauge
players_online ${metrics.players_online}

# HELP total_resources Número total de recursos carregados
# TYPE total_resources gauge
total_resources ${metrics.total_resources}
    `;
};

// Cria um servidor HTTP que responde com as métricas
const server = http.createServer((req, res) => {
    if (req.url === '/metrics') {
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end(generateMetrics());
    } else {
        res.writeHead(404);
        res.end('Not Found');
    }
});

// Porta onde o servidor vai rodar (9100)
const PORT: number = 9100;

// Inicia o servidor
server.listen(PORT, () => {
    console.log(`Servidor de métricas rodando na porta ${PORT}`);
});

// Evento para atualizar as métricas com base nos dados do FiveM
setInterval(() => {
    // Obtém o número de jogadores conectados
    metrics.players_online = GetNumPlayerIndices(); // Função de FiveM

    // Obtém o número total de recursos carregados
    metrics.total_resources = GetNumResources(); // Função de FiveM
}, 5000);
