extends Node
## Config for most of the game's data.
##
## -- Overview --
## This does not do much by itself, but contains data for all of the upgrades, crates, etc.
## Not all data is here, but for large dictionaries of game data this is the best place to put it.
##
## The dictionaries are not constant because they contain lambdas within them, though they are
## not meant to be changed during the game, so do not do so.
##
## Do note that this requires Globals.game to be set to use most of the lambda values,
## so without a game present there will be an error; no checking is done.
##
## The data can get quite long, so please use regions where appropriate (See the "upgrades") variable.
##
## Do not add any functionality here for the game itself for organization. Only add data.

#region Constants
const UPDATE_RATE:float = 0.5

var MIN_PRESTIGE_SCORE:float = 10

var BASE_BUY_SPEED:float = 0.1

var PP_BONUS_BASE:float = 1
var PP_BONUS_DIV_SCALE:float = 10

## Delay between tokens on each button
## They arent technically constants because they are arrays.
var TOKEN_DELAY_INTERVAL:Array[float] = [60,90]
var TOKEN_EXPIRE_INTERVAL:Array[float] = [5,15]
var TOKEN_GAIN_INTERVAL:Array[int] = [1,3]
#endregion

#region Enums

# NOTE: Do no add enum data into savedata for the sake of allowing changes

## All of the game's unlocks.
## Add a comment describing what each unlocks, as well as a fitting name.
enum Unlocks {
	MASTERY # Unlocks the mastery tab
}

#endregion

# If updating, add a respective mastery entry
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
			"init": 6000,
			"scale": 2.5,
			"exp_growth": 0.2
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
			"exp_growth": 0.2
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
			"multiplier": .1,
			"rebirths": .1,
			"ultra": .1,
			"super": .2,
			"mega": 1
		},
		"cost": {
			"currency": "mega",
			"init": 400000,
			"scale": 3.5,
			"exp_growth": .25
		},
		"init_val": 1,
		"scale_val": 1.3,
		"exp_growth": .0
	}
}

