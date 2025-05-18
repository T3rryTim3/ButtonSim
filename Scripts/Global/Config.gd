extends Node

const UPDATE_RATE:float = 0.5

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
			"cash": 1,
			"multiplier": 1
		},
		"cost": {
			"currency": "multiplier",
			"init": 500,
			"scale": 2.2,
			"exp_growth": .05
		},
		"init_val": 1,
		"scale_val": 1.9,
		"exp_growth": .025
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
			"multiplier": 0.2,
			"rebirths": 1
		},
		"cost": {
			"currency": "rebirths",
			"init": 500,
			"scale": 5.5,
			"exp_growth": .025
		},
		"init_val": 1,
		"scale_val": 1.5,
		"exp_growth": .025
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
			"exp_growth": .02
		},
		"init_val": 1,
		"scale_val": 3,
		"exp_growth": .025
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
			"exp_growth": .02
		},
		"init_val": 1,
		"scale_val": 3,
		"exp_growth": .025
	}
}

var upgrades = {
	"hover_buy": {
		"name": "Hover to Buy",
		"reset_tags": ["prestige"],
		"cost_currency": "prestige_points",
		"get_max": func(): return len(RESET_LAYERS.keys()),
		"get_desc": func(next:int): return "Unlock hover-to-buy for " + str(RESET_LAYERS.keys()[next]),
		"get_cost": func(next:int): return pow(10,(next+1))
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
