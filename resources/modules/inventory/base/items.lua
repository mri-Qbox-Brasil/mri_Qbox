-- MRI items over ox_inventory/data/items.lua: each entry replaces the original, false removes it (see README)
return {
-- removidos do original
	["testburger"] = false,
	["identification"] = false,
	["phone"] = false,
	["water"] = false,
	["mastercard"] = false,
	["scrapmetal"] = false,
-- ilegal
	["black_money"] = {
		label = "Dinheiro Enrolado",
	},
	["markedbills"] = {
		label = "Dinheiro Marcado",
		weight = 1000,
		stack = false,
		close = true,
		description = "Dinheiro?",
	},
	["rolling_paper"] = {
		label = "Seda",
		weight = 0,
		stack = true,
		close = true,
		description = "Papel feito especificamente para enrolar e fumar tabaco ou cannabis.",
		client = {
			image = "rolling_paper.png",
		},
	},
-- drogas
	["watering_can"] = {
		label = "Regador",
		weight = 500,
		stack = false,
		close = false,
		description = "Um simples regador",
		client = {
			image = "watering_can.png",
		},
	},
	["fertilizer"] = {
		label = "Fertilizante",
		weight = 500,
		stack = false,
		close = false,
		description = "Fertilizante simples.",
		client = {
			image = "fertilizer.png",
		},
	},
	["advanced_fertilizer"] = {
		label = "Fertilizante avançado",
		weight = 500,
		stack = false,
		close = false,
		description = "Fertilizante com muitos nutrientes.",
		client = {
			image = "advanced_fertilizer.png",
		},
	},
	["liquid_fertilizer"] = {
		label = "Fertilizante líquido",
		weight = 200,
		stack = false,
		close = false,
		description = "Basicamente água com nutrientes, o mais barato.",
		client = {
			image = "liquid_fertilizer.png",
		},
	},
	["weed_lemonhaze_seed"] = {
		label = "Semente de Maconha",
		weight = 20,
		stack = true,
		close = true,
		description = "Plante preguiça.",
	},
	["weed_lemonhaze"] = {
		label = "Maconha",
		weight = 20,
		stack = true,
		close = false,
		description = "Um verdinho daquele que o Gordela gosta...",
	},
	["coca_seed"] = {
		label = "Semente de Coca",
		weight = 20,
		stack = true,
		close = true,
		description = "Plante ansiedade.",
	},
	["coca"] = {
		label = "Cocaína",
		weight = 20,
		stack = true,
		close = false,
		description = "Dizem que dá pra mastigar isso...",
	},
	["weed_processing_table"] = {
		label = "Mesa de Produção",
		weight = 1000,
		stack = false,
		close = true,
		description = "Fazer as dolinhas.",
		client = {
			image = "weed_processing_table.png",
		},
	},
	["cocaine_processing_table"] = {
		label = "Mesa de Produção",
		weight = 1000,
		stack = false,
		close = true,
		description = "Encher os ziplocks.",
		client = {
			image = "cocaine_processing_table.png",
		},
	},
	["weed_brick"] = {
		label = "Tijolo de Maconha",
		weight = 1000,
		stack = true,
		close = true,
		description = "Tijolo de maconha de 1 kg para vender para clientes grandes.",
	},
	["meth"] = {
		label = "Metanfetamina",
		weight = 100,
		stack = true,
		close = true,
		description = "Um saquinho de metanfetamina",
	},
	["crackbaggy"] = {
		label = "Dolinha de Crack",
		weight = 5,
		stack = true,
		close = true,
		description = "Para virar um super-nóia.",
	},
	["xtcbaggy"] = {
		label = "Saco de Ecstasy",
		weight = 5,
		stack = true,
		close = true,
		description = "Para ficar feliz mais rápido",
	},
	["weedbaggy"] = {
		label = "Saco de Maconha",
		weight = 5,
		stack = true,
		close = true,
		description = "Fuma, fuma, fuma, folha de bananeira...",
	},
	["cokebaggy"] = {
		label = "Saco de Cocaína",
		weight = 0,
		stack = true,
		close = true,
		description = "Para ficar sem dormir...",
		client = {
			image = "cocaine_baggy.png",
		},
	},
	["coke_brick"] = {
		label = "Tijolo de Cocaína",
		weight = 1000,
		stack = false,
		close = true,
		description = "Pacote pesado de cocaína, usado principalmente para transações e ocupa muito espaço",
		client = {
			image = "coke_brick.png",
		},
	},
	["oxy"] = {
		label = "Oxy com Prescrição",
		weight = 0,
		stack = true,
		close = true,
		description = "O rótulo foi arrancado",
		client = {
			image = "oxy.png",
		},
	},
	["joint"] = {
		label = "Cigarro de Maconha",
		weight = 0,
		stack = true,
		close = true,
		description = "Sidney ficaria muito orgulhoso de você",
		client = {
			image = "joint.png",
		},
	},
-- roubos
	["10kgoldchain"] = {
		label = "Corrente de Ouro 10k",
		weight = 2000,
		stack = true,
		close = true,
		description = "Corrente de ouro 10 quilates.",
		client = {
			image = "10kgoldchain.png",
		},
	},
	["rolex"] = {
		label = "Relógio Dourado",
		weight = 1500,
		stack = true,
		close = true,
		description = "Um relógio de ouro parece ser o jackpot para mim!",
		client = {
			image = "rolex.png",
		},
	},
	["goldbar"] = {
		label = "Barra de Ouro",
		weight = 7000,
		stack = true,
		close = true,
		description = "Parece bem caro para mim",
		client = {
			image = "goldbar.png",
		},
	},
	["goldchain"] = {
		label = "Corrente de Ouro",
		weight = 1500,
		stack = true,
		close = true,
		description = "Uma corrente de ouro parece ser o jackpot para mim!",
		client = {
			image = "goldchain.png",
		},
	},
	["diamond_ring"] = {
		label = "Anel de Diamante",
		weight = 1500,
		stack = true,
		close = true,
		description = "Um anel de diamante parece ser o jackpot para mim!",
		client = {
			image = "diamond_ring.png",
		},
	},
-- roubo a lojinha
	["stickynote"] = {
		label = "Post-it",
		weight = 0,
		stack = false,
		close = false,
		description = "Às vezes útil para lembrar de algo :)",
		client = {
			image = "stickynote.png",
		},
	},
-- roubos casas
	["advancedlockpick"] = {
		label = "Lockpick Avançado",
		weight = 500,
		stack = true,
		close = true,
		description = "Se você perde suas chaves com frequência, isso é muito útil... Também útil para abrir suas cervejas",
		client = {
			image = "advancedlockpick.png",
		},
	},
	["screwdriverset"] = {
		label = "Kit de Ferramentas",
		weight = 1000,
		stack = true,
		close = false,
		description = "Muito útil para aparafusar... parafusos...",
		client = {
			image = "screwdriverset.png",
		},
	},
	["microwave"] = {
		label = "Micro-ondas",
		weight = 46000,
		stack = false,
		close = true,
		description = "Micro-ondas",
	},
	["small_tv"] = {
		label = "TV Pequena",
		weight = 30000,
		stack = false,
		close = true,
		description = "TV",
	},
	["toaster"] = {
		label = "Torradeira",
		weight = 18000,
		stack = false,
		close = true,
		description = "Torrada",
	},
-- roubo a banco
	["electronickit"] = {
		label = "Kit Eletrônico",
		weight = 100,
		stack = true,
		close = true,
		description = "Se você sempre quis construir um robô, talvez possa começar por aqui. Quem sabe você se torne o novo Elon Musk?",
		client = {
			image = "electronickit.png",
		},
	},
	["drill"] = {
		label = "Furadeira",
		weight = 20000,
		stack = true,
		close = false,
		description = "A verdadeira...",
		client = {
			image = "drill.png",
		},
	},
	["bag"] = {
		label = "Bolsa",
		weight = 1000,
		stack = false,
		close = false,
		description = "Uma bolsa bem grande para carregar todo tipo de objeto",
		client = {
			image = "bag.png",
		},
	},
	["thermite"] = {
		label = "Termite",
		weight = 1000,
		stack = true,
		close = true,
		description = "Às vezes você deseja que tudo queime",
		client = {
			image = "thermite.png",
		},
	},
	["security_card_01"] = {
		label = "Cartão de Segurança A",
		weight = 0,
		stack = true,
		close = true,
		description = "Um cartão de segurança... Me pergunto para o que serve",
		client = {
			image = "security_card_01.png",
		},
	},
	["security_card_02"] = {
		label = "Cartão de Segurança B",
		weight = 0,
		stack = true,
		close = true,
		description = "Um cartão de segurança... Me pergunto para o que serve",
		client = {
			image = "security_card_02.png",
		},
	},
	["cryptostick"] = {
		label = "Crypto Stick",
		weight = 200,
		stack = false,
		close = true,
		description = "Por que alguém compraria dinheiro que não existe... Quantos conteria..?",
		client = {
			image = "cryptostick.png",
		},
	},
	["trojan_usb"] = {
		label = "USB Trojan",
		weight = 0,
		stack = true,
		close = true,
		description = "Software útil para desativar alguns sistemas",
		client = {
			image = "usb_device.png",
		},
	},
-- consumíveis
	["burger"] = {
		label = "Hambúrguer",
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = "eating",
			prop = "burger",
			usetime = 2500,
			notification = "Você comeu um delicioso hambúrguer",
		},
	},
	["tosti"] = {
		label = "Sanduíche de Queijo Grelhado",
		weight = 200,
		stack = true,
		close = true,
		description = "Bom para comer.",
		client = {
			image = "tosti.png",
		},
	},
	["cola"] = {
		label = "Cola",
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = { model = "prop_ecola_can", pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = "Você matou sua sede com uma cola",
		},
	},
	["sprunk"] = {
		label = "Sprite",
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = { model = "prop_ld_can_01", pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = "Você matou sua sede com uma sprite",
		},
	},
	["mustard"] = {
		label = "Mostarda",
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = { model = "prop_food_mustard", pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = "Você .. bebeu mostarda",
		},
	},
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
		label = "Garrafa de Água Vazia",
		weight = 10,
		stack = true,
		description = "Garrafa de Água vazia",
	},
	["water_contaminat"] = {
		label = "Água Contaminada",
		weight = 500,
		stack = true,
		close = true,
		cancel = true,
		description = "Água contaminada, não beba isso!",
		client = {
			status = { thirst = -15 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = { model = "prop_ld_flow_bottle", pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -2.5) },
			usetime = 2500,
			remove = function()
				lib.notify({
					title = "Hidratação",
					message = "Você bebeu água contaminada, não é bom para você!",
					icon = "viruses",
					iconColor = "#5C940D",
				})
			end,
		},
	},

	["beer"] = {
		label = "Cerveja",
		weight = 500,
		stack = true,
		close = true,
		description = "Nada como uma boa cerveja gelada!",
		client = {
			image = "beer.png",
		},
	},
	["sandwich"] = {
		label = "Sanduíche",
		weight = 200,
		stack = true,
		close = true,
		description = "Bom pão para o seu estômago",
		client = {
			image = "sandwich.png",
		},
	},
	["vodka"] = {
		label = "Vodka",
		weight = 500,
		stack = true,
		close = true,
		description = "Para todos os sedentos por aí",
		client = {
			image = "vodka.png",
		},
	},
	["coffee"] = {
		label = "Café",
		weight = 200,
		stack = true,
		close = true,
		description = "Aumenta 4 de cafeína",
		client = {
			image = "coffee.png",
		},
	},
