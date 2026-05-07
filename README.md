# mri_Qbox 🧩

Resource central do framework MRI Qbox — responsável por fazer as principais conexões entre os resources da suite MRI Qbox. Inclui sistemas de combate, veículos, VIP, staff, drag-to-craft, item carrying, water cooler e mais.

## Principais recursos

### Core MRI
- 🎨 **GlobalState.UIColors** — Define esquema de cores global (success, info, warning, danger) para todos os resources.
- 👤 **Menu F9 (Player)** — Status, job, gang, reputação, skills, waypoints, gerenciamento de portas, blips, baús, NPCs, props, elevadores, posters, garages, crafting, groups, spotlight.
- 🔧 **Menu F10 (Admin)** — Admin panel, vehicle tune, clock, weather, gerenciamento.
- 👥 **Staff System** — Gerenciamento de roles (admin/mod/support) com persistência de metadata.
- ⭐ **VIP System** — Tiers de VIP com paychecks, bônus de peso no inventário, gerenciamento online/offline.

### Combate
- 💥 **Damage Ragdoll** — Ragdoll quando atingido nas pernas.
- 🚫 **Blind Fire Disabled** — Tiro de cobertura desabilitado.
- 🤸 **Combat Roll Disabled** — Rolamento de combate desabilitado.
- 👊 **Free Punch Disabled** — Soco apenas quando mirando.
- 🔫 **Realistic Recoil** — Recuo vertical, drunk aiming, headshot disable, crosshair hide.
- 🥽 **Forced First Person** — Modos de POV forçado.

### Veículos
- 🏎️ **Drift** — Drift com Shift + NUI drift points display.
- 💥 **Car Explosion** — Veículos explodem ao cair de altura.
- 🚫 **Air Control Disabled** — Pulo/saída desabilitados no ar.
- 🛞 **Wheel Break** — Rodas quebram em impacto forte.
- 💾 **Save Wheel Position** — Salva ângulo do volante ao estacionar.

### Interações
- 🗑️ **Dumpsters** — Esconder e buscar em lixeiras.
- 🚗 **Per-door Vehicle Entry** — Entrar no veículo pela porta específica via ox_target.
- 🛠️ **Drag-to-Craft** — Combinar itens arrastando no ox_inventory para craftar.
- 📦 **Item Carrying** — Prop visual anexado ao jogador ao carregar itens.
- 🌍 **Item Collection** — Pegar/colocar itens do mundo como props.
- 💧 **Water Cooler** — Beber de bebedouros e encher garrafas.

### Utilidades
- 🎬 **Cinematic Intro** — Cinemática de boas-vindas para novos jogadores.
- 📐 **Raycast Picker** — Seletor de coordenadas via raycast.
- 🔒 **Indestructible Props** — Props de rua/tráfego congelados.
- 🎭 **Mask Fix** — Correção de clipping de máscara em faces customizadas.
- 💾 **SQL Backup** — Backups automáticos do banco de dados.
- 🔄 **Auto-updater** — Atualizações com notificações Discord webhook.

## Instalação rápida

1. Copie a pasta `mri_Qbox` para a pasta de resources do servidor.
2. Adicione `ensure mri_Qbox` no `server.cfg` (após `qbx_core`, `ox_lib`, `ox_inventory`).
3. Certifique-se de que todos os resources dependentes estão disponíveis.

## Configuração

### Cores globais (GlobalState.UIColors)

O resource define automaticamente:
```lua
GlobalState.UIColors = {
    success = '#22C55E',
    info = '#3B82F6',
    warning = '#F59E0B',
    danger = '#EF4444',
}
```

### Drag-to-Craft (modules/dragCraft/config.lua)

Receitas padrão:
```lua
RECIPES = {
    ['garbage metalscrap'] = {
        result = { name = 'lockpick', count = 1 },
        duration = 3000,
        -- before/after callbacks
    },
}
```

### Item Carrying (modules/itemCarry/)

Items que exibem prop visual:
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

### Water Cooler (modules/waterCooler/config/config.lua)

Modelos de alvos (bebedouros, pias):
- Beber água: aumenta thirst metadata.
- Encher garrafa: converte `empty_water_bottle` → `water_bottle`.

## Keybinds

| Tecla | Ação |
|---|---|
| **F9** | Abrir menu do jogador. |
| **F10** | Abrir menu admin. |

## Comandos

