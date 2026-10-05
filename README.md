# mri_Qbox: Manual

Coleção de módulos da suíte MRI: menus F9/F10, staff e VIP, comandos de admin e módulos de
combate, veículos, interação, inventário e mundo. Cada módulo liga, desliga e se configura
pelo painel `/mriqbox` (ou pela aba no mri_Qadmin), e a mudança vale na hora, sem reiniciar.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Permissões (ACE)](#permissões-ace)
4. [Painel de configuração](#painel-de-configuração)
5. [Módulos](#módulos)
6. [Comandos](#comandos)
7. [Teclas](#teclas)
8. [Menus F9 e F10](#menus-f9-e-f10)
9. [Staff](#staff)
10. [VIP](#vip)
11. [Veículos: cadastro e estoque](#veículos-cadastro-e-estoque)
12. [Integrações](#integrações)
13. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
14. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `ox_lib` | Sim | Menus, comandos, callbacks, keybinds, principals e o `/uiconfig` do tema |
| `qbx_core` | Sim | `QBX.PlayerData`, jobs, gangs e metadata (staff, VIP); o fork MRI, com a API de veículos em runtime |
| `oxmysql` | Sim | Lista de personagens dos painéis de staff e VIP e a tabela `vehicles_data` |
| `ox_inventory` | Sim | Peso, drop de itens, craft arrastando, carregar nos braços, pegar do chão, `/viewallitems` |
| `ox_target` | Sim | Lixeiras, entrar pela porta, bebedouros, pegar do chão |
| `qbx_management` | Para os painéis | Jogadores próximos nos painéis de staff e VIP e o `/menu <job>` |
| `mri_Qjobsystem` | Não | Mostra "Gerenciar Emprego" e "Gerenciar Gangue" no F9 pra chefe e recrutador. Sem ele, essas duas opções só não aparecem |
| `mri_Qadmin` | Não | Abas "MRI Qbox" (painel) e "Veículos"; destino preferido de `setPlayerJob`/`setPlayerGang` |
| `ps-adminmenu` | Não | Alternativa de `setPlayerJob`/`setPlayerGang` sem o mri_Qadmin |
| `mri_Qvinewood` | Não | Entrada "Vinewood" no menu de gerenciamento |

Os menus F9/F10 disparam comandos de outros recursos (`doorlock`, `blip`, `bau`, `npc`,
`objectspawner`, `elevador`, `garagelist`, `craft:create`, `open_jobs`, `spotlight`,
`weather`, `adm`...). Cada entrada só funciona se o recurso daquele comando estiver instalado.

---

## Instalação

1. Coloque a pasta `mri_Qbox` em `resources/` (na base MRI, em `resources/[mri]`).
2. No `server.cfg`, inicie depois de `ox_lib`, `qbx_core`, `oxmysql`, `ox_inventory` e
   `ox_target`:
   ```
   ensure mri_Qbox
   ```
3. Libere a ACE de admin (ver [Permissões](#permissões-ace)).
4. Abra o `/mriqbox` e ligue os módulos que quiser. Os valores ficam em `data/config.json`.
5. Não há SQL para importar: staff e VIP ficam na metadata do personagem
   (`players.metadata`), que o `qbx_core` já cria, e a tabela `vehicles_data` é criada
   sozinha.
6. Vindo do mri_Qvehicles: tire ele do servidor (ver [Vindo do mri_Qvehicles](#vindo-do-mri_qvehicles)).

---

## Permissões (ACE)

| Permissão | Libera |
|---|---|
| `mri_Qbox.admin` ou `command` | O painel `/mriqbox` e a aba no mri_Qadmin |
| `mri_Qvehicles.admin`, `mri_Qbox.admin` ou `command` | A tela de veículos (aba "Veículos" no mri_Qadmin) |
| `group.admin` | Comandos de admin (`/item`, `/staff`, `/vipadm`...) e os eventos dos painéis de staff e VIP |

```
add_ace group.admin command allow
add_principal identifier.fivem:1 group.admin
```

O recurso também **concede principals sozinho**: ao logar, quem tem `metadata.staff` recebe
o principal do cargo (`group.admin`, `group.mod`, `group.support`) e quem tem `metadata.vip`
recebe o principal com o nome do tier. Não é preciso mexer no `server.cfg` pra cada admin.

---

## Painel de configuração

`/mriqbox` abre o painel (ou a aba "MRI Qbox" no mri_Qadmin). ESC fecha.

- **Lateral:** categorias (Menus, Admin, Combate, Veículos, Interação, Inventário, Mundo, Som) e
  busca por nome ou descrição.
- **Lista:** cada módulo com descrição e o liga/desliga na própria linha. Módulo que faz
  parte da base mostra o selo "Base" no lugar do liga/desliga: fica sempre ligado.
- **Detalhe:** as opções do módulo (número com unidade, texto, seleção, listas, tabela
  chave e valor, JSON), "Restaurar padrão", "Descartar" e "Salvar". O módulo Veículos abre
  a tela de cadastro inteira, com "Módulos" pra voltar.

Tudo vale na hora pra todos os jogadores:

- módulo de loop (recuo, drift, roda solta...) passa a obedecer na volta seguinte;
- módulo que registra coisa em outro recurso (olhinho, gancho do inventário, item de menu,
  textura) registra ao ligar e remove ao desligar;
- comando e tecla continuam registrados (o FiveM não remove), mas desligados avisam
  "Comando desligado no painel do mri_Qbox" ou não fazem nada.

O servidor valida cada valor pelo tipo da opção antes de gravar em `data/config.json`.
O tema do painel segue a suíte: cor de destaque e fundo pelas convars `mri:color` e
`mri:backgroundColor`, e o resto (dark/glass, opacidade, raio, fonte) pelo `/uiconfig`.

---

## Módulos

Ligado ou desligado de fábrica entre parênteses.

### Menus e admin

| Módulo | O que faz |
|---|---|
| Menus F9 e F10 (ligado) | Menu do jogador e de administração. Os exports pra outros recursos continuam valendo com ele desligado |
| Staff (ligado) | Cargos de staff gravados no personagem e aplicados como ACE ao logar |
| VIP (desligado) | Tiers com ACE, peso do inventário e salário periódico. Opções: intervalo do salário, conta, símbolo da moeda e os tiers (JSON) |
| Setar job e gang (ligado) | Diálogos de job/gang e cargo (`setPlayerJob`, `setPlayerGang`, `/setargang`) |
| Comandos de admin (ligado) | `/item`, `/tuning`, `/menu_admin`, `/customs`, `/raycast`, `/menu` |
| Atalhos de comando (ligado) | Outro nome pra um comando que já existe, editado no painel (atalho -> comando). Já vem com `/tpto` -> `/tp`, `/tpway` -> `/tpm` e `/god` -> `/revive`, pra quem vem do creative ou vRP. Vale a permissão do comando original; atalho com nome de comando que já existe ou que aponta pra outro atalho é ignorado, com aviso no console |
| Ver todos os itens (ligado) | `/viewallitems` |
| Identificadores no console (ligado) | Mostra os identificadores de quem conecta |
| Tocar cutscene (ligado) | `/cutscene <nome>` |

### Combate

| Módulo | O que faz |
|---|---|
| Cair com tiro na perna (desligado) | Ragdoll ao levar tiro na perna ou na pélvis |
| Sem tiro cego (desligado) | Não atira da cobertura sem mirar |
| Sem rolamento (desligado) | Tira o rolamento de combate mirando |
| Sem soco sem mirar (desligado) | Só bate ou atira segurando a mira |
| Recuo realista (desligado) | Recuo vertical por tipo de arma, mira bêbada, sem headshot de um tiro, sem soco mirando, armas sem recuo |
| Só duas câmeras a pé (desligado) | Primeira e terceira pessoa (V alterna) |
| Primeira pessoa armado no carro (desligado) | Motorista armado vai pra primeira pessoa (sempre ou só segurando a mira) |
| Esconder HUD nativa (ligado) | Esconde nome do veículo, área, classe e rua; opcional, a mira |

### Veículos

| Módulo | O que faz |
|---|---|
| Veículos (sempre ligado) | Cadastro, edição e estoque dos veículos sem reiniciar. Ver [Veículos: cadastro e estoque](#veículos-cadastro-e-estoque) |
| Drift no Shift (ligado) | Perde aderência segurando Shift até a velocidade máxima (padrão 80 km/h) |
| Pontos de drift (desligado) | Contador de pontos de drift na tela |
| Roda solta em batida (desligado) | Roda solta por força do impacto ou por velocidade da colisão |
| Roda virada ao desligar (desligado) | A roda fica no ângulo em que o carro foi desligado |
| Sem controle no ar (desligado) | Carro no ar não gira pelo controle |
| Explosão em queda (desligado) | Explode ao cair de uma altura (padrão 40 m) |
| Entrar pela porta (ligado) | Olhinho em cada porta; carro de concessionária não deixa |
| Rádio do carro (ligado) | `/mri_carradio` liga e desliga o rádio e a escolha vale em todo veículo. Sem tecla padrão (dá pra definir no painel) |
| Placas Mercosul (desligado) | Textura de placa Mercosul. Obsoleto: prefira o `mri_Qcarplates` |

### Interação

| Módulo | O que faz |
|---|---|
| Lixeiras (ligado) | Olhinho pra se esconder e vasculhar (abre o inventário da lixeira). Modelos no painel |
| Bebedouros (ligado) | Beber água e encher garrafa em bebedouros, fontes e pias. Beber seguido demais só mostra um aviso |

### Inventário

| Módulo | O que faz |
|---|---|
| Pegar itens do chão (ligado) | Olhinho pra pegar o prop de um item do ox_inventory. O export `itemPlace` continua valendo desligado |
| Carregar nos braços (ligado) | Itens como caixas ficam nos braços com animação (lista em `resources/modules/itemcarry/items.lua`) |
| Craft arrastando (ligado) | Arrastar um item sobre o outro faz a receita (em `resources/modules/dragcraft/recipes.lua`) |
| Item no chão vira prop (desligado) | Item largado aparece como o prop dele (tabela item e prop no painel) |

### Som

| Módulo | O que faz |
|---|---|
| Trilha sonora (ligado) | Player de música do servidor: scripts pedem música por prioridade e a trilha toca a mais importante, com troca suave. Abaixa quando o jogador fala. O volume segue o slider de efeitos sonoros das configurações de áudio do GTA (zerado, não toca). Ao trocar de faixa, mostra um aviso com capa, título e artista, ou um player com play e pause, numa das 8 posições das notificações do ox_lib. Opções: volume da trilha, tempo da troca, abaixar falando e quanto, aviso da faixa, posição do aviso e do player, os momentos e os locais |

### Mundo

| Módulo | O que faz |
|---|---|
| Cinematic de boas-vindas (ligado) | Planos da cidade com legenda (`mth-cinematic:start` ou `/cinematic`) |
| Sem capacete automático (ligado) | O personagem não põe capacete sozinho na moto |
| Máscara sem atravessar o rosto (ligado) | Encolhe cabeça e traços enquanto a máscara pede |
| Postes indestrutíveis (ligado) | Postes, semáforos e hidrantes não quebram (modelos no painel) |

---

## Comandos

| Comando | Permissão | Descrição |
|---|---|---|
| `/mriqbox` | `mri_Qbox.admin` ou `command` | Abre o painel de configuração |
| `/tpway` | A do `/tpm` | Atalho de `/tpm`: teleporta pro waypoint do mapa |
| `/god [id]` | A do `/revive` | Atalho de `/revive`: revive o jogador informado ou você mesmo |
| `/menu <job>` | Nenhuma | Abre o boss menu do job (`qbx_management`) |
| `/cutscene <nome>` | Nenhuma | Toca uma cutscene do jogo |
| `/setargang <id>` | Nenhuma | Diálogo de setar gangue do jogador |
| `/mri_carradio` | Nenhuma | Liga e desliga o rádio do carro |
| `/item <item> [qtd] [alvo] [tipo]` | `group.admin` | Dá um item a você ou ao alvo |
| `/tuning` | `group.admin` | Aplica todos os mods no veículo atual |
| `/customs` | `group.admin` | Abre a customização do veículo atual |
| `/menu_admin` | `group.admin` | Abre o menu F10 |
| `/raycast` | `group.admin` | Pega coordenadas por raycast e copia |
| `/viewallitems` | `group.admin` | Baú temporário com um de cada item |
| `/staff <id> <add\|rem> [cargo]` | `group.admin` | Dá ou tira cargo de staff (`admin`, `mod`, `support`) |
| `/vipadm <id> <add\|rem> [tier]` | `group.admin` | Dá ou tira um tier de VIP |
| `/cinematic` | `group.admin` | Toca a cinematic de boas-vindas pra quem digitou |

Cada comando pertence a um módulo e só faz algo com o módulo ligado. `/setargang`,
`/cutscene` e `/menu` não têm restrição de permissão. `/tpway` e `/god` são atalhos
(módulo Atalhos de comando) e seguem a permissão do comando que chamam.

---

## Teclas

| Tecla | Ação |
|---|---|
| `F9` | Menu do jogador |
| `F10` | Menu de administração (executa `/menu_admin`, que exige `group.admin`) |

São keybinds do `ox_lib` (`menu_jogador_keybind` e `menu_admin_keybind`); o jogador pode
trocar nas configurações do FiveM. O rádio do carro (`/mri_carradio`) vem sem tecla.

---

## Menus F9 e F10

### F9: menu do jogador

Identificação (`/id`), Emprego (`/job`), Gangue (`/gang`), Ver Reputação (`/rep`), Ver
Habilidades (`/skill`) e Waypoints (limpar marcadores e configurações). "Gerenciar Emprego"
e "Gerenciar Gangue" aparecem pra chefe ou recrutador, segundo o `mri_Qjobsystem`.

### F10: menu de administração

Abrir Painel (`/adm`), Customizar Veículo (`/customs`), Relógio (hora, escala de tempo,
congelar tempo), Clima (`/weather`) e Gerenciamento: Portas, Blips, Baús, NPC, Props,
Elevador, Outdoors/Posters, Garagens, Crafting, Grupos, Spotlight e, com o `mri_Qvinewood`,
Vinewood. Staff e VIP entram aqui quando os módulos estão ligados.

Outros recursos acrescentam entradas pelos exports (ver
[Entrypoints](#entrypoints-para-outros-recursos)). Alvos: `'player'` (F9), `'f10'` e
`'management'`.

---

## Staff

O cargo fica em `metadata.staff` do personagem, no formato `group.<cargo>`.

- `/staff <id> add <cargo>` grava a metadata e concede o principal na hora.
- `/staff <id> rem` tira o principal e limpa a metadata.
- Ao logar, o principal é reaplicado a partir da metadata.
- O painel (F10 > Gerenciamento > Staff) lista a staff online e offline e altera cargos
  offline. A alteração offline exige `group.admin` de quem faz.

---

## VIP

O tier fica em `metadata.vip` e vira principal ACE com o mesmo nome.

- **Salário:** a cada intervalo (minutos, no painel), cada VIP online recebe o `payment` do
  tier na conta escolhida. `0` desliga.
- **Peso do inventário:** no login e a cada mudança, o peso máximo vira `inventory * 1000`
  gramas. Quem não é VIP usa o tier `nenhum`, por isso ele precisa existir.
- **Painel:** F10 > Vip lista VIPs online e offline e permite adicionar e remover.

Tiers no painel, em JSON:

```json
{
  "nenhum": { "label": "Sem vip", "payment": 0, "inventory": 100 },
  "tier1": { "label": "Tier 1", "payment": 5000, "inventory": 200 }
}
```

## Veículos: cadastro e estoque

Módulo da base (sempre ligado, substitui o antigo mri_Qvehicles). Cadastra, edita e controla
o estoque dos veículos sem editar o `shared/vehicles.lua` do qbx_core e sem reiniciar.

- **Onde abre:** aba **Veículos** do mri_Qadmin, ou `/mriqbox` > Veículos > Veículos.
- **Adicionar** veículos (carros addon) com nome, marca, preço, categoria, tipo e estoque.
- **Modelos fora da lista:** mostra os veículos que o jogo conhece (base e packs rodando) e
  que não estão na lista do qbx_core. "Cadastrar" abre o formulário já com o nome, a marca e
  o tipo que o jogo dá. É o antigo `/models`, agora na tela.
- **Editar veículos do jogo:** só os campos alterados ficam salvos; o resto segue o
  `shared/vehicles.lua`, então atualizações do Qbox continuam chegando.
- **Remover e restaurar:** veículo do jogo removido fica no filtro "Removidos" e volta ao
  original com um clique.
- **Aviso de modelo ausente:** marca veículos cujo modelo não existe no jogo (nome errado ou
  pack do carro parado).
- Tudo vale na hora pra concessionária, garagem, painel admin e demais scripts que usam a
  lista do qbx_core. Com a tela aberta, compras e mudanças de outro admin atualizam sozinhas.

Precisa do `qbx_core` com a API de veículos em runtime (`UpsertVehicleData` e
`RemoveVehicleData`, na pasta `mri/` do fork MRI).

### Tabela `vehicles_data`

Criada ou ajustada sozinha no start.

| Coluna | Significado |
|---|---|
| `model` | nome de spawn do veículo |
| `stock` | estoque da concessionária |
| `name`, `brand`, `price`, `category`, `type` | `NULL` = valor do `shared/vehicles.lua`; preenchido = editado pelo painel |
| `removed` | veículo do jogo removido pelo painel |

A versão antiga do `qbx_vehicleshop` gravava uma cópia completa de cada veículo nessa
tabela. No primeiro start, o estoque fica, os campos iguais ao `shared/vehicles.lua` viram
`NULL` e os diferentes ficam como edição. Nada é apagado.

### Vindo do mri_Qvehicles

Tire o `mri_Qvehicles` do servidor (pasta e `ensure`). O mri_Qbox faz `provide` dele e
continua com a mesma tabela, a mesma permissão (`mri_Qvehicles.admin`), a mesma aba no
mri_Qadmin e os mesmos exports. Se os dois estiverem rodando juntos, o módulo de veículos do
mri_Qbox não sobe e avisa no console.

### Para scripts que guardam a lista de veículos

Quem pega a lista uma vez (`exports.qbx_core:GetVehiclesByName()` ou
`GetCoreObject().Shared.Vehicles`) recebe uma cópia. Pra acompanhar as mudanças do painel,
escute o evento do qbx_core:

```lua
-- server
AddEventHandler('qbx_core:server:onVehicleUpdate', function(model, vehicle)
    VEHICLES[model] = vehicle -- vehicle nil = removido
end)

-- client
RegisterNetEvent('qbx_core:client:onVehicleUpdate', function(model, vehicle)
    VEHICLES[model] = vehicle
end)
```

---

## Integrações

### mri_Qadmin

O painel aparece como a aba "MRI Qbox" e a tela de veículos como a aba "Veículos" (dois
plugins do mesmo resource). `setPlayerJob` e `setPlayerGang` usam os
eventos `mri_Qadmin:server:SetJob`/`SetGang` quando ele está iniciado; sem ele, caem no
`ps-adminmenu`.

### mri_Qjobsystem

O F9 consulta `CheckPlayerIsbossByJobSystemData` e `CheckPlayerIrecruiterByJobSystemData`
pra mostrar as opções de gerenciar.

### qbx_management

Jogadores próximos nos painéis de staff e VIP (`qbx_management:server:getPlayers`), boss
menu do `/menu <job>` e o pedido de confirmação de recrutamento
(`mri_Qbox:client:request`).

### ox_inventory

Ganchos `swapItems`/`createItem` dos módulos de item no chão, craft arrastando e carregar
nos braços (registrados só com o módulo ligado) e o export `itemPlace` nos itens.

---

## Entrypoints para outros recursos

### Menus (cliente)

```lua
exports.mri_Qbox:AddPlayerMenu({          -- F9
    title = 'Minha opção',
    icon = 'star',
    iconAnimation = 'fade',
    description = 'Descrição da opção',
    arrow = true,
    onSelectFunction = function() ExecuteCommand('meucomando') end,
    onSelectArg = nil,                    -- opcional: argumento pra onSelectFunction
})
exports.mri_Qbox:RemovePlayerMenu('Minha opção')

exports.mri_Qbox:AddManageMenu({ ... })   -- F10 > Gerenciamento
exports.mri_Qbox:RemoveManageMenu('Minha opção')

exports.mri_Qbox:AddItemToMenu('f10', { ... })  -- 'f10' | 'management' | 'player'
exports.mri_Qbox:RemoveItemFromMenu('f10', 'Minha opção')
```

### `GetRayCoords` (cliente)

Seletor de coordenadas por raycast. Bloqueia até `E` (vector3), `G` (vector4) ou `Q`
(cancela, retorna `false`). Já copia pro clipboard.

```lua
local coords = exports.mri_Qbox:GetRayCoords()
```

### `Request` (cliente)

Pergunta Sim/Não num menu do `ox_lib`. Bloqueia até a resposta e retorna booleano. Também
disponível como callback `mri_Qbox:client:request`.

```lua
local confirmou = exports.mri_Qbox:Request('Título', 'Texto da pergunta', 'top-right')
```

### `CanCarryItem` (cliente)

```lua
local pode = exports.mri_Qbox:CanCarryItem('water', 5)
```

### `setPlayerJob` / `setPlayerGang` (cliente)

```lua
exports.mri_Qbox:setPlayerJob(targetServerId)   -- job opcional; sem ele abre o seletor
exports.mri_Qbox:setPlayerGang(targetServerId)
```

### `addVip` / `removeVip` (cliente)

```lua
exports.mri_Qbox:addVip({
    vipData = { source = 1, citizenId = 'ABC12345', name = 'Nome Sobrenome', offline = false },
    newRole = 'tier1',
    callback = function() end,   -- opcional
})
```

### `VipAdm` (servidor)

Mesma lógica do `/vipadm`. Retorna `true` em caso de sucesso.

```lua
exports.mri_Qbox:VipAdm(source, { id = targetId, tipo = 'add', tier = 'tier1' })
```

### `addRecipe` (cliente e servidor)

Receita de craft arrastando em runtime; sincroniza o outro lado sozinha.

```lua
exports.mri_Qbox:addRecipe('garbage metalscrap', {
    duration = 2000,
    costs  = { garbage = { need = 1, remove = true }, metalscrap = { need = 1, remove = true } },
    result = { { name = 'lockpick', amount = 1 } },
})
```

A chave é `"<itemA> <itemB>"`; a ordem inversa também vale.

### `itemPlace` (servidor)

Pra usar no campo `export` de um item do `ox_inventory`: coloca o prop do item no chão à
frente do jogador e bloqueia o uso dentro de veículo.

```lua
['cadeira'] = {
    label = 'Cadeira',
    weight = 1000,
    prop = 'prop_chair_01a',
    export = 'mri_Qbox.itemPlace',
},
```

### Trilha sonora (estado e evento)

A trilha não tem export: quem pede música não precisa saber se o mri_Qbox está rodando
(sem ele, nada acontece e não dá erro) e nada passa pelo servidor.

**Pedido contínuo** (tocar enquanto algo dura): uma chave `music:<id>` no statebag do
jogador. Toca o pedido de maior prioridade (o mais recente desempata); ao soltar
(`nil`), volta o que estava por baixo. Prioridades: `ambient` (10), `zone` (20),
`activity` (30), `scene` (40), `ui` (50), ou um número. Por ser estado, o pedido
sobrevive a reinício: se o mri_Qbox subir depois, ele lê as chaves que já existem.

```lua
-- client (o último argumento false = só neste client, sem rede)
LocalPlayer.state:set('music:perseguicao', { moment = 'chase', priority = 'activity' }, false)
LocalPlayer.state:set('music:perseguicao', nil, false)        -- solta

-- abaixar a música (diálogo, cutscene com som próprio): nível 0 a 1, ou { level, fade }
LocalPlayer.state:set('musicDuck:cutscene', { level = 0.3, fade = 800 }, false)
LocalPlayer.state:set('musicDuck:cutscene', nil, false)

-- servidor, pra um jogador
Player(source).state:set('music:evento', { moment = 'festa', priority = 'zone' }, true)

-- servidor, pra todo mundo (só o servidor escreve no GlobalState)
GlobalState['music:carnaval'] = { moment = 'festa', priority = 'zone' }
GlobalState['music:carnaval'] = nil
```

Quem pediu deve soltar a chave ao terminar (e ao parar o resource).

**Frase curta por cima** (missão concluída, alerta): evento local; a música abaixa
enquanto ela toca.

```lua
TriggerEvent('mri_Qbox:soundtrack:stinger', { moment = 'alerta' })                 -- client
TriggerClientEvent('mri_Qbox:soundtrack:stinger', source, { moment = 'alerta' })   -- servidor
```

**Faixa:** `moment` (cadastrado no painel) ou `url` direto, em três formatos:

| Formato | Exemplo | Observação |
|---|---|---|
| YouTube | `https://www.youtube.com/watch?v=...` | Toca pelo player do YouTube |
| Link direto de áudio | `https://cdn.exemplo.com/chase.ogg` | Player leve, sem anúncio, loop sem emenda |
| Arquivo de um resource | `@meu_script/sounds/chase.ogg` | O próprio script hospeda: o arquivo precisa estar no `files` do fxmanifest dele |

Opções do pedido: `volume` (0 a 1), `loop`, `fade` (ms) e `title` (nome no aviso).

**Como aparece na tela** (no pedido ou no momento; sem nada, vale o painel):

| Opção | Valores | Efeito |
|---|---|---|
| `display` | `toast` (padrão), `player`, `none` | Aviso que some em alguns segundos, player com play/pause e progresso que fica enquanto a música é a da vez, ou nada na tela |
| `position` | `top`, `top-right`, `top-left`, `bottom`, `bottom-right`, `bottom-left`, `center-right`, `center-left` | As mesmas 8 posições das notificações do ox_lib. `bottom-left` fica acima do minimapa. Sem ela, a posição do aviso ou do player do painel |
| `autoplay` | `true` (padrão), `false` | Só no player: com `false` ele aparece pausado, esperando o play |
| `focus` | `true` | Só no pedido: o player ganha o mouse até a pessoa dar play, fechar (X) ou apertar ESC |

```lua
-- caixa de som: aparece no meio da tela, pausada, com o mouse pra pessoa dar play
LocalPlayer.state:set('music:caixa', {
    url = '@meu_script/sounds/radio.ogg',
    priority = 'activity',
    display = 'player',
    autoplay = false,
    focus = true,
    position = 'center-right',
}, false)
```

Pausar segura a vez da música: ela fica em silêncio sem pular pra outra de prioridade
menor, e o play continua de onde parou. Sem `focus`, o player só mostra e não dá pra
clicar (clicar na NUI tira o controle do personagem, então quem decide é o script).

Os momentos se cadastram no painel (módulo Trilha sonora, campo **Momentos**): nome,
uma ou mais faixas (com várias, sorteia uma a cada vez), volume, loop, como aparece,
posição e se o player começa tocando. Cada faixa tem um ▶ pra ouvir na hora.

### Locais da trilha (painel)

No painel, módulo Trilha sonora, campo **Locais**: cada local é um círculo no mapa que toca
um momento enquanto o jogador está dentro. Saiu, volta o que estava tocando antes. Não
precisa de script.

- Cadastre antes os momentos (campo **Momentos**, logo acima). **Adicionar local aqui** cria o local na posição atual do jogador; **Usar minha posição**
  move um local existente. Vá até o lugar com o painel aberto.
- Cada local: nome, raio (metros), momento, prioridade (`zona` por padrão, pra
  perseguição e cena passarem por cima), só a pé ou só de veículo, altura mínima e máxima
  (separa andares e interiores) e só à noite (20h às 6h).
- **Testar** toca o momento na hora; **Mostrar** desenha o círculo no mundo por 20
  segundos (feche o painel pra ver).
- Locais um dentro do outro seguem a prioridade, e o mais recente desempata.
- Usa as zonas do ox_lib: só acordam ao entrar e sair. Cada jogador roda os próprios
  locais, então ninguém dispara a música de outro.

### Estoque de veículos (servidor)

Com o nome antigo, pra quem já chamava o mri_Qvehicles (o mri_Qbox faz `provide` dele):

| Export | Descrição |
|---|---|
| `exports.mri_Qvehicles:GetStock(model)` | Estoque do modelo (0 quando não há linha) |
| `exports.mri_Qvehicles:GetStocks()` | Estoque de todos os modelos com linha na tabela |
| `exports.mri_Qvehicles:TakeStock(model)` | Tira uma unidade. Retorna `false` sem estoque. Atômico no banco |
| `exports.mri_Qvehicles:ReturnStock(model)` | Devolve uma unidade (ex.: pagamento falhou) |
| `exports.mri_Qvehicles:SetStock(model, stock)` | Define o estoque |

O `qbx_vehicleshop` e o `mri_Qadmin` do MRI usam esses exports.

### GlobalState `UIColors`

Cores de status que os recursos MRI leem:

```lua
{ success = '#51CF66', info = '#668CFF', warning = '#FFD700', danger = '#FF6347' }
```

---

## Estrutura de arquivos

```
mri_Qbox/
├── data/config.json            # valores salvos pelo painel
├── html/                       # NUI (painel, contador de drift, trilha) e vehicles.html (aba Veículos)
├── resources/
│   ├── core/                   # núcleo: registro dos módulos, config, painel, exports
│   └── modules/<módulo>/       # um módulo por pasta: config.lua, client.lua, server.lua
└── fxmanifest.lua
```