-- equipáveis
	["parachute"] = {
		label = "Paraquedas",
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = "clothingshirt", clip = "try_shirt_positive_d" },
			usetime = 1500,
		},
	},
	["armour"] = {
		label = "Colete",
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = "clothingshirt", clip = "try_shirt_positive_d" },
			usetime = 3500,
		},
	},
-- documentação
	["id_card"] = {
		label = "Carteira de Identidade",
		weight = 0,
		stack = false,
		close = false,
		description = "Um cartão contendo todas as suas informações para se identificar.",
		client = {
			image = "id_card.png",
		},
	},
	["lawyerpass"] = {
		label = "Licença de Advogado",
		weight = 0,
		stack = false,
		close = false,
		description = "Passe exclusivo para advogados para mostrar que podem representar um suspeito",
		client = {
			image = "lawyerpass.png",
		},
	},
	["weaponlicense"] = {
		label = "Licença de Arma",
		weight = 0,
		stack = false,
		close = true,
		description = "Licença de arma.",
		client = {
			image = "weapon_license.png",
		},
	},
	["driver_license"] = {
		label = "Carteira de Motorista",
		weight = 0,
		stack = false,
		close = false,
		description = "Permissão para mostrar que você pode dirigir um veículo",
		client = {
			image = "driver_license.png",
		},
	},
