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
			"scale": 3
		},
		"init_val": 1,
		"scale_val": 1.6
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
			"init": 100,
			"scale": 1.8
		},
		"init_val": 1,
		"scale_val": 1.6
	}
}