| Comando | Restrito | Descrição |
|---|---|---|
| `/tpway` | Não | Teleportar para waypoint. |
| `/god [id]` | Não | Reviver jogador. |
| `/item <name> [count] [target]` | `group.admin` | Dar item. |
| `/tuning` | `group.admin` | Tunar veículo atual ao máximo. |
| `/menu_admin` | `group.admin` | Abrir menu admin. |
| `/customs` | `group.admin` | Abrir vehicle customs. |
| `/raycast` | `group.admin` | Seletor de coordenadas. |
| `/models` | `group.admin` | Listar modelos de veículos faltando. |
| `/viewallitems` | `group.admin` | Ver todos os itens em stash temp. |
| `/staff <id> <add/rem> [role]` | `group.admin` | Gerenciar roles de staff. |
| `/vipadm <id> <add/rem> [tier]` | `group.admin` | Gerenciar tiers de VIP. |
| `/cinematic` | `group.admin` | Reproduzir cinemática. |
| `/cutscene <name>` | Não | Reproduzir cutscene. |
| `/menu <job>` | Não | Abrir menu de boss do job. |

## Exports

### Client

| Export | Descrição |
|---|---|
| `GetRayCoords` | Abre seletor de coordenadas via raycast. |
| `Request` | Dialog sim/não, retorna boolean. |
| `CanCarryItem` | Verifica se jogador pode carregar item por peso. |
| `setPlayerJob` | Dialog para definir job/grade de jogador. |
| `setPlayerGang` | Dialog para definir gang/grade de jogador. |
| `AddItemToMenu` | Adiciona item aos menus. |
| `RemoveItemFromMenu` | Remove item dos menus. |
| `AddManageMenu` | Adiciona item ao menu de gerenciamento. |
| `RemoveManageMenu` | Remove do menu de gerenciamento. |
| `AddPlayerMenu` | Adiciona item ao menu do jogador. |
| `RemovePlayerMenu` | Remove do menu do jogador. |
| `addRecipe` | Adiciona receita drag-to-craft dinamicamente. |
| `addVip` | Adiciona VIP a jogador (online/offline). |
| `removeVip` | Remove VIP de jogador. |

### Server

| Export | Descrição |
|---|---|
| `VipAdm` | Gerenciamento de VIP (add/remove). |
| `addRecipe` | Adiciona receita drag-to-craft dinamicamente. |
| `itemPlace` | Colocar item como prop no mundo. |

## NUI

### Drift Points Display (`web-side/`)
- **Framework:** Vue.js 2.5.17
- **Localização:** Bottom-center HUD com borda verde, ícone de drift, contador de pontos.
- **Mensagem:** `SendNUIMessage({ drift: <points> })`
- **Font:** Orbitron (Google Fonts)

## Conexões entre resources MRI Qbox

| Resource | Integração |
|---|---|
| `mri_Qjobsystem` | Verificação de boss/recruiter no menu F9. |
| `mri_Qadmin` | Fallback para setJob/setGang. |
| `mri_Qvinewood` | Menu option condicional no F9. |
| `qbx_management` | Boss menu, fetch de jogadores próximos. |
| `qbx_core` | Player data, jobs, gangs, metadata em todo o resource. |

## Estrutura de arquivos 📁

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
│   │   │   ├── target-modules/ # Dumpsters, per-door entry
│   │   │   └── utilities-modules/ # Commands, exports, fixes
│   │   └── server-side/
│   │       ├── ox_lib-modules/ # Drop items, staff, VIP
│   │       └── utilities-modules/ # Commands, utils
│   └── waterCooler/            # Sistema de hidratação
└── web-side/                   # NUI drift points (Vue.js)
    ├── index.html
    ├── core.js
    └── icones/
```

## Dependências

### Obrigatórias
- `ox_lib` — Menus, callbacks, notificações, progress bars, keybinds.
- `qbx_core` — Framework principal.
- `qbx_management` — Boss menu, player fetching.
- `oxmysql` — SQL queries (staff/VIP lookups).
- `ox_inventory` — Weight checks, drop items, drag craft, item carrying.
- `ox_target` — Targeting (dumpsters, vehicle doors, water cooler).

### Opcionais
- `mri_Qjobsystem` — Boss/recruiter checks.
- `mri_Qadmin` — Admin menu integration.
- `mri_Qvinewood` — Vinewood menu entry.
- `ps-adminmenu` — Fallback admin menu.
- `scully_emotemenu` — Emote cancellation.
- `hud` — HUD needs update.

## Observações importantes ⚠️

- O resource define `GlobalState.UIColors` que é consumido por outros resources MRI Qbox.
- O sistema de drag-to-craft usa hooks do ox_inventory — receitas podem ser adicionadas dinamicamente via export.
- O cinematic de boas-vindas spawna o jogador em coords fixas após a animação.
- Water cooler tem proteção contra abuso (morte por beber demais em 1 minuto).
- Item collection usa `ox_inventory:Items()` para mapear modelos de props para itens.
- O módulo `mercosulplates.lua` está deprecated — substituído por `mri_Qcarplates`.

Contribuições e melhorias são bem-vindas — abra PRs ou issues. 🙌
