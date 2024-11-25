<h1 align='center'>
  pf_wrs
</h1>

<div align="center">
Water refill system with security measures and kick functionality
</div>
<p align="center">
  <img src="image.png" width="350" title="pf_wrs">
</p>
<div align='center'>
  
  ![GitHub License](https://img.shields.io/github/license/PFScripts/pf_wrs?label=License&labelColor=%E2%80%8E%E2%80%8E&color=%2330b893)
  <a href='https://discord.gg/QhMmyx8xsE'>
    ![Discord](https://img.shields.io/discord/1279910494425186446?style=flat&logo=discord&logoColor=%2330b893&label=%E2%80%8E%20&labelColor=%E2%80%8E%E2%80%8E&color=%2330b893)
  </a>
</div>

## `Information`

### `Features` 

- Lets you refill empty water bottles in water fountains / sinks / water coolers
- Player drop functionality and security implementations with customizable reasons
- Fully costumizable

## `Requirements`

- [**qbx_smallresources**](https://github.com/Qbox-project/qbx_smallresources)
- [**ox_inventory**](https://github.com/overextended/ox_inventory)
- [**ox_lib**](https://github.com/overextended/ox_lib)


## `Getting Started`

### `Installation`


1. Download the script from [GitHub](https://github.com/try2diept/pf_wrs).
2. Extract the folder into your FiveM resources directory.
3. Add `start pf_wars` to your `server.cfg`.

### note:
to be able to use the script to a full extent, follow these steps:
1. Add the following code in `ox_inventory\data\items.lua`:
```lua
    ["water_bottle"] = {
		label = "Garrafa de Água",
		weight = 200,
		stack = true,
		close = true,
		decay = true,
		degrade = 120, -- Dura 3 dias (In Game) 1 dia são 40 mins lmao
		description = "Apenas uma garrafa de água",
		client = {
			image = "water_bottle.png",
		}
	},
	["empty_water_bottle"] = {
		label = "Garrafa de Água",
		weight = 200,
		stack = true,
		description = "Garrafa de água vazia",
	},
```
2. Add the following code in `qbx_smallresources\qbx_consumables\config.lua` in "drinks":
```lua
 water_bottle = {
                min = 5,
                max = 8,
                stressRelief = {
                    min = 0,
                    max = 0
                },
            },
```
[note: if already is "water" just edit]
3.  replace the following code in `qbx_smallresources\qbx_consumables\server.lua`:
```lua
for drink, params in pairs(config.consumables.drink) do
    exports.qbx_core:CreateUseableItem(drink, function(source, item)
        local drank = lib.callback.await('consumables:client:Drink', source, params.anim, params.prop)
        if not drank then return end
        if not exports.ox_inventory:RemoveItem(source, item.name, 1, nil, item.slot) then return end

        local sustenance = math.random(params.min, params.max)
        relieveStress(source, params.stressRelief.min, params.stressRelief.max)

        addThirst(source, sustenance)
    end)
end
```
with:
```lua
for drink, params in pairs(config.consumables.drink) do
    exports.qbx_core:CreateUseableItem(drink, function(source, item)
        local drank = lib.callback.await('consumables:client:Drink', source, params.anim, params.prop)
        if not drank then return end
        if not exports.ox_inventory:RemoveItem(source, item.name, 1, nil, item.slot) then return end

        local sustenance = math.random(params.min, params.max)
        relieveStress(source, params.stressRelief.min, params.stressRelief.max)

        addThirst(source, sustenance)
        if item.name == 'water_bottle' then
            if exports.ox_inventory:CanCarryItem(source, 'water_bottle', 1) then
                exports.ox_inventory:AddItem(source, 'empty_water_bottle', 1)
            else
                lib.notify({title = 'Inventory', description = 'You can´t carry any more items', type = 'error'})
            end
        end
    end)
end
```

## Configuration

- You can configure the script using the provided `config.lua` file. Below is an example of how you can customize various parameters.
- Can change / add new languages in `locales/*`
