# mri_Qbox — Manual

Recurso guarda-chuva da suite MRI: reúne os menus F9/F10, o sistema de staff e VIP, e um conjunto de módulos opcionais de combate, veículos e interação que ligam os demais recursos MRI ao `qbx_core`.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Permissões (ACE)](#permissões-ace)
4. [Configuração](#configuração)
5. [Comandos](#comandos)
6. [Teclas](#teclas)
7. [Menus F9 e F10](#menus-f9-e-f10)
8. [Staff](#staff)
9. [VIP](#vip)
10. [Módulos](#módulos)
11. [Integrações](#integrações)
12. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
13. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `ox_lib` | Sim | Importado no `fxmanifest.lua` (`@ox_lib/init.lua`). Menus, comandos, callbacks, keybinds, principals |
| `qbx_core` | Sim | Importa `@qbx_core/modules/playerdata.lua`. Fonte de `QBX.PlayerData`, jobs, gangs e metadata |
| `oxmysql` | Sim | Importado no `fxmanifest.lua`. Lista de players para os painéis de staff e VIP |
| `ox_inventory` | Sim | Peso, drop de itens, drag-craft, item carry, item collection, `/viewallitems` |
| `ox_target` | Sim | Lixeiras, entrada por porta do veículo, water cooler, itemcollection |
| `qb-core` | Sim (se `vipmenu.Enable`) | `modules/mri/server-side/ox_lib-modules/vip.lua` chama `exports['qb-core']:GetCoreObject()` no load |
| `qbx_management` | Sim (para os painéis) | `qbx_management:server:getPlayers` (busca de jogadores próximos) e `OpenBossMenu` (`/menu`) |
| `mri_Qjobsystem` | Sim (para o menu F9) | O menu do jogador chama `CheckPlayerIsbossByJobSystemData` sem checar se o recurso existe — o menu quebra sem ele |
| `mri_Qadmin` | Não | Usado como destino preferencial de `setPlayerJob`/`setPlayerGang` |
| `ps-adminmenu` | Não | Fallback de `setPlayerJob`/`setPlayerGang` quando o `mri_Qadmin` não está iniciado |
| `mri_Qvinewood` | Não | Adiciona a entrada "Vinewood" no menu de gerenciamento |

Os menus F9/F10 disparam comandos de outros recursos (`doorlock`, `blip`, `bau`, `npc`, `objectspawner`, `elevador`, `garagelist`, `craft:create`, `open_jobs`, `spotlight`, `weather`, `adm`…). Cada entrada só funciona se o recurso que registra aquele comando estiver instalado — o `mri_Qbox` não valida isso.

---

## Instalação

1. Copie a pasta `mri_Qbox` para `resources/`.
2. Adicione ao `server.cfg`, depois de `ox_lib`, `qbx_core`, `oxmysql`, `ox_inventory` e `ox_target`:
   ```
   ensure mri_Qbox
   ```
3. Libere a ACE de admin (ver [Permissões (ACE)](#permissões-ace)).
4. Ajuste `config.lua` — quase todos os módulos vêm com `toggle = false` e precisam ser ligados individualmente.
5. Não há SQL para importar. Staff e VIP são gravados na metadata do player (`players.metadata`), tabela que o `qbx_core` já cria.

---

## Permissões (ACE)

Os comandos administrativos usam `restricted = 'group.admin'` do `ox_lib`:

```
add_ace group.admin command allow
add_principal identifier.fivem:1 group.admin
```

Além disso, o recurso **concede principals dinamicamente**:

- Ao entrar no servidor, quem tem `metadata.staff` recebe o principal correspondente (`group.admin`, `group.mod`, `group.support`) via `lib.addPrincipal`.
- Ao entrar, quem tem `metadata.vip` recebe o principal com o nome do tier (`tier1`, …).

Ou seja, o cargo de staff é persistido na metadata do personagem e reaplicado como ACE a cada login — não é preciso mexer no `server.cfg` para cada admin.

---

## Configuração

Arquivo principal: `config.lua` (tabela global `cfg`).

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `cfg.printidentifiers` | bool | Não | Imprime todos os identifiers do jogador no console em `playerConnecting` |
| `cfg.vipmenu.Enable` | bool | Não | Liga o sistema de VIP. Se `false`, os arquivos de VIP saem no `return` inicial |
| `cfg.vipmenu.PaycheckInterval` | number | Não | Intervalo do salário VIP, em minutos. `0` ou menos desliga o pagamento |
| `cfg.vipmenu.CashType` | string | Não | Conta que recebe o salário: `money`, `bank` ou `crypto` |
| `cfg.vipmenu.CoinType` | string | Não | Símbolo da moeda exibido na notificação de salário |
| `cfg.vipmenu.Roles` | tabela | Sim (se `Enable`) | Tiers de VIP. **Precisa conter a chave `nenhum`** — é o fallback usado para quem não é VIP |
| `cfg.vipmenu.Roles[tier].label` | string | Sim | Nome exibido nos menus |
| `cfg.vipmenu.Roles[tier].payment` | number | Sim | Valor do salário por intervalo |
| `cfg.vipmenu.Roles[tier].inventory` | number | Sim | Peso máximo do inventário em kg (multiplicado por 1000 e aplicado com `ox_inventory:SetMaxWeight`) |
| `cfg.indestructibleProps` | bool | Não | Congela props de rua/tráfego para não serem destruídos |
| `cfg.dropitems` | bool | Não | Liga o drop de itens como prop no mundo |
| `cfg.dropitems_table` | tabela | Não | Mapa `item = modelo do prop`. Só os itens listados aqui viram prop ao serem largados |
| `cfg.entervehicle.toggle` | bool | Não | Adiciona opções de target em cada porta do veículo para entrar direto naquele assento |
| `cfg.dumpsters.toggle` | bool | Não | Liga as lixeiras (esconder-se e vasculhar) |
| `cfg.dumpsters.HideProps.Model` | array | Não | Hashes dos props em que o jogador pode se esconder |
| `cfg.dumpsters.TrashProps.Model` | array | Não | Hashes dos props que podem ser vasculhados |
| `cfg.disablefreepunch.toggle` | bool | Não | Só permite socar mirando (evita soco acidental ao usar o target) |
| `cfg.forcedfirstperson.twopov` | bool | Não | Reduz as visões de câmera a duas (primeira e terceira pessoa) |
| `cfg.forcedfirstperson.invehicle.ativar` | bool | Não | Força primeira pessoa dentro do veículo |
| `cfg.forcedfirstperson.invehicle.hold` | bool | Não | Só força primeira pessoa no veículo enquanto segura arma |
| `cfg.disablecombatroll.toggle` | bool | Não | Desativa o rolamento de combate |
| `cfg.damageragdoll.toggle` | bool | Não | Faz o jogador cair ao levar tiro na perna |
| `cfg.disableblindfiring.toggle` | bool | Não | Desativa o tiro cego atrás de cobertura |
| `cfg.realisticrecoil.hideCrosshair` | bool | Não | Esconde a mira nativa do GTA ao apontar |
| `cfg.realisticrecoil.drunkAiming` | bool | Não | Mira instável ("bêbada") |
| `cfg.realisticrecoil.drunkAimingPower` | number | Não | Intensidade do tremor da mira |
| `cfg.realisticrecoil.verticalRecoil` | bool | Não | Recuo vertical ao atirar |
| `cfg.realisticrecoil.disableAimPunching` | bool | Não | Bloqueia socar enquanto mira |
| `cfg.realisticrecoil.disableHeadshots` | bool | Não | Remove o one-shot na cabeça |
| `cfg.realisticrecoil.whitelistedWeapons` | tabela | Não | Armas sem recuo (por hash de nome) |
| `cfg.realisticrecoil.recoilMultipliers` | tabela | Não | Multiplicador de recuo vertical por classe de arma (`PISTOL`, `SMG`, `RIFLE`, `LMG`, `SHOTGUN`, `SNIPER`, `VEHICLE`) |
| `cfg.wheelbreak.toggle` | bool | Não | Roda quebra/solta em colisão |
| `cfg.wheelbreak.mode` | string | Não | `impact` (usa força do impacto) ou `speed` (usa velocidade mínima) |
| `cfg.wheelbreak.impactDamage` | number | Não | (`impact`) dano de lataria perdido de uma vez para quebrar a roda |
| `cfg.wheelbreak.minImpactSpeed` | number | Não | (`impact`) velocidade mínima em km/h para validar o impacto |
| `cfg.wheelbreak.impactDeltaSpeed` | number | Não | (`impact`) perda mínima de velocidade em km/h num instante |
| `cfg.wheelbreak.cooldown` | number | Não | ms entre uma quebra e outra no mesmo veículo |
| `cfg.wheelbreak.speed` | number | Não | (`speed`) velocidade mínima em km/h para quebrar a roda |
| `cfg.savewheelpos.toggle` | bool | Não | Mantém o ângulo do volante ao sair do veículo |
| `cfg.disableaircontrol.toggle` | bool | Não | Bloqueia pular/sair do veículo enquanto ele está no ar |
| `cfg.carexplosion.toggle` | bool | Não | Veículo explode ao cair de altura |
| `cfg.carexplosion.height` | number | Não | Altura da queda que dispara a explosão |
| `cfg.drift.toggle` | bool | Não | Liga o drift com Shift |
| `cfg.drift.points` | bool | Não | Mostra o contador de pontos de drift na NUI |
| `cfg.drift.speed` | number | Não | Velocidade máxima em que o drift funciona |
| `cfg.mercosulplates.toggle` | bool | Não | **Deprecado.** Substituído pelo recurso `mri_Qcarplates` |

### Chaves de config sem implementação

`cfg.SqlBackup` e `cfg.AutoUpdater` existem no `config.lua`, mas **nenhum arquivo do repositório lê essas chaves**. Alterá-las não tem efeito.

### Configs por módulo

| Arquivo | Conteúdo |
|---|---|
| `modules/dragCraft/config.lua` | Receitas do drag-to-craft (`RECIPES`) |
| `modules/itemCarry/server/data.lua` | Itens que geram prop visual ao serem carregados (`CARRY_ITEMS`) |
| `modules/waterCooler/config/config.lua` | Props-alvo, distâncias, progress bar, itens de garrafa e hidratação |
| `modules/cinematic/client/config.lua` | Planos de câmera da cinemática de boas-vindas |

---

## Comandos

| Comando | Permissão | Descrição |
|---|---|---|
| `/tpway` | Nenhuma | Teleporta para o waypoint marcado no mapa (executa `tpm` no cliente) |
| `/god [id]` | Nenhuma | Revive o jogador informado ou você mesmo. **Sem restrição de permissão no código** |
| `/menu <job>` | Nenhuma | Abre o boss menu do job informado (`qbx_management:OpenBossMenu`) |
| `/cutscene <nome>` | Nenhuma | Reproduz uma cutscene nativa do GTA pelo nome |
| `/setargang <id>` | Nenhuma | Abre o diálogo de definir gangue do jogador informado. **Sem restrição de permissão no código** |
| `/item <item> [count] [target] [type]` | `group.admin` | Adiciona um item ao inventário (seu ou do alvo) |
| `/tuning` | `group.admin` | Aplica todos os mods no veículo em que você está |
| `/customs` | `group.admin` | Abre o menu de customização do veículo atual |
| `/menu_admin` | `group.admin` | Abre o menu administrativo (mesma coisa que F10) |
| `/raycast` | `group.admin` | Seleciona coordenadas no mundo por raycast e copia para o clipboard |
| `/models` | `group.admin` | Copia para o clipboard a lista de modelos de veículo presentes no servidor mas ausentes da `VehicleList` |
| `/viewallitems` | `group.admin` | Abre um stash temporário com todos os itens do servidor (exceto `identification`) |
| `/staff <id> <add\|rem> [cargo]` | `group.admin` | Concede ou remove cargo de staff (`admin`, `mod`, `support`) |
| `/vipadm <id> <add\|rem> [tier]` | `group.admin` | Concede ou remove um tier de VIP |
| `/cinematic` | `group.admin` | Dispara a cinemática de boas-vindas para quem executou |

`/god`, `/tpway`, `/setargang` e `/cutscene` estão sem restrição — o `restricted` está comentado no código-fonte de `/god` e `/tpway`.

---

## Teclas

| Tecla | Ação |
|---|---|
| `F9` | Abre o menu do jogador |
| `F10` | Abre o menu administrativo (executa `/menu_admin`, que exige `group.admin`) |

As duas são keybinds do `ox_lib` (`menu_jogador_keybind` e `menu_admin_keybind`), então o jogador pode reatribuí-las nas configurações do FiveM.

---

## Menus F9 e F10

### F9 — menu do jogador

Entradas fixas: Identificação (`/id`), Emprego (`/job`), Gangue (`/gang`), Ver Reputação (`/rep`), Ver Habilidades (`/skill`) e Waypoints (limpar marcadores e configurações).

"Gerenciar Emprego" e "Gerenciar Gangue" só aparecem se o `mri_Qjobsystem` disser que o jogador é chefe ou recrutador.

### F10 — menu de administração

Entradas fixas: Abrir Painel (`/adm`), Customizar Veículo (`/customs`), Relógio (hora, escala de tempo, congelar tempo), Clima (`/weather`) e Gerenciamento.

O submenu **Gerenciamento** agrupa comandos de outros recursos: Portas (`doorlock`), Blips (`blip`), Baús (`bau`), NPC (`npc`), Props (`objectspawner`), Elevador (`elevador`), Outdoors/Posters (`rw_draw++`), Garagens (`garagelist`), Crafting (`craft:create` / `craft:edit`), Grupos (`createjob` / `open_jobs`) e Spotlight. Se o `mri_Qvinewood` estiver iniciado, aparece também a entrada Vinewood.

### Menus extensíveis

Os três menus aceitam entradas de outros recursos em runtime — ver [Entrypoints](#entrypoints-para-outros-recursos). Os alvos válidos são `'player'` (F9), `'f10'` (F10) e `'management'` (submenu Gerenciamento).

---

## Staff

O cargo de staff é gravado em `metadata.staff` do personagem, com o valor no formato `group.<cargo>` (`group.admin`, `group.mod`, `group.support`).

- `/staff <id> add <cargo>` — grava a metadata e concede o principal na hora.
- `/staff <id> rem` — remove o principal e limpa a metadata.
- No login (`QBCore:Server:OnPlayerLoaded`), o principal é reaplicado a partir da metadata.
- O painel de staff (registrado no menu de Gerenciamento) lista todos os personagens do banco com metadata de staff, online e offline, e permite alterar o cargo de jogadores offline via `mri_Qbox:server:manageStaff`.

---

## VIP

Ligado por `cfg.vipmenu.Enable`. O tier é gravado em `metadata.vip` e vira principal de ACE com o mesmo nome do tier.

- **Salário** — a cada `PaycheckInterval` minutos, cada jogador online com VIP recebe `Roles[tier].payment` na conta definida em `CashType`.
- **Peso do inventário** — no login e a cada alteração de VIP, o peso máximo é definido como `Roles[tier].inventory * 1000` gramas. Quem não é VIP usa `Roles.nenhum.inventory` — por isso a chave `nenhum` é obrigatória.
- **Painel** — entrada no menu F10; lista VIPs online e offline e permite adicionar/remover.

---

## Módulos

Cada módulo é ligado individualmente pelo `config.lua`. Os que estão desligados fazem `return` no topo do arquivo e não custam nada.

### Combate (`modules/mri/client-side/combat-modules/`)

| Módulo | Config | O que faz |
|---|---|---|
| `damageragdoll.lua` | `cfg.damageragdoll` | Ragdoll ao levar tiro na perna |
| `disableblindfiring.lua` | `cfg.disableblindfiring` | Remove o tiro cego em cobertura |
| `disablecombatroll.lua` | `cfg.disablecombatroll` | Remove o rolamento de combate |
| `disablefreepunch.lua` | `cfg.disablefreepunch` | Só permite socar mirando |
| `forcedfirstperson.lua` | `cfg.forcedfirstperson` | Restringe as visões de câmera / força primeira pessoa no veículo |
| `realisticrecoil.lua` | `cfg.realisticrecoil` | Recuo vertical, mira instável, sem headshot, sem crosshair |

### Veículos (`modules/mri/client-side/vehicles-modules/`)

| Módulo | Config | O que faz |
|---|---|---|
| `drift.lua` | `cfg.drift` | Drift com Shift; contador de pontos na NUI (`web-side/`) |
| `wheelbreak.lua` | `cfg.wheelbreak` | Roda quebra em impacto forte |
| `savewheelpos.lua` | `cfg.savewheelpos` | Mantém o ângulo do volante ao estacionar |
| `disableaircontrol.lua` | `cfg.disableaircontrol` | Bloqueia sair/pular do veículo no ar |
| `carexplosion.lua` | `cfg.carexplosion` | Explosão ao cair de altura |
| `mercosulplates.lua` | `cfg.mercosulplates` | Deprecado — use `mri_Qcarplates` |

### Target (`modules/mri/client-side/target-modules/`)

| Módulo | Config | O que faz |
|---|---|---|
| `dumpsters.lua` | `cfg.dumpsters` | "Esconder" e "Vasculhar" em lixeiras via `ox_target` |
| `entervehicle.lua` | `cfg.entervehicle` | Entrar no veículo pela porta que estiver mirando. Bloqueia veículos de concessionária (`state.isVehicleShopEntity`) |
| `trunkchest.lua` | — | **Arquivo inteiramente comentado** — não faz nada |

### Utilitários

| Módulo | O que faz |
|---|---|
| `indestructibleprops.lua` | Congela props de rua (ligado por `cfg.indestructibleProps`) |
| `maskfix.lua` | Corrige clipping de máscara em faces freemode |
| `oncache.lua` | Desliga o capacete automático de moto (`SetPedConfigFlag 35`) |
| `cutscene.lua` | `/cutscene <nome>` — reproduz cutscene nativa |
| `exports.lua` | `GetRayCoords` e `Request` |
| `checkWeight.lua` | `CanCarryItem` |
| `dropitems.lua` (server) | Hook `swapItems` do `ox_inventory`: largar um item de `cfg.dropitems_table` cria o drop com o prop correspondente |
| `connect.lua` (server) | Imprime identifiers no `playerConnecting` |

### Módulos independentes (`modules/*/`)

| Módulo | O que faz |
|---|---|
| `cinematic/` | Cinemática de boas-vindas: percorre os planos de câmera do config, força clima e horário e, ao final, teleporta o jogador para `vector3(304.44, -1204.42, 38.89)` (posição fixa no código) |
| `dragCraft/` | Craft por arrasto no `ox_inventory`: arrastar item A sobre item B produz o resultado da receita. Hooks `swapItems` no servidor; receitas em `modules/dragCraft/config.lua` |
| `itemCarry/` | Prop visual anexado ao jogador ao carregar certos itens (`CARRY_ITEMS`), com `walkOnly` e `blockVehicle` |
| `itemcollection/` | Pegar props do mundo como item e colocar itens no mundo como prop. Os modelos são derivados do campo `prop` dos itens do `ox_inventory` — não há lista fixa |
| `waterCooler/` | Beber em bebedouros/pias (aumenta `thirst`) e encher `empty_water_bottle` → `water_bottle`. Beber demais (`excessiveDrinkCount` vezes em 1 minuto) mata o personagem |

---

## Integrações

### mri_Qjobsystem

O menu F9 chama `CheckPlayerIsbossByJobSystemData` e `CheckPlayerIrecruiterByJobSystemData` para decidir se mostra "Gerenciar Emprego" e "Gerenciar Gangue". A chamada é direta, sem `GetResourceState` — sem o `mri_Qjobsystem` iniciado, o menu do jogador não abre.

### mri_Qadmin

`setPlayerJob` e `setPlayerGang` verificam `GetResourceState('mri_Qadmin')`. Se estiver iniciado, disparam `mri_Qadmin:server:SetJob` / `mri_Qadmin:server:SetGang`. Caso contrário, caem no fallback do `ps-adminmenu`.

### qbx_management

Fonte da lista de jogadores próximos usada nos painéis de staff e VIP (`qbx_management:server:getPlayers`) e do boss menu aberto por `/menu <job>`.

### mri_Qvinewood

Se estiver iniciado, adiciona a entrada "Vinewood" no submenu de Gerenciamento (executa `/vinewood`).

### ox_inventory

Além dos usos diretos (peso, itens, stash temporário), o recurso registra **dois hooks `swapItems`**: um para o drop de itens como prop e outro para o drag-craft.

---

## Entrypoints para outros recursos

### Menus — cliente

Adicionar e remover entradas dos menus F9/F10/Gerenciamento em runtime. É o mecanismo que os outros recursos MRI usam para se plugarem ao painel.

```lua
exports.mri_Qbox:AddPlayerMenu({          -- menu F9
    title = 'Minha opção',
    icon = 'star',
    iconAnimation = 'fade',
    description = 'Descrição da opção',
    arrow = true,
    onSelectFunction = function() ExecuteCommand('meucomando') end,
    onSelectArg = nil,                    -- opcional: argumento passado para onSelectFunction
})
exports.mri_Qbox:RemovePlayerMenu('Minha opção')

exports.mri_Qbox:AddManageMenu({ ... })   -- submenu Gerenciamento (dentro do F10)
exports.mri_Qbox:RemoveManageMenu('Minha opção')

exports.mri_Qbox:AddItemToMenu('f10', { ... })  -- menu F10 direto ('f10' | 'management' | 'player')
exports.mri_Qbox:RemoveItemFromMenu('f10', 'Minha opção')
```

### `GetRayCoords` — cliente

Abre o seletor de coordenadas por raycast. Bloqueia até o jogador confirmar (`E` = vector3, `G` = vector4) ou cancelar (`Q`). Retorna o vetor e já copia para o clipboard; retorna `false` se cancelado.

```lua
local coords = exports.mri_Qbox:GetRayCoords()
```

### `Request` — cliente

Diálogo Sim/Não em menu do `ox_lib`. Bloqueia até a resposta e retorna booleano.

```lua
local confirmou = exports.mri_Qbox:Request('Título', 'Texto da pergunta', 'top-right')
```

### `CanCarryItem` — cliente

Verifica se o jogador aguenta o peso de `amount` unidades do item.

```lua
local pode = exports.mri_Qbox:CanCarryItem('water', 5)
```

### `setPlayerJob` / `setPlayerGang` — cliente

Abrem diálogos de seleção de job/gangue e grade e aplicam no jogador alvo (via `mri_Qadmin` ou `ps-adminmenu`).

```lua
exports.mri_Qbox:setPlayerJob(targetServerId)   -- job opcional; se omitido, abre o seletor
exports.mri_Qbox:setPlayerGang(targetServerId)
```

### `addVip` / `removeVip` — cliente

Usados pelo painel de VIP. Tratam jogador online (via comando `/vipadm`) e offline (via evento `mri_Qbox:server:manageVip`).

```lua
exports.mri_Qbox:addVip({
    vipData = { source = 1, citizenId = 'ABC12345', name = 'Nome Sobrenome', offline = false },
    newRole = 'tier1',
    callback = function() end,   -- opcional
})
```

### `VipAdm` — servidor

Mesma lógica do comando `/vipadm`, chamável de outro recurso. Retorna `true` em caso de sucesso.

```lua
exports.mri_Qbox:VipAdm(source, { id = targetId, tipo = 'add', tier = 'tier1' })
```

### `addRecipe` — cliente e servidor

Adiciona uma receita de drag-craft em runtime; a chamada sincroniza automaticamente o outro lado.

```lua
exports.mri_Qbox:addRecipe('garbage metalscrap', {
    duration = 2000,
    costs  = { garbage = { need = 1, remove = true }, metalscrap = { need = 1, remove = true } },
    result = { { name = 'lockpick', amount = 1 } },
})
```

A chave da receita é `"<itemA> <itemB>"`; a ordem inversa também é aceita no momento do craft.

### `itemPlace` — servidor

Export desenhado para ser usado como hook de item do `ox_inventory` (campo `export` em `data/items.lua`). Coloca o prop do item no chão à frente do jogador e bloqueia o uso dentro de veículo.

```lua
['cadeira'] = {
    label = 'Cadeira',
    weight = 1000,
    prop = 'prop_chair_01a',
    export = 'mri_Qbox.itemPlace',
},
```

### GlobalState `UIColors`

O recurso publica um esquema de cores em `GlobalState.UIColors`, consumido pelos demais recursos MRI:

```lua
{ success = '#51CF66', info = '#668CFF', warning = '#FFD700', danger = '#FF6347' }
```

Para alterar, edite `modules/mri/client-side/ox_lib-modules/context.lua` **e** `modules/mri/client-side/main.lua` — a tabela está duplicada nos dois arquivos.

---

## Estrutura de arquivos

```
mri_Qbox/
├── config.lua                                   — cfg: VIP, drop de itens, combate, veículos, target
├── modules/
│   ├── cinematic/                               — cinemática de boas-vindas (/cinematic)
│   │   ├── client/client.lua                    — planos de câmera, música, teleporte final
│   │   ├── client/config.lua                    — lista de shots (posição, look-at, duração, texto, hora)
│   │   └── server/server.lua                    — comando /cinematic (group.admin)
│   ├── dragCraft/                               — craft arrastando um item sobre outro
│   │   ├── config.lua                           — RECIPES
│   │   ├── client/client.lua                    — progress bar e callbacks client
│   │   └── server/server.lua                    — hook swapItems, fila de craft, addRecipe
│   ├── itemCarry/                               — prop visual ao carregar item
│   │   ├── client/c_itemCarry.lua               — anexa o prop, restringe andar/veículo
│   │   └── server/data.lua                      — CARRY_ITEMS
│   ├── itemcollection/                          — pegar/colocar props do mundo como item
│   │   ├── shared/shared.lua                    — mapa prop → item, derivado do ox_inventory
│   │   ├── client/client.lua                    — target "Pegar" em objetos do mundo
│   │   └── server/server.lua                    — pickup e export itemPlace
│   ├── waterCooler/                             — beber e encher garrafa
│   │   ├── config/config.lua                    — props-alvo, distâncias, itens, hidratação
│   │   ├── client/client.lua                    — target, animação, skill check
│   │   └── server/server.lua                    — hidratação, troca de garrafa, anti-abuso
│   └── mri/
│       ├── client-side/
│       │   ├── main.lua                         — GlobalState.UIColors
│       │   ├── combat-modules/                  — ragdoll, recoil, blind fire, combat roll, free punch, POV
│       │   ├── vehicles-modules/                — drift, wheelbreak, explosão, volante, controle no ar, placas
│       │   ├── target-modules/                  — lixeiras, entrada por porta, trunkchest (comentado)
│       │   ├── ox_lib-modules/                  — menus F9/F10, painel staff, painel VIP, inputs, oncache
│       │   ├── ox_inventory-modules/            — CanCarryItem
│       │   └── utilities-modules/               — comandos, cutscene, raycast/Request, props indestrutíveis, maskfix
│       └── server-side/
│           ├── ox_lib-modules/                  — drop de itens como prop, staff, VIP (salário e peso)
│           └── utilities-modules/               — comandos admin, identifiers no connect, /viewallitems
├── web-side/                                    — NUI do contador de pontos de drift
│   ├── index.html
│   ├── core.js
│   └── icones/
└── fxmanifest.lua
```
