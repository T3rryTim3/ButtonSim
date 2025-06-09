extends Node

var scn_upgrade = preload("res://Scenes/UI/upgrade.tscn")
var scn_currency_popup = preload("res://Scenes/UI/CurrencyPopup.tscn")

var player := {}

var NUM_0 := B.new(0)
var NUM_1 := B.new(1)

var _cached_stat_increases := {}

var crate_reward_multis := {}

#region Player Data
func get_player_data():
	var s = {
		"time": 0.0,

		"score": B.new(0),

		"tokens": B.new(100),

		"cash": B.new(0),
		"multiplier": B.new(0),
		"rebirths": B.new(10),
		"super":B.new(0),
		"ultra":B.new(0),
		"mega":B.new(0),
		"hyper":B.new(0),

		"resets": {
			"prestige": {
				"count" : B.new(0),
				"points":B.new(100)
			},
		},

		"buy_speed": Config.BASE_BUY_SPEED, ## Time it takes for each button buy
		"autobuy_speed": Config.BASE_BUY_SPEED/2, ## Time it takes for each auto button buy

		"upgrades": {},

		"crates": {},
		"crate_rewards": {}

	}

	for upgrade in Config.upgrades:
		s["upgrades"][upgrade] = {
			"purchased": 0
		}

	for crate in Config.crates:
		s["crates"][crate] = 20
		for reward in Config.crates[crate]["rewards"]:
			s["crate_rewards"][reward["name"]] = 0

	return s

## Convert a value to json accounting for bignums or other data types as
## they are added.
func to_json(d:Variant) -> Variant:
	var new

	if d is Dictionary:
		new = {}
		for k in d:
			new[k] = to_json(d[k])
	elif d is Array:
		new = []
		for i in d:
			new.append(to_json(i))
	elif d is B:
		new = d.to_json()
	else:
		return d

	return new

func from_json(d:Variant) -> Variant:
	var new

	if d is Dictionary:
		if not "_type" in d:
			new = {}
			for k in d:
				new[k] = from_json(d[k])
		elif d._type == "bignum":
			new = B.from_json(d)
	elif d is Array:
		new = []
		for i in d:
			new.append(from_json(i))
	else:
		return d

	return new

func save_game() -> void:
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	var savedata = {
		"slots": [
			{
				"name": "Default",
				"data": {}
			}
		]
	}
	
	var new_save = to_json(player)

	savedata.slots[0]["data"] = new_save

	save_file.store_line(JSON.stringify(savedata))
	save_file.close()

	print("Game successfully saved.")

func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		print("No save data found. Using default.")
		player = get_player_data()
		return
	
	var json = JSON.new()
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var parse_result = json.parse(save_file.get_as_text())

	if not parse_result == OK:
		printerr("Error parsing save data!")
		print(json.get_error_message())
		return

	if json.data and json.data["slots"][0]["data"]:
		player = from_json(json.data["slots"][0]["data"])

	print("Game successfully loaded.")

#endregion

#region Crates
## Increments the player's crate rewards by the reward-amount key-value pairs passed
func increase_crate_rewards(reward_dict:Dictionary):
	for k in reward_dict:
		player.crate_rewards[k] += reward_dict[k]["amt"]
	_update_crate_reward_multis()


## Updates the internal crate multi dict; called on crate opening
func _update_crate_reward_multis() -> void:
	var new_multis = {}
	for crate in Config.crates:
		for reward in Config.crates[crate]["rewards"]:
			for multi in reward["multi"]:
				if not multi in new_multis:
					new_multis[multi] = B.new(1)
				new_multis[multi].multiplyEquals(player.crate_rewards[reward["name"]]*reward["multi"][multi]+1)
	crate_reward_multis = new_multis

## Get the multiplier of a given stat 
func _get_crate_reward_multi(mul:B, key:String) -> B:
	if key in crate_reward_multis:
		mul.multiplyEquals(crate_reward_multis[key])
	return mul


## Returns a dictionary of crate reward names to their respective multipliers.
func get_crate_rewards() -> Dictionary:
	return player.crate_rewards


## Returns the current amount of a given crate.
func get_crate_count(crate:String) -> int:
	return player.crates[crate]