-- eletrônicos
-- sd-phone / sd-tablet
	["phone_black"] = {
		label = "Celular Preto",
		weight = 190,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "phone_black.png" },
		server = { export = "sd-phone.usePhone_black" },
	},
	["phone_blue"] = {
		label = "Celular Azul",
		weight = 190,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "phone_blue.png" },
		server = { export = "sd-phone.usePhone_blue" },
	},
	["phone_green"] = {
		label = "Celular Verde",
		weight = 190,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "phone_green.png" },
		server = { export = "sd-phone.usePhone_green" },
	},
	["phone_orange"] = {
		label = "Celular Laranja",
		weight = 190,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "phone_orange.png" },
		server = { export = "sd-phone.usePhone_orange" },
	},
	["phone_pink"] = {
		label = "Celular Rosa",
		weight = 190,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "phone_pink.png" },
		server = { export = "sd-phone.usePhone_pink" },
	},
	["phone_purple"] = {
		label = "Celular Roxo",
		weight = 190,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "phone_purple.png" },
		server = { export = "sd-phone.usePhone_purple" },
	},
	["phone_red"] = {
		label = "Celular Vermelho",
		weight = 190,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "phone_red.png" },
		server = { export = "sd-phone.usePhone_red" },
	},
	["phone_yellow"] = {
		label = "Celular Amarelo",
		weight = 190,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "phone_yellow.png" },
		server = { export = "sd-phone.usePhone_yellow" },
	},
	["tablet_black"] = {
		label = "Tablet Preto",
		weight = 700,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "tablet_black.png" },
		server = { export = "sd-tablet.useTablet_black" },
	},
	["tablet_blue"] = {
		label = "Tablet Azul",
		weight = 700,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "tablet_blue.png" },
		server = { export = "sd-tablet.useTablet_blue" },
	},
	["tablet_green"] = {
		label = "Tablet Verde",
		weight = 700,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "tablet_green.png" },
		server = { export = "sd-tablet.useTablet_green" },
	},
	["tablet_orange"] = {
		label = "Tablet Laranja",
		weight = 700,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "tablet_orange.png" },
		server = { export = "sd-tablet.useTablet_orange" },
	},
	["tablet_pink"] = {
		label = "Tablet Rosa",
		weight = 700,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "tablet_pink.png" },
		server = { export = "sd-tablet.useTablet_pink" },
	},
	["tablet_purple"] = {
		label = "Tablet Roxo",
		weight = 700,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "tablet_purple.png" },
		server = { export = "sd-tablet.useTablet_purple" },
	},
	["tablet_red"] = {
		label = "Tablet Vermelho",
		weight = 700,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "tablet_red.png" },
		server = { export = "sd-tablet.useTablet_red" },
	},
	["tablet_yellow"] = {
		label = "Tablet Amarelo",
		weight = 700,
		stack = false,
		consume = 0,
		close = true,
		client = { image = "tablet_yellow.png" },
		server = { export = "sd-tablet.useTablet_yellow" },
	},
	["radio"] = {
		label = "Rádio",
		weight = 1000,
		stack = false,
		allowArmed = true,
	},
	["radiocell"] = {
		label = "Bateria de Rádio",
		weight = 100,
		stack = false,
		close = false,
		description = "Precisando de uma carga?",
	},
	["laptop"] = {
		label = "Laptop",
		weight = 4000,
		stack = true,
		close = true,
		description = "Laptop caro",
		client = {
			image = "laptop.png",
		},
	},
	["speaker"] = {
		label = "Caixa de Som",
		weight = 475,
		stack = true,
		close = true,
		description = "Põe um som pra tocar DJ!",
	},
-- materiais
	["glass"] = {
		label = "Vidro",
		weight = 100,
		stack = true,
		close = false,
		description = "Reciclável",
	},
	["plastic"] = {
		label = "Plástico",
		weight = 100,
		stack = true,
		close = false,
		description = "Reciclável",
	},
	["rubber"] = {
		label = "Borracha",
		weight = 100,
		stack = true,
		close = false,
		description = "Reciclável",
	},
	["metalscrap"] = {
		label = "Sucata de Metal",
		weight = 100,
		stack = true,
		close = false,
		description = "Você provavelmente pode fazer algo legal com isso.",
	},
	["copper"] = {
		label = "Cobre",
		weight = 100,
		stack = true,
		close = false,
		description = "Belo pedaço de metal que você provavelmente pode usar para algo",
	},
	["iron"] = {
		label = "Ferro",
		weight = 100,
		stack = true,
		close = false,
		description = "Peça útil de metal que você provavelmente pode usar para algo",
	},
	["steel"] = {
		label = "Aço",
		weight = 100,
		stack = true,
		close = false,
		description = "Bela peça de metal que você provavelmente pode usar para algo",
	},
	["aluminum"] = {
		label = "Alumínio",
		weight = 100,
		stack = true,
		close = false,
		description = "Belas peças de metal que você provavelmente pode usar para algo",
	},
	["wood"] = {
		label = "Madeira",
		weight = 1,
		stack = true,
		close = true,
		description = "Belo pedaço de madeira para você fazer algo",
	},
