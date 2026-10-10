-- MRI shops over ox_inventory/data/shops.lua: each entry replaces the original, false removes it (see README)
return {
-- removidas do original
	YouTool = false,
	PoliceArmoury = false,
	Medicine = false,
	BlackMarketArms = false,
	VendingMachineDrinks = false,

	General = {
		name = 'Loja de Conveniência',
		inventory = {
			{ name = 'burger', price = 10 },
			{ name = 'water', price = 10 },
			{ name = 'cola', price = 10 },
		}, locations = {
			vec3(25.7, -1347.3, 29.49),
			vec3(-3038.71, 585.9, 7.9),
			vec3(-3241.47, 1001.14, 12.83),
			vec3(1728.66, 6414.16, 35.03),
			vec3(1697.99, 4924.4, 42.06),
			vec3(1961.48, 3739.96, 32.34),
			vec3(547.79, 2671.79, 42.15),
			vec3(2679.25, 3280.12, 55.24),
			vec3(2557.94, 382.05, 108.62),
			vec3(373.55, 325.56, 103.56),
			vec3(1164.9, -323.65, 69.21),
		}, targets = {
			{ loc = vec3(24.45, -1345.93, 28.5), heading = 264.73, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' },
			{ loc = vec3(-3040.27, 584.15, 6.91), heading = 12.33, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' },
			{ loc = vec3(-3243.47, 1000.04, 11.83), heading = 354.74, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' },
			{ loc = vec3(1728.37, 6416.31, 34.04), heading = 239.19, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' },
			{ loc = vec3(1697.29, 4923.46, 41.06), heading = 317.79, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' },
			{ loc = vec3(1959.47, 3741.07, 31.34), heading = 296.46, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' },
			{ loc = vec3(549.22, 2670.09, 41.16), heading = 88.62, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' },
			{ loc = vec3(2676.79, 3279.96, 54.24), heading = 327.13, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' },
			{ loc = vec3(2555.95, 380.81, 107.62), heading = 347.61, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' },
			{ loc = vec3(372.89, 327.66, 102.57), heading = 252.27, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' },
			{ loc = vec3(1164.9, -323.65, 68.21), heading = 97.05, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' },
		}
	},

	Liquor = {
		name = 'Loja de Bebidas',
		inventory = {
			{ name = 'water', price = 10 },
			{ name = 'cola', price = 10 },
			{ name = 'burger', price = 15 },
		}, locations = {
			vec3(1135.808, -982.281, 46.415),
			vec3(-1222.915, -906.983, 12.326),
			vec3(-1487.553, -379.107, 40.163),
			vec3(-2968.243, 390.910, 15.043),
			vec3(1166.024, 2708.930, 38.157),
			vec3(1392.562, 3604.684, 34.980),
			vec3(-1393.409, -606.624, 30.319)
		}, targets = {
			{ loc = vec3(1134.2, -981.95, 45.42), heading = 271.46, ped = `a_m_m_genfat_02`, scenario = 'WORLD_HUMAN_DRINKING' },
			{ loc = vec3(-1222.61, -908.73, 11.33), heading = 30.93, ped = `a_m_m_genfat_02`, scenario = 'WORLD_HUMAN_DRINKING' },
			{ loc = vec3(-1485.74, -378.51, 39.16), heading = 126.89, ped = `a_m_m_genfat_02`, scenario = 'WORLD_HUMAN_DRINKING' },
			{ loc = vec3(-2966.52, 390.17, 14.04), heading = 83.17, ped = `a_m_m_genfat_02`, scenario = 'WORLD_HUMAN_DRINKING' },
			{ loc = vec3(1166.61, 2710.89, 38.16), heading = 176.06, ped = `a_m_m_genfat_02`, scenario = 'WORLD_HUMAN_DRINKING' },
			{ loc = vec3(1391.97, 3606.06, 33.98), heading = 192.75, ped = `a_m_m_genfat_02`, scenario = 'WORLD_HUMAN_DRINKING' },
		}
	},

	Ammunation = {
		name = 'Loja de Armas',
		inventory = {
			{ name = 'ammo-9', price = 5, },
			{ name = 'WEAPON_KNIFE', price = 200 },
			{ name = 'WEAPON_BAT', price = 100 },
			{ name = 'WEAPON_PISTOL', price = 1000, metadata = { registered = true }, license = 'weapon' }
		}, locations = {
			vec3(-662.180, -934.961, 21.829),
			vec3(810.25, -2157.60, 29.62),
			vec3(1693.44, 3760.16, 34.71),
			vec3(-330.24, 6083.88, 31.45),
			vec3(252.63, -50.00, 69.94),
			vec3(22.56, -1109.89, 29.80),
			vec3(2567.69, 294.38, 108.73),
			vec3(-1117.58, 2698.61, 18.55),
			vec3(842.44, -1033.42, 28.19)
		}, targets = {
			{ loc = vec3(-662.1, -933.54, 20.83), heading = 175.42, ped = `cs_terry`, scenario = 'WORLD_HUMAN_DRINKING' },
			{ loc = vec3(810.26, -2159.07, 28.62), heading = 355.69, ped = `cs_terry`, scenario = 'WORLD_HUMAN_DRINKING' },
			{ loc = vec3(1691.98, 3760.95, 33.71), heading = 228.58, ped = `cs_terry`, scenario = 'WORLD_HUMAN_DRINKING' },
			{ loc = vec3(-330.29, 6085.54, 31.57), length = 0.6, width = 0.5, heading = 225.0, minZ = 31.4, maxZ = 31.8, distance = 2.0 },
			{ loc = vec3(252.85, -51.62, 70.0), length = 0.6, width = 0.5, heading = 70.0, minZ = 69.9, maxZ = 70.3, distance = 2.0 },
			{ loc = vec3(23.68, -1106.46, 29.91), length = 0.6, width = 0.5, heading = 160.0, minZ = 29.8, maxZ = 30.2, distance = 2.0 },
			{ loc = vec3(2566.59, 293.13, 108.85), length = 0.6, width = 0.5, heading = 360.0, minZ = 108.7, maxZ = 109.1, distance = 2.0 },
			{ loc = vec3(-1117.61, 2700.26, 18.67), length = 0.6, width = 0.5, heading = 221.82, minZ = 18.5, maxZ = 18.9, distance = 2.0 },
			{ loc = vec3(841.05, -1034.76, 28.31), length = 0.6, width = 0.5, heading = 360.0, minZ = 28.2, maxZ = 28.6, distance = 2.0 }
		}
	},

	VendingMachineSoda = {
		name = 'Máquina de Refrigerante',
		inventory = {
			{ name = 'cola', price = 8 },
		},
		model = {
			`prop_vend_soda_02`, `prop_vend_fridge01`, `prop_vend_soda_01`
		}
	},

	VendingMachineCoffee = {
		name = 'Máquina de Café',
		inventory = {
			{ name = 'coffee', price = 5 },
		},
		model = {
			'prop_vend_coffe_01'
		}
	},

	VendingMachineWater = {
		name = 'Máquina de Água',
		inventory = {
			{ name = 'water', price = 4 },
		},
		model = {
			'prop_vend_water_01'
		}
	},

	PetShop = {
		name = 'Pet Shop',
		inventory = {
			{ name = 'petfood',                 price = 500, },
			{ name = 'collarpet',               price = 2000, },
			{ name = 'firstaidforpet',          price = 2000, },
			{ name = 'petnametag',              price = 2000, },
			{ name = 'petwaterbottleportable',  price = 500, },
			{ name = 'petgroomingkit',          price = 75000, },
			{ name = 'keepcompanionhusky',      price = 75000, count = 5, },
			{ name = 'keepcompanionpoodle',     price = 45000, count = 5, },
			{ name = 'keepcompanionrottweiler', price = 75000, count = 5, },
			{ name = 'keepcompanionwesty',      price = 30000, count = 5, },
			{ name = 'keepcompanioncat',        price = 25000, count = 10, },
			{ name = 'keepcompanionpug',        price = 50000, count = 5, },
			{ name = 'keepcompanionretriever',  price = 50000, count = 5, },
			{ name = 'keepcompanionshepherd',   price = 50000, count = 5, },
			{ name = 'keepcompanionhen',        price = 25000, count = 10, },
			{ name = 'keepcompanionrat',        price = 25000, count = 10, },
			{ name = 'keepcompanionrabbit',     price = 25000, count = 20, },
		},
		locations = {
			vec3(405.84, 317.99, 103.13),
		},
		targets = {
			{ loc = vec3(404.57, 318.28, 102.13), heading = 255, ped = `a_m_y_epsilon_02`, scenario = 'CODE_HUMAN_COWER'},
		}
	},

	Poacher = {
		name = 'Poacher',
		inventory = {
			{ name = 'keepcompanionmtlion',  price = 75000, count = 5, currency = 'black_money', },
			{ name = 'keepcompanionmtlion2', price = 75000, count = 5, currency = 'black_money', },
			{ name = 'keepcompanioncoyote',  price = 75000, count = 5, currency = 'black_money', },
		},
		locations = {
			vec3(409.57, 329.04, 103.13),
		},
		targets = {

		}
	},
}
