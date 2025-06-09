extends Node

const UPDATE_RATE:float = 0.5

var MIN_PRESTIGE_SCORE:float = 10

var BASE_BUY_SPEED:float = 0.1

var PP_BONUS_BASE:float = 1
var PP_BONUS_DIV_SCALE:float = 10

## Delay between tokens on each button
## They arent technically constants because they are arrays.
var TOKEN_DELAY_INTERVAL:Array[float] = [60,90]
var TOKEN_EXPIRE_INTERVAL:Array[float] = [5,10] # TODO
var TOKEN_GAIN_INTERVAL:Array[float] = [1,3] # TODO

const RESET_LAYERS = {
	"multiplier": {
		"color": Color(1,.4,.4),
		"reset": [],
		"multiplies": {
			"cash": 1
		},
		"cost": {
			"currency": "cash",
			"init": 10,
			"scale": 3,
			"exp_growth": 0.05
		},
		"init_val": 1,
		"scale_val": 1.6,
		"exp_growth": .0
	},

	"rebirths": {
		"color": Color(0.4,0.4,1),
		"reset": [
			"cash",
			"multiplier"
		],
		"multiplies": {
			"cash": 0.25,
			"multiplier": 1
		},
		"cost": {
			"currency": "multiplier",
			"init": 500,
			"scale": 2.2,
			"exp_growth": .1
		},
		"init_val": 1,
		"scale_val": 1.5,
		"exp_growth": .0
	},

	"super": {
		"color": Color(0.5,1,0.5),
		"reset": [
			"cash",
			"multiplier",
			"rebirths"
		],
		"multiplies": {
			"cash": 0.05,
			"multiplier": 0.05,
			"rebirths": 1
		},
		"cost": {
			"currency": "rebirths",
			"init": 1000,
			"scale": 5.5,
			"exp_growth": .1
		},
		"init_val": 1,
		"scale_val": 1.5,
		"exp_growth": .0
	},

	"ultra": {
		"color": Color(0.2,.4,.8),
		"reset": [
			"cash",
			"multiplier",
			"rebirths",
			"super"
		],
		"multiplies": {
			"cash": 0.1,
			"multiplier": 0.1,
			"rebirths": 0.2,
			"super": 1
		},
		"cost": {
			"currency": "super",
			"init": 2000,
			"scale": 2.5,
			"exp_growth": 0.15
		},
		"init_val": 1,
		"scale_val": 1.4,
		"exp_growth": .0
	},

	"mega": {
		"color": Color(1,.5,1),
		"reset": [
			"cash",
			"multiplier",
			"rebirths",
			"ultra",
			"super"
		],
		"multiplies": {
			"cash": 0.1,
			"multiplier": 0.2,
			"rebirths": 0.2,
			"ultra": 0.2,
			"super": 1
		},
		"cost": {
			"currency": "ultra",
			"init": 30000,
			"scale": 3,
			"exp_growth": 0.25
		},
		"init_val": 1,
		"scale_val": 1.3,
		"exp_growth": .0
	},
	
	"hyper": {
		"color": Color(0,1,1),
		"reset": [
			"cash",
			"multiplier",
			"rebirths",
			"ultra",
			"super",
			"mega"
		],
		"multiplies": {
			"multiplier": .2,
			"rebirths": .2,
			"ultra": .2,
			"super": 1
		},
		"cost": {
			"currency": "mega",
			"init": 400000,
			"scale": 3.5,
			"exp_growth": .35
		},
		"init_val": 1,
		"scale_val": 3,
		"exp_growth": .0
	}
}