-- diversos
	["money"] = {
		label = "Dinheiro",
	},
	["garbage"] = {
		label = "Lixo",
	},
	["clothing"] = {
		label = "Roupas",
		consume = 0,
	},
	["paperbag"] = {
		label = "Saco de papel",
		weight = 1,
		stack = false,
		close = false,
		consume = 0,
	},
	["panties"] = {
		label = "Calcinha",
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = { model = "prop_cs_panties_02", pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		},
	},
	["notepad"] = {
		label = "Bloco de Notas",
		weight = 0,
		stack = false,
		close = true,
		consume = 0,
		description = "Algumas vezes você precisa se lembrar de algo importante :)",
		server = {
			export = "randol_notes.notepad",
		},
	},
	["tornnote"] = {
		label = "Anotação",
		weight = 0,
		stack = false,
		close = false,
	},
	["binoculars"] = {
		label = "Binóculos",
		weight = 600,
		stack = true,
		close = true,
		description = "Furtivos...",
		client = {
			image = "binoculars.png",
		},
	},
	["firework1"] = {
		label = "2 Irmãos",
		weight = 1000,
		stack = true,
		close = true,
		description = "Fogos de artifício",
		client = {
			image = "firework1.png",
		},
	},
	["firework2"] = {
		label = "Estaladores",
		weight = 1000,
		stack = true,
		close = true,
		description = "Fogos de artifício",
		client = {
			image = "firework2.png",
		},
	},
	["firework3"] = {
		label = "Apaga Tudo",
		weight = 1000,
		stack = true,
		close = true,
		description = "Fogos de artifício",
		client = {
			image = "firework3.png",
		},
	},
	["firework4"] = {
		label = "Weeping Willow",
		weight = 1000,
		stack = true,
		close = true,
		description = "Fireworks",
		client = {
			image = "firework4.png",
		},
	},
	["walkstick"] = {
		label = "Bengala",
		weight = 1000,
		stack = true,
		close = true,
		description = "Bengala para todas as vovós por aí... HAHA",
		client = {
			image = "walkstick.png",
		},
	},
	["lighter"] = {
		label = "Isqueiro",
		weight = 0,
		stack = true,
		close = true,
		description = "Na véspera de Ano Novo, um bom fogo para ficar ao lado",
		client = {
			image = "lighter.png",
		},
	},
	["tablet"] = {
		label = "Tablet",
		weight = 2000,
		stack = true,
		close = true,
		description = "Tablet caro",
		client = {
			image = "tablet.png",
		},
	},
	["ghostcam"] = {
		label = "Camera Infravermelho",
		weight = 100,
		stack = true,
		close = true,
		consume = 0,
		description = "Uma câmera que vê além do que você enxerga.",
		server = {
			export = "randol_ghosthunting.ghostcam",
		},
	},

	['camera'] = {
		label = 'Câmera',
		weight = 1500,
		stack = false,
		close = true,
		client = {
			event = "y_camera:client:openCamera"
		},
		buttons = {
			{
				label = 'View photos',
				action = function(slot)
				   exports.qbx_camera:ShowScreen(slot)
				   client.closeInventory()
				end
			},
		},
		description = "Uma câmera profissional para tirar uma foto discreta da esposa do seu vizinho!"
	},

	['photo'] = {
		label = 'Foto',
		weight = 100,
		stack = true,
		close = true,
		buttons = {
			{
				label = 'Ver',
				action = function(slot)
					exports.qbx_camera:ShowPicture(slot)
					client.closeInventory()
				end
			},
			{
				label = 'Editar',
				action = function(slot)
					exports.qbx_camera:EditPicture(slot)
				end
			},
			{
				label = 'Obter link',
				action = function(slot)
					exports.qbx_camera:CopyURL(slot)
				end
			}
		},
		description = "Uma foto tirada com uma câmera."
	},

	["guide"] = {
		label = "Guia Iniciante",
		weight = 475,
		stack = true,
		close = true,
		description = "É novato em nosso servidor? Leia nosso guia!",
	},
	["rope"] = {
		label = "Corda",
		weight = 1,
		stack = true,
		close = true,
		description = nil,
	},
	["casinochips"] = {
		label = "Fichas de Cassino",
		weight = 0,
		stack = true,
		close = false,
		description = "Fichas para apostas em cassinos.",
	},
-- polícia
	["police_stormram"] = {
		label = "Aríete de Choque",
		weight = 18000,
		stack = true,
		close = true,
		description = "Uma ferramenta legal para arrombar portas",
		client = {
			image = "police_stormram.png",
		},
	},
	-- ND_Police
	["shield"] = {
		label = "Escudo Policial",
		weight = 8000,
		stack = false,
		consume = 0,
		client = {
			export = "ND_Police.useShield",
			add = function(total)
				if total > 0 then
					pcall(function()
						return exports["ND_Police"]:hasShield(true)
					end)
				end
			end,
			remove = function(total)
				if total < 1 then
					pcall(function()
						return exports["ND_Police"]:hasShield(false)
					end)
				end
			end,
		},
	},
	["spikestrip"] = {
		label = "Fita de Espinho",
		weight = 500,
		client = {
			export = "ND_Police.deploySpikestrip",
		},
	},
	["cuffs"] = {
		label = "Algemas",
		weight = 150,
		client = {
			export = "ND_Police.cuff",
		},
	},
	["zipties"] = {
		label = "Abraçadeiras de Nylon",
		weight = 10,
		client = {
			export = "ND_Police.ziptie",
		},
	},
	["tools"] = {
		label = "Ferramentas",
		description = "Podem ser usadas para ligar veículos.",
		weight = 800,
		consume = 1,
		stack = true,
		close = true,
		client = {
			export = "ND_Core.hotwire",
			event = "ND_Police:unziptie",
		},
	},
	["handcuffkey"] = {
		label = "Chave de Algema",
		weight = 10,
		client = {
			export = "ND_Police.uncuff",
		},
	},
	["casing"] = {
		label = "Estojo de Bala",
	},
	["projectile"] = {
		label = "Projétil",
	},
-- hospital
	-- mri_Qmedical
	["adrenaline"] = {
		label = "Adrenalina",
		weight = 100,
		stack = false,
		close = true,
		description = "Acorda até defunto."
	},
	["medicalbag"] = {
		label = "Bolsa de Primeiros Socorros",
		weight = 220,
		stack = true,
		description = "Um kit médico abrangente para tratar ferimentos e doenças.",
	},
	["bandage"] = {
		label = "Bandagem",
		weight = 100,
		consume = 1,
		stack = true,
		description = "Uma simples bandagem usada para cobrir e proteger ferimentos.",
		client = {
			export = "mri_Qmedical.bandage",
		},
	},
	["analgesic"] = {
		label = "Analgésico",
		weight = 10,
		stack = true,
		consume = 0,
		description = "Analgésico que mascara a dor temporariamente, não trata o ferimento.",
		client = {
			export = "mri_Qmedical.analgesic",
		},
	},
	["defibrillator"] = {
		label = "Desfibrilador",
		weight = 100,
		stack = true,
		description = "Usado para reviver pacientes.",
	},
	["tweezers"] = {
		label = "Pinças",
		weight = 100,
		stack = true,
		description = "Pinças de precisão para remover objetos estranhos, como balas, de ferimentos com segurança.",
	},
	["burncream"] = {
		label = "Creme para Queimaduras",
		weight = 100,
		stack = true,
		description = "Creme especializado para tratar e aliviar queimaduras leves e irritações na pele.",
	},
	["suturekit"] = {
		label = "Kit de Sutura",
		weight = 100,
		stack = true,
		description = "Um kit contendo ferramentas cirúrgicas e materiais para suturar e fechar ferimentos.",
	},
	["icepack"] = {
		label = "Pacote de Gelo",
		weight = 200,
		stack = true,
		description = "Um pacote de gelo usado para reduzir o inchaço e fornecer alívio da dor e inflamação.",
	},
	["stretcher"] = {
		label = "Maca",
		weight = 200,
		stack = true,
		description = "Um maca usada para mover pacientes que precisam de cuidados médicos.",
	},
	["emstablet"] = {
		label = "Tablet de EMS",
		weight = 200,
		stack = true,
		client = {
			export = "mri_Qmedical.openDistressCalls",
		},
	},
	["tourniquet"] = {
		label = "Torniquete",
		weight = 120,
		stack = true,
		consume = 0,
		description = "Garrote para estancar rapidamente sangramentos arteriais graves.",
		client = {
			export = "mri_Qmedical.tourniquet",
		},
	},
	["splint"] = {
		label = "Tala",
		weight = 150,
		stack = true,
		consume = 0,
		description = "Imobiliza um membro fraturado, reduzindo a dor e a limitação de movimento.",
		client = {
			export = "mri_Qmedical.splint",
		},
	},
	["plastercast"] = {
		label = "Gesso",
		weight = 200,
		stack = true,
		close = true,
		description = "Ataduras gessadas para imobilizar fraturas. Aplicado pelo médico; só sai serrado.",
	},
	["stethoscope"] = {
		label = "Estetoscópio",
		weight = 90,
		stack = false,
		consume = 0,
		description = "Instrumento para aferir os sinais vitais de um paciente.",
		client = {
			export = "mri_Qmedical.stethoscope",
		},
	},
	["salinebag"] = {
		label = "Soro Fisiológico",
		weight = 200,
		stack = true,
		consume = 0,
		description = "Bolsa de soro para hidratação e reposição volêmica; recupera vitalidade ao longo do tempo.",
		client = {
			export = "mri_Qmedical.saline",
		},
	},
	["bloodbag"] = {
		label = "Bolsa de Sangue",
		weight = 250,
		stack = true,
		consume = 0,
		description = "Bolsa de sangue para transfusão. Atenção à compatibilidade sanguínea do paciente.",
		client = {
			export = "mri_Qmedical.bloodbag",
		},
	},