var upgrades = {
	#region Prestige Points
	"PP Buttons": {
		"name": "Buttons",
		"tags": ["prestige"],
		"reset_tags": ["rank"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_max": func(): return 20,
		"get_desc": func(next:int): return "Button count is increased by " + str(5*(next+1)),
		"get_cost": func(next:int): return B.new(4).multiply(B.new(8).power(next))
	},
	"PP Layers": {
		"name": "Rebirths",
		"tags": ["prestige"],
		"reset_tags": ["rank"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_max": func(): return len(RESET_LAYERS.keys()) - 2,
		"get_desc": func(next:int): return "Unlock " + str(RESET_LAYERS.keys()[next+2]),
		"get_cost": func(next:int): return B.new(60).multiply(B.new(400).power(next))
	},
	"PP Auto Buy": {
		"name": "Auto Buy",
		"tags": ["prestige"],
		"reset_tags": ["rank"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_max": func(): return len(RESET_LAYERS.keys()),
		"get_desc": func(next:int): return "Unlock auto-buy for " + str(RESET_LAYERS.keys()[next]),
		"get_cost": func(next:int): return B.new(100).multiply(B.new(1000).power(next))
	},
	"PP Free Cost": {
		"name": "Free cost",
		"tags": ["prestige"],
		"reset_tags": ["rank"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_max": func(): return len(RESET_LAYERS.keys()),
		"get_desc": func(next:int): return str(RESET_LAYERS.keys()[next]).capitalize() + " Purchases do not spend anything.",
		"get_cost": func(next:int): return B.new(10).multiply(B.new(1000).power(next))
	},
	"PP Boost": {
		"name": "PP Boost",
		"tags": ["prestige"],
		"reset_tags": ["rank"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_max": func(): return len(RESET_LAYERS.keys()) + 1,
		"get_desc": func(next:int): return "Your PP now multiplies " + str((["cash"] + RESET_LAYERS.keys() + ["All purchased."])[next]),
		"get_cost": func(next:int): return B.new(40).multiply(B.new(1200).power(next)),
		"get_multi": func(val:int) -> Dictionary[String, B]: 
	# Ugly, but lambda doesnt support indentation that isn't.
	var total:Dictionary[String, B] = {}
	var pp = Globals.game.get_stat("prestige_points")
	for k in range(val):
		total[(["cash"]+RESET_LAYERS.keys())[k]] = B.new(1).multiply(pp).divide(pow(10, k)).plus(1)
	return total
	},
	"PP Buy speed": {
		"name": "Buy speed",
		"tags": ["prestige"],
		"reset_tags": ["rank"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_max": func(): return 20,
		"get_desc": func(_next:int): return "Your buy speed is 20% faster.",
		"get_cost": func(next:int): return B.new(25).multiply(B.new(15).power(next))
	},
	"PP PP Multi": {
		"name": "PP Multi",
		"tags": ["prestige"],
		"reset_tags": ["rank"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"get_max": func(): return 100,
		"get_desc": func(_next:int): return "Your PP is multiplied by " + str(Globals.game.get_upgrade_count("PP PP Multi") + 2),
		"get_cost": func(next:int): return B.new(2).multiply(B.new(3).power(next)),
		"get_multi": func(val:int) -> Dictionary[String, B]: return {"prestige_points": B.new(val+1)}
	},
	#endregion

	#region Tokens
	"Token Cash multi": {
		"name": "Cash multiplier",
		"tags": ["token"],
		"reset_tags": ["rank"],
		"currency": "tokens",
		"currency_name": "Tokens",
		"get_max": func(): return 1000,
		"get_desc": func(next:int): return "x" + str(next+1) + " Cash",
		"get_cost": func(_next:int): return B.new(5),
		"get_multi": func(val:int) -> Dictionary[String, B]: return {"cash": B.new(val+1)}
	},
	"Token Buy speed": {
		"name": "Buy Speed",
		"tags": ["token"],
		"reset_tags": ["rank"],
		"currency": "tokens",
		"currency_name": "Tokens",
		"get_effect": func(val:int): return pow(0.95, val),
		"get_max": func(): return 10,
		"get_desc": func(next:int): return "Buy speed increased by " + str(round((1-Globals.game.get_upgrade_effect("Token Buy speed", next+1))*100)) + "%",
		"get_cost": func(next:int): return B.new(3).multiply(next+1)
	},
	"Token PP Multi": {
		"name": "PP Multiplier",
		"tags": ["token"],
		"reset_tags": ["rank"],
		"currency": "tokens",
		"currency_name": "Tokens",
		"get_max": func(): return 10,
		"get_desc": func(next:int): return str(1+(next+1)/2.0) + "x PP Gain",
		"get_cost": func(next:int): return B.new(3).multiply(next+1),
		"get_multi": func(val:int) -> Dictionary[String, B]: return {"prestige_points": B.new(1+(val)/2.0)}
	},
	#endregion

	#region Crates
	"Crate Buy Stat Crate": {
		"name": "Stat Crate",
		"tags": ["crate"],
		"currency": "prestige_points",
		"currency_name": "PP",
		"allow_refund": false,
		"get_max": func(): return -1, # Unlimited
		"get_desc": func(_next:int): return "Buy 1 stat crate. Cost caps at 1000.",
		"get_cost": func(next:int): return B.new(min(100*(next+1), 1000000)),
		"on_buy": func(_next:int): Globals.game.increase_crate_count("basic", 1)
	},

	"Crate Buy Token Crate": {
		"name": "Token Crate",
		"tags": ["crate"],
		"currency": "tokens",
		"currency_name": "Tokens",
		"allow_refund": false,
		"get_max": func(): return -1, # Unlimited
		"get_desc": func(_next:int): return "Buy 1 token crate.",
		"get_cost": func(_next:int): return B.new(20),
		"on_buy": func(_next:int): Globals.game.increase_crate_count("token", 1)
	},
	#endregion
	
	#region Mastery
	"Mastery Gain": {
		"name": "Mastery Increase",
		"tags": ["mastery"],
		"currency": "prestige_points",
		"currency_name": "Prestige Points",
		"allow_refund": false,
		"get_max": func(): return 8,
		"get_desc": func(next:int): return "Mastery gain multiplied by " + str(B.new(3).power(next)),
		"get_cost": func(next:int): return B.new(1000).multiply(B.new(10).power(next)),
		"get_multi": func(val:int) -> Dictionary[String, B]: return {"mastery":B.new(3).power(val)},
	},
	#endregion
	
}

var crates = {

	"basic": {
		"id": "basic", # Must be the same as the key
		"health": 10,
		"name": "Stat crate",
		"desc": "A basic crate. Affects various early multipliers.",
		"reset_tags": ["rank"],
		"cost": {
			"currency_name": "PP",
			"get_player_currency": func(): return Globals.game.get_stat("prestige_points"),
			"spend_currency": func(amt:Variant): Globals.game.minus_stat("prestige_points", amt),
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
			{"name": "Unfathomable", "color":Color(0.3,0.6,0.6), "weight": 0.01,"multi": {"cash": 100, "multiplier": 100, "rebirths": 100, "prestige_points": 2}},
		]
	},

	"token": {
		"id": "token", # Must be the same as the key
		"health": 15,
		"name": "Token crate",
		"desc": "Low bonuses, but affects a bunch of stats. Even PP!",
		"reset_tags": ["rank"],
		"cost": {
			"currency_name": "Tokens",
			"get_player_currency": func(): return Globals.game.get_reset("tokens").points,
			"spend_currency": func(amt:Variant): Globals.game.spend_reset_points("tokens", amt),
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
					"cash": 0.5, 
					"multiplier": 0.4, 
					"rebirths": 0.3, 
					"super": 0.2, 
					"ultra": 0.2, 
					"mega": 0.2, 
					"hyper": 0.2, 
					"prestige_points": 0.2
				}
			},
		]
	},

	# Keep these together, preferably at the end.
	#region Rank crates
	"rank1": {
		"id": "rank1", # Must be the same as the key
		"health": 30,
		"name": "Rank 1 Crate",
		"desc": "Reward for reaching rank 1. Only 1 reward.",
		"reset_tags": [],
		"rewards": [
			{"name": "Rank 1", "color":Color(0.8,0.4,0.4), "weight": 10.0,"multi": {"cash": 1, "prestige_points": 0.5}},
		]
	},
	#endregion
}

# NOTE: Most rank logic done in rank.gd to avoid a bunch of lambdas
var ranks = {
	1: {
		"requirement": {
			"text": "30M PP",
			"get_progress": func() -> float: return min(Globals.game.get_stat("prestige_points").divide(B.new(3, 7)).mantissa, 1)
		},
		"unlock": "Mastery menu, rank 1 crate"
	}
}

var mastery = {
	"multiplier": {
		"max": 30, # Max progress; supports int and bignum
		"get_multi": func(current:B): return current.divideEquals(4).plusEquals(1)
	},
	"rebirths": {
		"max": 100,
		"get_multi": func(current:B): return current.divideEquals(4).plusEquals(1)
	},
	"super": {
		"max": 1000,
		"get_multi": func(current:B): return current.divideEquals(4).plusEquals(1)
	},
	"ultra": {
		"max": 10000,
		"get_multi": func(current:B): return current.divideEquals(4).plusEquals(1)
	},
	"mega": {
		"max": 10000,
		"get_multi": func(current:B): return current.divideEquals(4).plusEquals(1)
	},
	"hyper": {
		"max": 100000,
		"get_multi": func(current:B): return current.divideEquals(4).plusEquals(1)
	},
}

## Reorganized reset data for the multipliers. Done to save performance.
var reset_stat_multis = {}

func has_unlock(unlock:Unlocks) -> bool:
	match unlock:
		Unlocks.MASTERY:
			return Globals.game.get_rank() >= 1
		_:
			return false

func _ready() -> void:

	## Load data in reset_stat_multis
	for k in RESET_LAYERS:
		for multi in RESET_LAYERS[k]["multiplies"]:
			if not multi in reset_stat_multis:
				reset_stat_multis[multi] = []
			reset_stat_multis[multi].append([k, RESET_LAYERS[k]["multiplies"][multi]])