var upgrades = {
	#region Prestige Points
	"PP Buttons": {
		"name": "Buttons",
		"tags": ["prestige"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_player_currency": func(): return Game.get_reset("prestige").points,
		"spend_currency": func(amt:Variant): Game.spend_reset_points("prestige", amt),
		"get_max": func(): return 20,
		"get_desc": func(next:int): return "Button count is increased by " + str(5*(next+1)),
		"get_cost": func(next:int): return B.new(4).multiply(B.new(8).power(next))
	},
	"PP Layers": {
		"name": "Rebirths",
		"tags": ["prestige"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_player_currency": func(): return Game.get_reset("prestige").points,
		"spend_currency": func(amt:Variant): Game.spend_reset_points("prestige", amt),
		"get_max": func(): return len(RESET_LAYERS.keys()) - 3,
		"get_desc": func(next:int): return "Unlock " + str(RESET_LAYERS.keys()[next+3]),
		"get_cost": func(next:int): return B.new(60).multiply(B.new(40).power(next))
	},
	"PP Auto Buy": {
		"name": "Auto Buy",
		"tags": ["prestige"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_player_currency": func(): return Game.get_reset("prestige").points,
		"spend_currency": func(amt:Variant): Game.spend_reset_points("prestige", amt),
		"get_max": func(): return len(RESET_LAYERS.keys()),
		"get_desc": func(next:int): return "Unlock auto-buy for " + str(RESET_LAYERS.keys()[next]),
		"get_cost": func(next:int): return B.new(100).multiply(B.new(1000).power(next))
	},
	"PP Free Cost": {
		"name": "Free cost",
		"tags": ["prestige"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_player_currency": func(): return Game.get_reset("prestige").points,
		"spend_currency": func(amt:Variant): Game.spend_reset_points("prestige", amt),
		"get_max": func(): return len(RESET_LAYERS.keys()),
		"get_desc": func(next:int): return str(RESET_LAYERS.keys()[next]).capitalize() + " Purchases do not spend anything.",
		"get_cost": func(next:int): return B.new(10).multiply(B.new(1000).power(next))
	},
	"PP Boost": {
		"name": "PP Boost",
		"tags": ["prestige"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_player_currency": func(): return Game.get_reset("prestige").points,
		"spend_currency": func(amt:Variant): Game.spend_reset_points("prestige", amt),
		"get_max": func(): return len(RESET_LAYERS.keys()) + 1,
		"get_desc": func(next:int): return "Your PP now multiplies " + str((["cash"] + RESET_LAYERS.keys() + ["All purchased."])[next]),
		"get_cost": func(next:int): return B.new(40).multiply(B.new(1200).power(next))
	},
	"PP Buy speed": {
		"name": "Buy speed",
		"tags": ["prestige"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_player_currency": func(): return Game.get_reset("prestige").points,
		"spend_currency": func(amt:Variant): Game.spend_reset_points("prestige", amt),
		"get_max": func(): return 20,
		"get_desc": func(next:int): return "Your buy speed is 20% faster.",
		"get_cost": func(next:int): return B.new(25).multiply(B.new(15).power(next))
	},
	"PP PP Multi": {
		"name": "PP Multi",
		"tags": ["prestige"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_player_currency": func(): return Game.get_reset("prestige").points,
		"spend_currency": func(amt:Variant): Game.spend_reset_points("prestige", amt),
		"get_max": func(): return 100,
		"get_desc": func(next:int): return "Your PP is multiplied by " + str(Game.get_upgrade_count("PP PP Multi") + 2),
		"get_cost": func(next:int): return B.new(2).multiply(B.new(3).power(next))
	},
	#endregion

	#region Tokens
	"Token Cash multi": {
		"name": "Cash multiplier",
		"tags": ["token"],
		"currency": "tokens",
		"currency_name": "Tokens",
		"get_effect": func(val:int): return val+1,
		"get_player_currency": func(): return Game.get_stat("tokens"),
		"spend_currency": func(amt:Variant): Game.minus_stat("tokens", amt),
		"get_max": func(): return 1000,
		"get_desc": func(next:int): return "x" + str(Game.get_upgrade_effect("Token Cash multi", next+1)) + " Cash",
		"get_cost": func(next:int): return B.new(5)
	},
	"Token Buy speed": {
		"name": "Buy Speed",
		"tags": ["token"],
		"currency": "tokens",
		"currency_name": "Tokens",
		"get_effect": func(val:int): return pow(0.95, val),
		"get_player_currency": func(): return Game.get_stat("tokens"),
		"spend_currency": func(amt:Variant): Game.minus_stat("tokens", amt),
		"get_max": func(): return 10,
		"get_desc": func(next:int): return "Buy speed increased by " + str(round((1-Game.get_upgrade_effect("Token Buy speed", next+1))*100)) + "%",
		"get_cost": func(next:int): return B.new(3).multiply(next+1)
	},
	"Token PP Multi": {
		"name": "PP Multiplier",
		"tags": ["token"],
		"currency": "prestige_points",
		"currency_name": "Tokens",
		"get_effect": func(val:int): return 1+(val)/2.0,
		"get_player_currency": func(): return Game.get_stat("tokens"),
		"spend_currency": func(amt:Variant): Game.minus_stat("tokens", amt),
		"get_max": func(): return 10,
		"get_desc": func(next:int): return str(Game.get_upgrade_effect("Token PP Multi", next+1)) + "x PP Gain",
		"get_cost": func(next:int): return B.new(3).multiply(next+1)
	},
	#endregion

	#region Crates
	"Crate Buy Stat Crate": {
		"name": "Stat Crate",
		"tags": ["crate"],
		"currency": "PP",
		"currency_name": "PP",
		"allow_refund": false,
		"get_effect": func(val:int): return 1,
		"get_player_currency": func(): return Game.get_reset("prestige").points,
		"spend_currency": func(amt:Variant): Game.spend_reset_points("prestige", amt),
		"get_max": func(): return -1, # Unlimited
		"get_desc": func(next:int): return "Buy 1 stat crate. Cost caps at 1000.",
		"get_cost": func(next:int): return B.new(min(100*(next+1), 1000)),
		"on_buy": func(next:int): Game.increase_crate_count("basic", 1)
	},

	"Crate Buy Token Crate": {
		"name": "Token Crate",
		"tags": ["crate"],
		"currency": "tokens",
		"currency_name": "Tokens",
		"allow_refund": false,
		"get_effect": func(val:int): return 1,
		"get_player_currency": func(): return Game.get_stat("tokens"),
		"spend_currency": func(amt:Variant): Game.minus_stat("tokens", amt),
		"get_max": func(): return -1, # Unlimited
		"get_desc": func(next:int): return "Buy 1 token crate.",
		"get_cost": func(next:int): return B.new(20),
		"on_buy": func(next:int): Game.increase_crate_count("token", 1)
	}
	#endregion
}

var crates = {
	"basic": {
		"id": "basic", # Must be the same as the key
		"health": 10,
		"name": "Stat crate",
		"desc": "A basic crate. Affects various early multipliers.",
		"cost": {
			"currency_name": "PP",
			"get_player_currency": func(): return Game.get_reset("prestige").points,
			"spend_currency": func(amt:Variant): Game.spend_reset_points("prestige", amt),
			"get_cost": func(): return B.new(100)
		},
		"rewards": [
			{"name": "Common", "color":Color(1,1,1), "weight": 10.0,"multi": {"cash": 0.1}},
			{"name": "Uncommon", "color":Color(0.6,1,0.6), "weight": 5.0,"multi": {"multiplier": 0.1}},
			{"name": "Rare", "color":Color(0.6,0.6,1), "weight": 2.0,"multi": {"rebirths": 0.1}},
			{"name": "Epic", "color":Color(1,0.6,1), "weight": 1.0,"multi": {"super": 0.1}},
			{"name": "Legendary", "color":Color(1,1,0.6), "weight": 0.5,"multi": {"ultra": 0.1}},
			{"name": "Mythical", "color":Color(0.6,1,1), "weight": 0.25,"multi": {"cash": 0.5,"multiplier": 0.5,"rebirths": 0.5}},
			{"name": "Insane", "color":Color(0.6,0.3,0.6), "weight": 0.1,"multi": {"cash": 5, "multiplier": 5}},
		]
	},
	"token": {
		"id": "token", # Must be the same as the key
		"health": 15,
		"name": "Token crate",
		"desc": "Low bonuses, but affects a bunch of stats. Even PP!",
		"cost": {
			"currency_name": "Tokens",
			"get_player_currency": func(): return Game.get_reset("tokens").points,
			"spend_currency": func(amt:Variant): Game.spend_reset_points("tokens", amt),
			"get_cost": func(): return B.new(100)
		},
		"rewards": [
			{"name": "Dull", "color":Color(0.6,0.6,0.6), "weight": 10.0,"multi": {"cash": 0.1, "multiplier": 0.1, "rebirths": 0.1}},
			{"name": "Decent", "color":Color(0.6,0.6,0.8), "weight": 6.0,"multi": {"cash": 0.2, "multiplier": 0.2, "rebirths": 0.1, "super": 0.05}},
			{"name": "Shiny", "color":Color(0.7,0.7,0.9), "weight": 2.0,"multi": {"prestige_points": 0.2}},
			{
				"name": "Pristine", 
				"color":Color(0.6,0.6,0.8), 
				"weight": 0.8, 
				"multi": {
					"cash": 0.1, 
					"multiplier": 0.1, 
					"rebirths": 0.1, 
					"super": 0.1, 
					"ultra": 0.1, 
					"prestige_points": 0.1
				}
			},
			{
				"name": "Remarkable", 
				"color":Color(0.6,0.6,1), 
				"weight": 0.1, 
				"multi": {
					"cash": 0.1, 
					"multiplier": 0.1, 
					"rebirths": 0.1, 
					"super": 0.1, 
					"ultra": 0.1, 
					"mega": 0.1, 
					"hyper": 0.1, 
					"prestige_points": 0.1
				}
			},
		]
	}
}

## Reorganized reset data for the multipliers. Done to save performance.
var reset_stat_multis = {}

func _ready() -> void:

	## Load data in reset_stat_multis
	for k in RESET_LAYERS:
		for multi in RESET_LAYERS[k]["multiplies"]:
			if not multi in reset_stat_multis:
				reset_stat_multis[multi] = []
			reset_stat_multis[multi].append([k, RESET_LAYERS[k]["multiplies"][multi]])