-- caçador
	-- ars_hunting
	["animal_tracker"] = {
		label = "Rastreador de Animais",
		weight = 200,
		allowArmed = true,
		stack = false,
	},
	["campfire"] = {
		label = "Fogueira",
		weight = 200,
		allowArmed = true,
		stack = false,
	},
	["huntingbait"] = {
		label = "Isca de Caça",
		weight = 100,
		allowArmed = true,
	},
	["cooked_meat"] = {
		label = "Carne Cozida",
		weight = 200,
	},
	["raw_meat"] = {
		label = "Carne Crua",
		weight = 200,
	},
	["skin_deer_ruined"] = {
		label = "Pele de Veado Rasgada",
		weight = 200,
		stack = false,
	},
	["skin_deer_low"] = {
		label = "Pele de Veado Desgastada",
		weight = 200,
	},
	["skin_deer_medium"] = {
		label = "Pele de Veado Macia",
		weight = 200,
	},
	["skin_deer_good"] = {
		label = "Pele de Veado de Qualidade",
		weight = 200,
	},
	["skin_deer_perfect"] = {
		label = "Pele de Veado Impecável",
		weight = 200,
	},
	["deer_horn"] = {
		label = "Chifre de Veado",
		weight = 1000,
	},
-- mochilas
	["backpack1"] = {
		label = "Mochila 1",
		weight = 15,
		stack = false,
		close = true,
		description = "Uma mochila estilosa",
	},
	["backpack2"] = {
		label = "Mochila 2",
		weight = 15,
		stack = false,
		close = true,
		description = "Uma mochila estilosa",
	},
	["duffle1"] = {
		label = "Bolsa de Viagem",
		weight = 15,
		stack = false,
		close = true,
		description = "Uma bolsa de viagem estilosa",
	},
-- cdn-fuel
	["syphoningkit"] = {
		label = "Kit de Sifonagem",
		weight = 5000,
		stack = false,
		close = false,
		description = "Um kit feito para sifonar gasolina de veículos.",
		client = {
			image = "syphoningkit.png",
		},
	},
	["jerrycan"] = {
		label = "Lata Jerry",
		weight = 15000,
		stack = false,
		close = false,
		description = "Uma lata Jerry feita para armazenar gasolina.",
		client = {
			image = "jerrycan.png",
		},
	},
