# Manual do mri_Qbox

## Visão Geral

O **mri_Qbox** é o resource central do framework MRI Qbox para servidores FiveM. Atua como o núcleo de conexões entre todos os resources da suite MRI Qbox, fornecendo sistemas essenciais de combate, veículos, gerenciamento de staff, VIP, utilitários administrativos e diversas mecânicas de gameplay que integram o ecossistema.

## Funcionalidades Principais

### 1. Core MRI (Sistema Central)

#### Esquema de Cores Global
- Define cores globais via `GlobalState.UIColors` para todos os resources
- Cores predefinidas: success (`#22C55E`), info (`#3B82F6`), warning (`#F59E0B`), danger (`#EF4444`)
- Consumido automaticamente por outros resources da suite MRI Qbox

#### Menu F9 (Jogador)
Painel completo para o jogador com acesso a:
- Status do personagem, job, gang, reputação e skills
- Gerenciamento de waypoints
- Controle de portas, blips, baús e NPCs
- Gerenciamento de props e elevadores
- Posters, garages, crafting
- Sistemas de groups e spotlight

#### Menu F10 (Admin)
Painel administrativo com:
- Ferramentas de administração geral
- Vehicle tune (sintonização de veículos)
- Controle de clock e weather (tempo/clima)
- Gerenciamento avançado do servidor

#### Staff System
- Gerenciamento de roles de staff (admin, mod, support)
- Persistência de metadata no banco de dados
- Comandos para adicionar/remover staff online e offline

#### VIP System
- Sistema de tiers de VIP com benefícios escalonados
- Paychecks automáticos para VIPs
- Bônus de peso no inventário baseado no tier
- Gerenciamento online e offline via comandos administrativos

### 2. Sistemas de Combate

#### Ragdoll em Danos
- Ativa ragdoll quando o jogador é atingido nas pernas
- Simulação realística de incapacitação por ferimentos nas pernas

#### Tiro de Cobertura Desabilitado
- Remove a mecânica de blind fire (atirar sem mirar de trás de coberturas)
- Incentiva combate tático e posicionamento

#### Rolamento de Combate Desabilitado
- Remove o combat roll (rolamento durante combate)
- Altera a dinâmica de movimentação sob fogo

#### Soco Apenas Mirando
- Desabilita socos aleatórios sem mirar
- Requer mira para executar ataques corpo a corpo

#### Recuo Realístico
- Implementa recuo vertical realístico nas armas
- Efeito drunk aiming (mira instável)
- Desabilita headshot (tiros na cabeça)
- Oculta crosshair (ponteiro de mira)

#### POV Forçado
- Modos de ponto de visão forçados (primeira pessoa)
- Alteração na experiência de camera durante combate

### 3. Sistemas de Veículos

#### Drift System
- Sistema de drift ativado com tecla Shift
- Exibição de pontos de drift em tempo real via NUI (Vue.js)
- HUD com contador de pontos posicionado no centro inferior da tela
- Ícone de drift com borda verde e fonte Orbitron

#### Explosão de Veículos
- Veículos explodem ao cair de alturas significativas
- Simulação realística de danos por impacto

#### Controle no Ar Desabilitado
- Desabilita pulo e saída do veículo enquanto estiver no ar
- Previne exploits de física

#### Rodas Quebram em Impacto
- Rodas quebram em impactos fortes
- Danos realísticos ao sistema de rodas

#### Salvamento do Volante
- Salva o ângulo do volante ao estacionar
- Mantém a posição das rodas ao reentrar no veículo

### 4. Interações e Mecânicas

#### Lixeiras (Dumpsters)
- Permite esconder itens em lixeiras
- Busca de itens escondidos em lixeiras via ox_target

#### Entrada Específica em Veículos
- Entrar no veículo pela porta específica clicada
- Integração com ox_target para seleção de portas

#### Drag-to-Craft
- Sistema de craftamento arrastando itens no ox_inventory
- Combina dois itens para criar um novo produto
- Receitas configuráveis em `modules/dragCraft/config.lua`
- Suporte a callbacks before/after para lógica customizada
- Adição dinâmica de receitas via exports

#### Item Carrying
- Exibe prop visual anexado ao jogador ao carregar itens
- Configuração por item com modelo, osso, animação e restrições
- Suporta walkOnly (apenas andando) e blockVehicle (bloqueia entrar em veículos)

