extends Node

const UPDATE_RATE:float = 0.5

const RESET_LAYERS = {
	"multiplier": {
		"color": Color(1,0,0),
		"reset": [],
		"multiplies": {
			"cash": 1
		},
		"cost": {
			"currency": "cash",
			"init": 10,
			"scale": 3,
			"exp_growth": .2
		},
		"init_val": 1,
		"scale_val": 2.1
	},

	"rebirths": {
		"color": Color(0,0,1),
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
			"scale": 3.2,
			"exp_growth": .15
		},
		"init_val": 1,
		"scale_val": 1.6
	},

	"super rebirths": {
		"color": Color(0,1,0),
		"reset": [
			"cash",
			"multiplier",
			"rebirths"
		],
		"multiplies": {
			"cash": 0.05,
			"multiplier": 0.2,
			"rebirths": 1,
			"exp_growth": .1
		},
		"cost": {
			"currency": "rebirths",
			"init": 500,
			"scale": 5.5
		},
		"init_val": 1,
		"scale_val": 3
	}
}