-- jim_mining
	["silverearring"] = {
		label = "Brincos de Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "silver_earring.png",
		},
	},
	["mininglaser"] = {
		label = "Laser de Mineração",
		weight = 900,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "mininglaser.png",
		},
	},
	["stone"] = {
		label = "Pedra",
		weight = 2000,
		stack = true,
		close = false,
		description = "Pedra woo",
		client = {
			image = "stone.png",
		},
	},
	["diamond_necklace"] = {
		label = "Colar de Diamante",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "diamond_necklace.png",
		},
	},
	["drillbit"] = {
		label = "Broca",
		weight = 10,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "drillbit.png",
		},
	},
	["silveringot"] = {
		label = "Lingote de Prata",
		weight = 1000,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "silveringot.png",
		},
	},
	["emerald_ring"] = {
		label = "Anel de Esmeralda",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "emerald_ring.png",
		},
	},
	["emerald_necklace_silver"] = {
		label = "Colar de Esmeralda Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "emerald_necklace_silver.png",
		},
	},
	["ruby_ring_silver"] = {
		label = "Anel de Rubi Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "ruby_ring_silver.png",
		},
	},
	["sapphire_necklace_silver"] = {
		label = "Colar de Safira Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "sapphire_necklace_silver.png",
		},
	},
	["emerald_earring_silver"] = {
		label = "Brincos de Esmeralda Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "emerald_earring_silver.png",
		},
	},
	["ruby"] = {
		label = "Rubi",
		weight = 100,
		stack = true,
		close = false,
		description = "Um Rubi que brilha",
		client = {
			image = "ruby.png",
		},
	},
	["ruby_ring"] = {
		label = "Anel de Rubi",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "ruby_ring.png",
		},
	},
	["miningdrill"] = {
		label = "Broca de Mineração",
		weight = 1000,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "miningdrill.png",
		},
	},
	["emerald"] = {
		label = "Esmeralda",
		weight = 100,
		stack = true,
		close = false,
		description = "Uma Esmeralda que brilha",
		client = {
			image = "emerald.png",
		},
	},
	["sapphire_earring_silver"] = {
		label = "Brincos de Safira Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "sapphire_earring_silver.png",
		},
	},
	["ruby_necklace_silver"] = {
		label = "Colar de Rubi Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "ruby_necklace_silver.png",
		},
	},
	["uncut_sapphire"] = {
		label = "Safira Bruta",
		weight = 100,
		stack = true,
		close = false,
		description = "Uma Safira bruta",
		client = {
			image = "uncut_sapphire.png",
		},
	},
	["can"] = {
		label = "Lata Vazia",
		weight = 10,
		stack = true,
		close = false,
		description = "Uma lata vazia, boa para reciclagem",
		client = {
			image = "can.png",
		},
	},
	["ruby_earring_silver"] = {
		label = "Brincos de Rubi Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "ruby_earring_silver.png",
		},
	},
	["uncut_ruby"] = {
		label = "Rubi Bruto",
		weight = 100,
		stack = true,
		close = false,
		description = "Um Rubi bruto",
		client = {
			image = "uncut_ruby.png",
		},
	},
	["ruby_earring"] = {
		label = "Brincos de Rubi",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "ruby_earring.png",
		},
	},
	["goldpan"] = {
		label = "Bandeja de Garimpagem de Ouro",
		weight = 10,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "goldpan.png",
		},
	},
	["emerald_ring_silver"] = {
		label = "Anel de Esmeralda Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "emerald_ring_silver.png",
		},
	},
	["ruby_necklace"] = {
		label = "Colar de Rubi",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "ruby_necklace.png",
		},
	},
	["diamond_earring_silver"] = {
		label = "Brincos de Diamante Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "diamond_earring_silver.png",
		},
	},
	["diamond_necklace_silver"] = {
		label = "Colar de Diamante Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "diamond_necklace_silver.png",
		},
	},
	["emerald_necklace"] = {
		label = "Colar de Esmeralda",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "emerald_necklace.png",
		},
	},
	["ironore"] = {
		label = "Minério de Ferro",
		weight = 1000,
		stack = true,
		close = false,
		description = "Ferro, um minério base.",
		client = {
			image = "ironore.png",
		},
	},
	["sapphire_earring"] = {
		label = "Brincos de Safira",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "sapphire_earring.png",
		},
	},
	["pickaxe"] = {
		label = "Picareta",
		weight = 1000,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "pickaxe.png",
		},
	},
	["diamond_earring"] = {
		label = "Brincos de Diamante",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "diamond_earring.png",
		},
	},
	["goldingot"] = {
		label = "Lingote de Ouro",
		weight = 1000,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "goldingot.png",
		},
	},
	["goldearring"] = {
		label = "Brincos de Ouro",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "gold_earring.png",
		},
	},
	["emerald_earring"] = {
		label = "Brincos de Esmeralda",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "emerald_earring.png",
		},
	},
	["carbon"] = {
		label = "Carbono",
		weight = 1000,
		stack = true,
		close = false,
		description = "Carbono, um minério base.",
		client = {
			image = "carbon.png",
		},
	},
	["sapphire_necklace"] = {
		label = "Colar de Safira",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "sapphire_necklace.png",
		},
	},
	["bottle"] = {
		label = "Garrafa Vazia",
		weight = 10,
		stack = true,
		close = false,
		description = "Uma garrafa de vidro",
		client = {
			image = "bottle.png",
		},
	},
	["uncut_diamond"] = {
		label = "Diamante Bruto",
		weight = 100,
		stack = true,
		close = false,
		description = "Um diamante bruto",
		client = {
			image = "uncut_diamond.png",
		},
	},
	["diamond"] = {
		label = "Diamante",
		weight = 1000,
		stack = true,
		close = true,
		description = "Um diamante parece o jackpot para mim!",
		client = {
			image = "diamond.png",
		},
	},
	["goldore"] = {
		label = "Minério de Ouro",
		weight = 1000,
		stack = true,
		close = false,
		description = "Minério de Ouro",
		client = {
			image = "goldore.png",
		},
	},
	["silver_ring"] = {
		label = "Anel de Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "silver_ring.png",
		},
	},
	["sapphire_ring_silver"] = {
		label = "Anel de Safira Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "sapphire_ring_silver.png",
		},
	},
	["sapphire_ring"] = {
		label = "Anel de Safira",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "sapphire_ring.png",
		},
	},
	["gold_ring"] = {
		label = "Anel de Ouro",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "gold_ring.png",
		},
	},
	["silverore"] = {
		label = "Minério de Prata",
		weight = 1000,
		stack = true,
		close = false,
		description = "Minério de Prata",
		client = {
			image = "silverore.png",
		},
	},
	["uncut_emerald"] = {
		label = "Esmeralda Bruta",
		weight = 100,
		stack = true,
		close = false,
		description = "Uma esmeralda bruta",
		client = {
			image = "uncut_emerald.png",
		},
	},
	["silverchain"] = {
		label = "Corrente de Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "silverchain.png",
		},
	},
	["copperore"] = {
		label = "Minério de Cobre",
		weight = 1000,
		stack = true,
		close = false,
		description = "Cobre, um minério base.",
		client = {
			image = "copperore.png",
		},
	},
	["sapphire"] = {
		label = "Safira",
		weight = 100,
		stack = true,
		close = false,
		description = "Uma safira que brilha",
		client = {
			image = "sapphire.png",
		},
	},
	["diamond_ring_silver"] = {
		label = "Anel de Diamante Prata",
		weight = 200,
		stack = true,
		close = false,
		description = "",
		client = {
			image = "diamond_ring_silver.png",
		},
	},
-- chaves de veículos
	-- mri_Qcarkeys
	["vehiclekey"] = {
		label = "Chave de Veículo",
		description = "Esta é uma chave do carro, cuide bem, se você a perder, provavelmente não poderá usar seu carro",
		weight = 10,
		stack = false,
		buttons = {
			{
				label = 'Juntar chaves',
				action = function()
					client.closeInventory()
					exports.mri_Qcarkeys:StackKeys()
				end
			},
		},
	},
	["keyring"] = {
		label = "Molho de Chaves",
		description = "Um molho com as suas chaves de veículo",
		weight = 10,
		stack = false,
		client = {
			image = "keys.png",
		},
		buttons = {
			{
				label = 'Juntar chaves soltas',
				action = function(slot)
					client.closeInventory()
					exports.mri_Qcarkeys:StackKeys(slot)
				end
			},
		},
	},
-- pescador
	-- lunar_fishing
	["basic_rod"] = { label = "Vara de pesca", stack = false, weight = 250 },
	["graphite_rod"] = { label = "Vara de grafite", stack = false, weight = 350 },
	["titanium_rod"] = { label = "Vara de titânio", stack = false, weight = 450 },
	["worms"] = { label = "Minhocas", weight = 10 },
	["artificial_bait"] = { label = "Isca artificial", weight = 30 },
	["anchovy"] = { label = "Anchova", weight = 20 },
	["grouper"] = { label = "Garoupa", weight = 3500 },
	["haddock"] = { label = "Haddock", weight = 500 },
	["mahi_mahi"] = { label = "Dourado", weight = 3500 },
	["piranha"] = { label = "Pirarucu", weight = 1500 },
	["red_snapper"] = { label = "Pargo-vermelho", weight = 2500 },
	["salmon"] = { label = "Salmão", weight = 1000 },
	["shark"] = { label = "Tubarão", weight = 7500 },
	["trout"] = { label = "Truta", weight = 750 },
	["tuna"] = { label = "Atum", weight = 10000 },