#### Item Collection
- Pegar e colocar itens do mundo como props
- Mapeia modelos de props para itens usando `ox_inventory:Items()`
- Integração com ox_inventory para spawn e remoção de props

#### Water Cooler
- Beber água de bebedouros e pias aumenta thirst metadata
- Encher garrafas vazias (`empty_water_bottle` → `water_bottle`)
- Proteção contra abuso (morte por beber demais em 1 minuto)
- Configurável em `modules/waterCooler/config/config.lua`

### 5. Utilitários

#### Cinematic Intro
- Cinemática de boas-vindas para novos jogadores
- Spawna o jogador em coordenadas fixas após a animação
- Reprodução via comando `/cinematic` (admin) ou `/cutscene <name>`

#### Raycast Picker
- Seletor de coordenadas via raycast
- Abre interface para capturar coordenadas 3D no mundo
- Export `GetRayCoords` para uso em outros resources

#### Props Indestrutíveis
- Congela props de rua e tráfego
- Previne destruição acidental de objetos do mundo

#### Mask Fix
- Correção de clipping de máscara em faces customizadas
- Ajuste automático para evitar problemas visuais

#### SQL Backup
- Backups automáticos do banco de dados
- Proteção de dados do servidor

#### Auto-updater
- Sistema de atualizações automáticas
- Notificações via Discord webhook quando updates são aplicados

## Comandos Disponíveis

### Jogador

| Comando | Descrição |
|---------|-----------|
| `/tpway` | Teleporta para o waypoint marcado no mapa |
| `/god [id]` | Revive o jogador especificado (ou o próprio) |
| `/cutscene <name>` | Reproduz uma cutscene específica |
| `/menu <job>` | Abre o menu de boss do job informado |

### Administrativos (Restritos a group.admin)

| Comando | Descrição |
|---------|-----------|
| `/item <name> [count] [target]` | Dá um item para o jogador (ou alvo) |
| `/tuning` | Sintoniza o veículo atual ao máximo |
| `/menu_admin` | Abre o menu administrativo |
| `/customs` | Abre o menu de modificação de veículos |
| `/raycast` | Abre o seletor de coordenadas via raycast |
| `/models` | Lista modelos de veículos faltando no servidor |
| `/viewallitems` | Visualiza todos os itens em stash temporário |
| `/staff <id> <add/rem> [role]` | Gerencia roles de staff (admin/mod/support) |
| `/vipadm <id> <add/rem> [tier]` | Gerencia tiers de VIP de jogadores |
| `/cinematic` | Reproduz a cinemática de boas-vindas |

## Keybinds

| Tecla | Ação |
|-------|------|
| **F9** | Abre o menu do jogador |
| **F10** | Abre o menu administrativo |

## Exports

### Client

| Export | Descrição |
|--------|-----------|
| `GetRayCoords` | Abre seletor de coordenadas via raycast |
| `Request` | Dialog sim/não, retorna boolean |
| `CanCarryItem` | Verifica se o jogador pode carregar item por peso |
| `setPlayerJob` | Dialog para definir job/grade do jogador |
| `setPlayerGang` | Dialog para definir gang/grade do jogador |
| `AddItemToMenu` | Adiciona item aos menus do resource |
| `RemoveItemFromMenu` | Remove item dos menus |
| `AddManageMenu` | Adiciona item ao menu de gerenciamento |
| `RemoveManageMenu` | Remove item do menu de gerenciamento |
| `AddPlayerMenu` | Adiciona item ao menu do jogador |
| `RemovePlayerMenu` | Remove item do menu do jogador |
| `addRecipe` | Adiciona receita drag-to-craft dinamicamente |
| `addVip` | Adiciona VIP a jogador (online/offline) |
| `removeVip` | Remove VIP de jogador |

### Server

| Export | Descrição |
|--------|-----------|
| `VipAdm` | Gerenciamento de VIP (add/remove) |
| `addRecipe` | Adiciona receita drag-to-craft dinamicamente |
| `itemPlace` | Coloca item como prop no mundo |

## NUI (Drift Points)

### Drift Points Display
- **Framework**: Vue.js 2.5.17
- **Localização**: Centro inferior da tela (bottom-center HUD)
- **Visual**: Borda verde, ícone de drift, contador de pontos
- **Fonte**: Orbitron (Google Fonts)
- **Uso**: Enviar pontos via `SendNUIMessage({ drift: <points> })`

