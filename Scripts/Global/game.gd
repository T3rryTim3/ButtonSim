extends Node

var scn_upgrade = preload("res://Scenes/UI/upgrade.tscn")

var player = {}

var NUM_0 = B.new(0)
var NUM_1 = B.new(1)

var _cached_stat_increases := {}

func get_player_data():
	var s = {
		"time": 0.0,

		"score": B.new(0),

		"cash": B.new(0),
		"multiplier": B.new(0),
		"rebirths": B.new(200),
		"super":B.new(0),
		"ultra":B.new(0),
		"mega":B.new(0),

		"resets": {
			"prestige": {
				"count" : B.new(0),
				"points":B.new(0)
			},
		},

		"buy_speed": Config.BASE_BUY_SPEED, ## Time it takes for each button buy

		"upgrades": {}

	}

	for upgrade in Config.upgrades:
		s["upgrades"][upgrade] = {
			"purchased": 0
		}

	return s

#region Stat Management
## Get the multiplier of a stat from all of the reset data.
func _get_reset_multi(mul:B, key:String) -> B:

	if key in Config.reset_stat_multis:
		for k in Config.reset_stat_multis[key]:
			mul.multiplyEquals(player[k[0]].multiply(k[1]).quickPlusEquals(1.0))

	return mul

## Get the amount that a stat would be increased by accounting for multipliers.
func get_stat_increase(key:String, val:B):

	if key not in Game.player:
		print_debug("Warning: Key not found for increase.")

	var mul:B

	if key in _cached_stat_increases:
		mul = _cached_stat_increases[key]
	else:
		mul = B.new(1)
		mul = _get_reset_multi(mul, key)
		_cached_stat_increases[key] = mul

	return val.multiply(mul)

## Increase a stat accounting for multipliers. The stat is assumed to be a direct key of player
func increase_stat(key:String, val:Variant):

	if val is float or val is int:
		val = B.new(val)
	elif val is not B:
		printerr("Non-number passed to increase stat!")
		return

	if key not in Game.player:
		print_debug("Warning: Key not found for increase.")

	player[key] = player[key].plus(get_stat_increase(key, val))

## Gets a stat from the player
func get_stat(stat:String) -> Variant:
	return player[stat]

## Sets a player's stat
func set_stat(stat:String, val:B) -> void:
	player[stat] = val

## Sets a stat to zero.
func zero_stat(stat:String) -> void:
	player[stat] = Game.NUM_0
#endregion

#region Resets
## Gets a reset data dict from the player
func get_reset(stat:String) -> Variant:
	return player["resets"][stat]

func spend_reset_points(stat:String, amt:Variant) -> void:
	player["resets"][stat].points.minusEquals(amt)
#endregion

#region Upgrades
func get_upgrades_by_tag(tag:String) -> Dictionary:
	var upgrades = {}

	for k in Config.upgrades:
		if tag in Config.upgrades[k]["tags"]:
			upgrades[k] = Config.upgrades[k]

	return upgrades

## Gets the amount of times an upgrade has been bought
func get_upgrade_count(upgrade:String) -> int:
	return player["upgrades"][upgrade]["purchased"]

## Increases the amount of times an upgrade has been bought
func increase_upgrade_count(upgrade:String, amt:int=1) -> void:
	player["upgrades"][upgrade]["purchased"] += amt

## Reset an upgrade's buy count to zero.
func reset_upgrade_count(upgrade:String, amt:int=1) -> void:
	player["upgrades"][upgrade]["purchased"] = 0
#endregion

#region Base functions
func _process(delta: float) -> void:
	_cached_stat_increases = {} # Reset cache every frame

	# Update buy speed
	var buy_speed = Config.BASE_BUY_SPEED
	buy_speed *= pow(0.8, get_upgrade_count("PP Buy speed"))
	player.buy_speed = buy_speed

func _ready() -> void:
	player = get_player_data()
#endregion