-- mecânica
	["harness"] = {
		label = "Cinto de Corrida",
		weight = 1000,
		stack = false,
		close = true,
		description = "Cinto de corrida para que você permaneça no carro independentemente.",
		client = {
			image = "harness.png",
		},
	},
	["cleaningkit"] = {
		label = "Kit de Limpeza",
		weight = 250,
		stack = true,
		close = true,
		description = "Um pano de microfibra com um pouco de sabão fará o seu carro brilhar novamente!",
		client = {
			image = "cleaningkit.png",
		},
	},
	["repairkit"] = {
		label = "Kit de Reparo",
		weight = 2500,
		stack = true,
		close = true,
		description = "Uma caixa de ferramentas com coisas para reparar seu veículo",
		client = {
			image = "repairkit.png",
		},
	},
	["advancedrepairkit"] = {
		label = "Kit de Reparo Avançado",
		weight = 4000,
		stack = true,
		close = true,
		description = "Uma caixa de ferramentas com coisas para reparar seu veículo",
		client = {
			image = "advancedkit.png",
		},
	},
	["nitrous"] = {
		label = "NOS",
		weight = 1000,
		stack = true,
		close = true,
		description = "Acelere, pedal do acelerador! :D",
		client = {
			image = "nitrous.png",
		},
	},
	["tow_rope"] = {
		label = "Corda de Reboque",
		weight = 9000,
		stack = true,
		close = true,
		description = "Pra carregar o coitado encalhado...",
		consume = 0,
		server = {
			export = "mri_Qtowing.useRope",
		},
	},
	["racing_gps"] = {
		label = "GPS de Corrida",
		weight = 500,
		stack = false,
		close = true,
		description = "Vrum vrum.",
		client = {
			image = "racing_gps.png",
		},
	},
	["driftchip"] = {
		label = "Drift Chip",
		weight = 300,
		degade = 21000,
		stack = true,
		close = true,
		allowArmed = true,
		description = "Use isso para ajustar a ECU para ativar ou desativar o modo de drift",
	},
	["driftchipbox"] = {
		label = "Drift Chip Box",
		weight = 350,
		stack = true,
		close = true,
		allowArmed = true,
		description = "Contém um chip de drift",
	},
-- fazenda
	-- kloud-farmjob
	["trowel"] = {
		label = "Espátula",
		weight = 500,
		decay = true,
		stack = false,
		close = false,
		description = "Diggy Diggy Diggy?",
	},
	["shovel"] = {
		label = "Pá",
		weight = 1000,
		decay = true,
		stack = false,
		close = false,
		description = "Diggy Diggy Diggy?",
	},
	["dirty_potato"] = {
		label = "Batata suja",
		weight = 250,
		degrade = 7160,
		decay = true,
		stack = true,
		close = false,
		description = "Potato potato but dirty dirty?",
	},
	["potato"] = {
		label = "Batata",
		weight = 250,
		degrade = 7160,
		decay = true,
		stack = true,
		close = false,
		description = "Potato potato?",
	},
	["dirty_cabbage"] = {
		label = "Repolho sujo",
		weight = 250,
		degrade = 7160,
		decay = true,
		stack = true,
		close = false,
		description = "Cabby cabby but dirty dirty?",
	},
	["cabbage"] = {
		label = "Repolho",
		weight = 250,
		degrade = 7160,
		decay = true,
		stack = true,
		close = false,
		description = "Cabby cabby?",
	},
	["dirty_tomato"] = {
		label = "Tomate sujo",
		weight = 250,
		degrade = 7160,
		decay = true,
		stack = true,
		close = false,
		description = "To-ma-to but dirty",
	},
	["tomato"] = {
		label = "Tomate",
		weight = 250,
		degrade = 7160,
		decay = true,
		stack = true,
		close = false,
		description = "To-ma-to",
	},
	["dirty_orange"] = {
		label = "Laranja suja",
		weight = 250,
		degrade = 7160,
		decay = true,
		stack = true,
		close = false,
		description = "It talks!!!!",
	},
	["orange"] = {
		label = "Laranja",
		weight = 250,
		degrade = 7160,
		decay = true,
		stack = true,
		close = false,
		description = "It talks!!!!",
	},
	["dirty_coffee_beans"] = {
		label = "Grãos de café sujos",
		weight = 250,
		degrade = 7160,
		decay = true,
		stack = true,
		close = false,
		description = "Ohh wakey wakey but dirty",
	},
	["coffee_beans"] = {
		label = "Grãos de café",
		weight = 250,
		degrade = 7160,
		decay = true,
		stack = true,
		close = false,
		description = "Ohh wakey wakey but dirty",
	},
-- petshop
	["keepcompanionmtlion"] = {
		label = "Leão",
		weight = 5000,
		stack = false,
		close = true,
		description = "Lion is your royal companion!",
	},
	["keepcompanionmtlion2"] = {
		label = "Pantera",
		weight = 5000,
		stack = false,
		close = true,
		description = "Panter is your royal companion!",
	},
	["keepcompanioncoyote"] = {
		label = "Coiote",
		weight = 5000,
		stack = false,
		close = true,
		description = "Coyote is your royal companion!",
	},
	["keepcompanionhusky"] = {
		label = "Husky",
		weight = 5000,
		stack = false,
		close = true,
		description = "Um cachorro que dizem ser mais inteligente que você.",
	},
	["keepcompanionpoodle"] = {
		label = "Poodle",
		weight = 5000,
		stack = false,
		close = true,
		description = "O corte de cabelo desse doguinho é mais caro que o seu carro.",
	},
	["keepcompanionrottweiler"] = {
		label = "Rottweiler",
		weight = 5000,
		stack = false,
		close = true,
		description = "O melhor amigo de um açougueiro.",
	},
	["keepcompanionwesty"] = {
		label = "Westie",
		weight = 5000,
		stack = false,
		close = true,
		description = "Uma ótima raça para caçar ratos e usar suéteres fofos.",
	},
	["keepcompanioncat"] = {
		label = "Gato",
		weight = 5000,
		stack = false,
		close = true,
		description = "Um gato ou uma gata? Muito difícil saber.",
	},
	["keepcompanionpug"] = {
		label = "Pug",
		weight = 5000,
		stack = false,
		close = true,
		description = "O ronco dele assombra você durante o sono.",
	},
	["keepcompanionretriever"] = {
		label = "Retriever",
		weight = 5000,
		stack = false,
		close = true,
		description = "Cachorro favorito da América.",
	},
	["keepcompanionshepherd"] = {
		label = "Border Collie",
		weight = 5000,
		stack = false,
		close = true,
		description = "Útil para ouvir seu bando de ovelhas.",
	},
	["keepcompanionrabbit"] = {
		label = "Coelho",
		weight = 5000,
		stack = false,
		close = true,
		description = "Parece ser fofinho mas é só um rato grande.",
	},
	["keepcompanionhen"] = {
		label = "Galinha",
		weight = 5000,
		stack = false,
		close = true,
		description = "Um melhor amigo e almoço. Dois por um!",
	},
	["keepcompanionrat"] = {
		label = "Rato",
		weight = 5000,
		stack = false,
		close = true,
		description = "Pode ser o maior cozinheiro do mundo ou um rato mesmo.",
	},
	["keepcompanionk9unit"] = {
		label = "K9 Unidade Malinois",
		weight = 5000,
		stack = false,
		close = true,
		description = "O melhor amigo viciado de um policial.",
	},
	--- pet items ----
	["petfood"] = {
		label = "Ração de Pet",
		weight = 500,
		stack = true,
		close = true,
		description = "Comidinha para seu pet.",
	},
	["collarpet"] = {
		label = "Coleira de Pet",
		weight = 500,
		stack = false,
		close = true,
		description = "Renomeie seu animal de estimação.",
	},
	["firstaidforpet"] = {
		label = "Kit Veterinário",
		weight = 500,
		stack = true,
		close = true,
		description = "Traga seu animal de estimação de volta dos mortos de novo e de novo.",
	},
	["petnametag"] = {
		label = "Tag de Pet",
		weight = 500,
		stack = true,
		close = true,
		description = "Renomeie seu animal de estimação.",
	},
	["petwaterbottleportable"] = {
		label = "Água para Pet",
		weight = 500,
		stack = false,
		close = true,
		description = "Água para seu animal de estimação. Pare de tentar beber isso.",
	},
	["petgroomingkit"] = {
		label = "Kit de preparação para animais de estimação",
		weight = 500,
		stack = false,
		close = true,
		description = "Agora seu animal de estimação pode passar uma verificação de ondas.",
	},