## Integração com Outros Resources

| Resource | Integração |
|----------|------------|
| `mri_Qjobsystem` | Verificação de boss/recruiter no menu F9 |
| `mri_Qadmin` | Fallback para setJob/setGang |
| `mri_Qvinewood` | Entrada condicional no menu F9 |
| `qbx_management` | Boss menu, busca de jogadores próximos |
| `qbx_core` | Dados do jogador, jobs, gangs, metadata |
| `ps-adminmenu` | Fallback para menu admin |
| `scully_emotemenu` | Cancelamento de emotes |

## Configuração

### Cores Globais
O resource define automaticamente o GlobalState.UIColors. Para modificar, altere em `modules/mri/client-side/main.lua`.

### Drag-to-Craft
Configure receitas em `modules/dragCraft/config.lua`:
```lua
RECIPES = {
    ['garbage metalscrap'] = {
        result = { name = 'lockpick', count = 1 },
        duration = 3000,
    },
}
```

### Item Carrying
Configure itens em `modules/itemCarry/`:
```lua
ITEMS = {
    ['box'] = {
        model = 'hei_prop_heist_box',
        bone = 60309,
        animation = { dict = 'anim@heists@box_carry@', clip = 'idle' },
        walkOnly = true,
        blockVehicle = true,
    },
}
```

### Water Cooler
Configure modelos de bebedouros em `modules/waterCooler/config/config.lua`.

## Instalação

1. Copie a pasta `mri_Qbox` para a pasta de resources do servidor FiveM
2. Adicione `ensure mri_Qbox` no `server.cfg` (após `qbx_core`, `ox_lib`, `ox_inventory`)
3. Certifique-se de que todos os resources dependentes estão disponíveis

## Dependências

### Obrigatórias
- `ox_lib` — Menus, callbacks, notificações, progress bars, keybinds
- `qbx_core` — Framework principal Qbox
- `qbx_management` — Boss menu, fetch de jogadores
- `oxmysql` — Consultas SQL (staff/VIP)
- `ox_inventory` — Weight checks, drop items, drag craft, item carrying
- `ox_target` — Targeting (dumpsters, vehicle doors, water cooler)

### Opcionais
- `mri_Qjobsystem` — Verificação de boss/recruiter
- `mri_Qadmin` — Integração com menu admin
- `mri_Qvinewood` — Entrada no menu F9
- `ps-adminmenu` — Fallback para menu admin
- `scully_emotemenu` — Cancelamento de emotes
- `hud` — Integração com HUD (requer atualização)

## Estrutura de Arquivos

```
mri_Qbox/
├── fxmanifest.lua
├── config.lua
├── generate_release.bat / .sh
├── modules/
│   ├── cinematic/              # Cinemática de boas-vindas
│   ├── dragCraft/              # Sistema drag-to-craft
│   ├── itemCarry/              # Props visuais ao carregar itens
│   ├── itemcollection/         # Pegar/colocar itens do mundo
│   ├── mri/                    # Core MRI modules
│   │   ├── client-side/
│   │   │   ├── main.lua        # GlobalState.UIColors
│   │   │   ├── combat-modules/ # Ragdoll, recoil, blind fire, etc.
│   │   │   ├── vehicles-modules/ # Drift, explosion, wheel break
│   │   │   ├── ox_lib-modules/ # Menus F9/F10, staff, vip, input
│   │   │   └── target-modules/ # Dumpsters, per-door entry
│   │   └── server-side/
│   │       ├── ox_lib-modules/ # Drop items, staff, VIP
│   │       └── utilities-modules/ # Commands, utils
│   └── waterCooler/            # Sistema de hidratação
└── web-side/                   # NUI drift points (Vue.js)
    ├── index.html
    ├── core.js
    └── icones/
```

## Observações Importantes

- O resource define `GlobalState.UIColors` consumido por outros resources MRI Qbox
- O sistema drag-to-craft usa hooks do ox_inventory — receitas podem ser adicionadas dinamicamente via export
- O cinematic de boas-vindas spawna o jogador em coordenadas fixas após a animação
- Water cooler possui proteção contra abuso (morte por beber demais em 1 minuto)
- Item collection usa `ox_inventory:Items()` para mapear modelos de props para itens
- O módulo `mercosulplates.lua` está deprecated — substituído por `mri_Qcarplates`
