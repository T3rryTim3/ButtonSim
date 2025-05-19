extends Node

const UPDATE_RATE:float = 0.5

var MIN_PRESTIGE_SCORE:float = 5

var BASE_BUY_SPEED:float = 0.1

var PP_BONUS_BASE:float = 1
var PP_BONUS_DIV_SCALE:float = 10

const RESET_LAYERS = {
	"multiplier": {
		"color": Color(1,.3,.3),
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
		"exp_growth": .025
	},

	"rebirths": {
		"color": Color(0.3,0.3,1),
		"reset": [
			"cash",
			"multiplier"
		],
		"multiplies": {
			"cash": 0.5,
			"multiplier": 1
		},
		"cost": {
			"currency": "multiplier",
			"init": 500,
			"scale": 2.2,
			"exp_growth": .1
		},
		"init_val": 1,
		"scale_val": 1.9,
		"exp_growth": .1
	},

	"super": {
		"color": Color(0.3,1,0.3),
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
			"init": 500,
			"scale": 5.5,
			"exp_growth": .1
		},
		"init_val": 1,
		"scale_val": 1.5,
		"exp_growth": .05
	},

	"ultra": {
		"color": Color(0.3,1,1),
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
			"super": 1.5
		},
		"cost": {
			"currency": "super",
			"init": 2000,
			"scale": 2.5,
			"exp_growth": 0.15
		},
		"init_val": 1,
		"scale_val": 3,
		"exp_growth": .05
	},

	"mega": {
		"color": Color(1,0,1),
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
			"rebirths": 0.3,
			"ultra": 0.5,
			"super": 1
		},
		"cost": {
			"currency": "ultra",
			"init": 10000,
			"scale": 2.5,
			"exp_growth": 0.2
		},
		"init_val": 1,
		"scale_val": 3,
		"exp_growth": .05
	},
	
	"hyper": {
		"color": Color(1,0.8,0.2),
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
			"init": 20000,
			"scale": 2.5,
			"exp_growth": .3
		},
		"init_val": 1,
		"scale_val": 3,
		"exp_growth": .05
	}
}

var upgrades = {
	"PP Buttons": {
		"name": "Buttons",
		"tags": ["prestige"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_player_currency": func(): return Game.get_reset("prestige").points,
		"spend_currency": func(amt:Variant): Game.spend_reset_points("prestige", amt),
		"get_max": func(): return 20,
		"get_desc": func(next:int): return "Button count is now " + str(5*(next+1)),
		"get_cost": func(next:int): return B.new(2).multiply(B.new(2).power(next))
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
		"get_cost": func(next:int): return B.new(5).multiply(B.new(15).power(next))
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
		"get_cost": func(next:int): return B.new(1000).multiply(B.new(100).power(next))
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
		"get_cost": func(next:int): return B.new(10).multiply(B.new(100).power(next))
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
		"get_cost": func(next:int): return B.new(5).multiply(B.new(10).power(next))
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
		"get_cost": func(next:int): return B.new(2).multiply(B.new(2).power(next))
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