-- placeable items
	["prop_cone_small"] = {
		label = "Traffic cone",
		description = "Small traffic cone",
		prop = { `prop_mp_cone_02`, `prop_mp_cone_03`, `prop_roadcone02a`, `prop_roadcone02b`, `prop_roadcone02c` },
		vehiclesWillAvoid = true,
		weight = 1800,
		stack = true,
		close = true,
		allowArmed = false,
		client = {
			anim = { dict = "anim@mp_snowball", clip = "pickup_snowball" },
			disable = { move = true, car = true, combat = true },
			usetime = 900,
			cancel = true,
		},
		server = {
			export = "mri_Qbox.itemPlace",
		},
	},
	["prop_cone_large"] = {
		label = "Traffic cone",
		description = "Large traffic cone",
		prop = { `prop_mp_cone_01`, `prop_roadcone01a`, `prop_roadcone01b`, `prop_roadcone01c` },
		vehiclesWillAvoid = true,
		weight = 1800,
		stack = true,
		close = true,
		allowArmed = false,
		client = {
			anim = { dict = "anim@mp_snowball", clip = "pickup_snowball" },
			disable = { move = true, car = true, combat = true },
			usetime = 900,
			cancel = true,
		},
		server = {
			export = "mri_Qbox.itemPlace",
		},
	},
	["prop_police_barrier"] = {
		label = "Police barrier",
		description = "DO NOT CROSS POLICE DEPT.",
		prop = `prop_barrier_work05`,
		vehiclesWillAvoid = true,
		weight = 1800,
		stack = true,
		close = true,
		allowArmed = false,
		client = {
			anim = { dict = "anim@mp_snowball", clip = "pickup_snowball" },
			disable = { move = true, car = true, combat = true },
			usetime = 900,
			cancel = true,
		},
		server = {
			export = "mri_Qbox.itemPlace",
		},
	},
	["prop_barrier_small"] = {
		label = "Work barrier",
		description = "Small work barrier",
		prop = `prop_barrier_work01a`,
		vehiclesWillAvoid = true,
		weight = 1800,
		stack = true,
		close = true,
		allowArmed = false,
		client = {
			anim = { dict = "anim@mp_snowball", clip = "pickup_snowball" },
			disable = { move = true, car = true, combat = true },
			usetime = 900,
			cancel = true,
		},
		server = {
			export = "mri_Qbox.itemPlace",
		},
	},
	["prop_barrier_medium"] = {
		label = "Work barrier",
		description = "Medium work barrier",
		prop = `prop_barrier_work06a`,
		vehiclesWillAvoid = true,
		weight = 1800,
		stack = true,
		close = true,
		allowArmed = false,
		client = {
			anim = { dict = "anim@mp_snowball", clip = "pickup_snowball" },
			disable = { move = true, car = true, combat = true },
			usetime = 900,
			cancel = true,
		},
		server = {
			export = "mri_Qbox.itemPlace",
		},
	},
	["prop_barrier_large"] = {
		label = "Work barrier",
		description = "Large work barrier",
		prop = `prop_mp_barrier_02b`,
		vehiclesWillAvoid = true,
		weight = 1800,
		stack = true,
		close = true,
		allowArmed = false,
		client = {
			anim = { dict = "anim@mp_snowball", clip = "pickup_snowball" },
			disable = { move = true, car = true, combat = true },
			usetime = 900,
			cancel = true,
		},
		server = {
			export = "mri_Qbox.itemPlace",
		},
	},
	["prop_worklight_large"] = {
		label = "Worklight",
		description = "Large worklight",
		prop = `prop_worklight_03b`,
		vehiclesWillAvoid = true,
		weight = 1800,
		stack = true,
		close = true,
		allowArmed = false,
		client = {
			anim = { dict = "anim@mp_snowball", clip = "pickup_snowball" },
			disable = { move = true, car = true, combat = true },
			usetime = 900,
			cancel = true,
		},
		server = {
			export = "mri_Qbox.itemPlace",
		},
	},
	["prop_worklight_small"] = {
		label = "Worklight",
		description = "Small worklight",
		prop = `prop_worklight_02a`,
		vehiclesWillAvoid = true,
		weight = 1800,
		stack = true,
		close = true,
		allowArmed = false,
		client = {
			anim = { dict = "anim@mp_snowball", clip = "pickup_snowball" },
			disable = { move = true, car = true, combat = true },
			usetime = 900,
			cancel = true,
		},
		server = {
			export = "mri_Qbox.itemPlace",
		},
	},

    ["recyclablematerial"] = {
        label = "Caixa de Reciclagem",
        weight = 100,
        stack = true,
        close = false,
        description = "Uma caixa de Materiais Recicláveis",
        client = {
            image = "recyclablematerial.png",
        }
    },
}