## Decrease `crate` count by `amt`
func decrease_crate_count(crate:String, amt:int = 1) -> void:
	player.crates[crate] -= amt


## Increase `crate` count by `amt`
func increase_crate_count(crate:String, amt:int = 1) -> void:
	player.crates[crate] += amt
	if amt > 0:
		SignalBus.CrateGained.emit()

#endregion

#region Stat Management
## Get the multiplier of a stat from all of the reset data.
func _get_reset_multi(mul:B, key:String) -> B:

	if key in Config.reset_stat_multis:
		for k in Config.reset_stat_multis[key]:
			mul.multiplyEquals(player[k[0]].multiply(k[1]).quickPlusEquals(1.0))

	var prestige_mutlis = get_prestige_bonuses()
	if key in prestige_mutlis:
		mul.multiplyEquals(prestige_mutlis[key])

	return mul


## Get a stats upgrade multipler based on upgrade data.
func _get_upgrade_multi(mul:B, key:String) -> B:

	match key:
		"cash":
			mul.multiplyEquals(get_upgrade_effect("Token Cash multi"))

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
		mul = _get_upgrade_multi(mul, key)
		mul = _get_crate_reward_multi(mul, key)
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


## Subtracts a player's stat by val
func minus_stat(stat:String, val:Variant) -> void:
	player[stat].minusEquals(val)


## Sets a stat to zero.
func zero_stat(stat:String) -> void:
	player[stat] = Game.NUM_0
#endregion

#region Prestige Bonuses
func get_prestige_bonuses() -> Dictionary:
	var bonuses = {}
	var pp = get_reset("prestige").points

	for k in range(get_upgrade_count("PP Boost")):
		bonuses[(["cash"]+Config.RESET_LAYERS.keys())[k]] = B.new(Config.PP_BONUS_BASE).divide(pow(Config.PP_BONUS_DIV_SCALE, k)).multiply(pp).plus(1)

	return bonuses
#endregion

#region Resets
## Gets a reset data dict from the player
func get_reset(stat:String) -> Variant:
	return player["resets"][stat]


## Gets the dict index of a reset
func get_reset_idx(stat:String) -> int:

	var idx = -1

	for k in Config.RESET_LAYERS:
		idx += 1
		if k == stat:
			break

	return idx


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


## Gets the effect of an upgrade
func get_upgrade_effect(upgrade:String, amt:int=-1) -> Variant:
	if amt < 0:
		amt = get_upgrade_count(upgrade)
	return Config.upgrades[upgrade]["get_effect"].call(amt)


## Increases the amount of times an upgrade has been bought
func increase_upgrade_count(upgrade:String, amt:int=1) -> void:
	player["upgrades"][upgrade]["purchased"] += amt


## Reset an upgrade's buy count to zero.
func reset_upgrade_count(upgrade:String, _amt:int=1) -> void:
	player["upgrades"][upgrade]["purchased"] = 0
#endregion

#region UI Effects
func currency_popup(label_text:String, label_color:Color=Color.WHITE, pos=null, p_scale:int=1, dir:Vector2 = Vector2.UP, time:float=0.5):
	
	var popup = scn_currency_popup.instantiate()
	popup.set_text(label_text)
	popup.set_color(label_color)
	popup.anim_time = time
	add_child(popup)

	if not pos:
		pos = popup.get_global_mouse_position() + Vector2(randi_range(-15,15),randi_range(-15,15))
	popup.global_position = pos

	popup.scale = Vector2(p_scale, p_scale)
	popup.dir = dir

	popup.play()
#endregion

#region Base functions
func _process(_delta: float) -> void:
	_cached_stat_increases = {} # Reset cache every frame

	# Update buy speed
	var buy_speed = Config.BASE_BUY_SPEED
	buy_speed *= pow(0.8, get_upgrade_count("PP Buy speed"))
	buy_speed *= get_upgrade_effect("Token Buy speed")
	player.buy_speed = buy_speed
	player.autobuy_speed = buy_speed*4

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()

func _ready() -> void:

	get_tree().auto_accept_quit = false
	load_game()

	tree_exiting.connect(save_game) 
	# TODO Auto save every n minutes
	# TODO Save slots + menu to select them
#endregion
