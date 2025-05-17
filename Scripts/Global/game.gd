extends Node

var player = {}

var NUM_0 = B.new(0)
var NUM_1 = B.new(1)

func get_player_data():
	var s = {
		"time": 0.0,

		"cash": B.new(0),
		"multiplier": B.new(0),
		"rebirths": B.new(0),
		"super":B.new(0),
		"ultra":B.new(0),
		"mega":B.new(0),
		"prestige_points":B.new(0),

		"upgrades": {}

	}

	return s

## Get the multiplier of a stat from all of the reset data.
func _get_reset_multi(key:String) -> B:
	var mul = B.new(1)

	for k in Config.RESET_LAYERS:
		if key not in Config.RESET_LAYERS[k]["multiplies"]:
			continue
		var val = Game.player[k].multiply(B.new(Config.RESET_LAYERS[k]["multiplies"][key]))
		mul = mul.multiply(val.plus(B.new(1)))

	return mul

## Get the amount that a stat would be increased by accounting for multipliers.
func get_stat_increase(key:String, val:B):

	if key not in Game.player:
		print_debug("Warning: Key not found for increase.")

	val = val.multiply(_get_reset_multi(key))
	return val

## Increase a stat accounting for multipliers. The stat is assumed to be a direct key of player
func increase_stat(key:String, val:B):

	if key not in Game.player:
		print_debug("Warning: Key not found for increase.")

	player[key] = player[key].plus(get_stat_increase(key, val))

## Gets a stat from the player
func get_stat(stat:String) -> B:
	return player[stat]

## Sets a player's stat
func set_stat(stat:String, val:B) -> void:
	player[stat] = val

## Sets a stat to zero.
func zero_stat(stat:String) -> void:
	player[stat] = Game.NUM_0

func _ready() -> void:
	player = get_player_data()
