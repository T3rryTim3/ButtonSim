extends Node
class_name Game
## The main game node.
##
## -- Overview --
## This handles all in-game data and manipulation of such. All data is kept within the "player" dictionary,
## but is never modified directly from any outside script. In the event you want to modify player data
## (E.g. spending cash), use a method within this node to do so.
##
## All "stats" should be bignums (B) and kept within the dictionary not nested within anything else.
## Not doing so leads to the setter and getter functions not working. 
##
## -- Other data types  + Saving/loading --
## If you ever use a data type which is not already present within the player dictionary, be sure
## to check if it can be converted into JSON within save_manager.gd. If not, implement it or
## consider an alternative. Do not change where stats are positioned for the sake of saving
## and loading data.
##
## -- Multiplier Caching --
## To save performance, a dictionary is kept and updated each frame with all of the multipliers.
## Whenever adding something which multiplies other stats, implement in properly within _cache_multis().
## Doing so allows for readability and for it to be seen in the stat index. Follow the examples within
## the function to add your implementation.
##
## -- Core functions --
## set_stat(): Used to set player stats that are directly present in the dictionary.
## get_stat(): Self-explanitory.
## _cache_multis() (Very important): Described in "Multiplier caching"
## increase_stat(): Use this whenever you increase a player's stat. This will ensure that it gets
## multiplied correctly from the cached multipliers.
##
## -- Adding on --
## If you add a feature which requires different setter and getter methods, create a separate region for it.
## Look at the upgrades and crates region for examples of how to do this.
##
## -- Use Config.gd --
## Config.gd (a global script) contains data for any features such as upgrades and crates. Add your data there.
## Do not add it anywhere else without a good reason to do so. This allows for easy balance changes
## later on should it be needed.
##
## -- Why not directly? --
## Changing stats only through these methods allows for easy changes later in development. Should you
## change how stats work there is no need to rewrite code in a bunch of different scripts.

#region Variables

## Emitting this will cause main to save and exit the game to the menu.
signal save_and_exit

var scn_upgrade = preload("res://Scenes/UI/upgrade.tscn")
var scn_currency_popup = preload("res://Scenes/UI/CurrencyPopup.tscn")

## The player dictionary. Initialized at _ready().
var player := {}

## Constants for big nums. use these instead of creating a bignum where applicable for performance.
var NUM_0 := B.new(0)
var NUM_1 := B.new(1)

var _cached_stat_increases := {}

var crate_reward_multis := {}

## All of the cached multipliers for the frame.
var _all_multipliers:Dictionary

#endregion

#region Player Data
func get_player_data():
	var s = {
		"time": 0.0,

		"score": B.new(0),

		"tokens": B.new(0),

		"rank": 0,

		"cash": B.new(0),
		"multiplier": B.new(0),
		"rebirths": B.new(0),
		"super":B.new(0),
		"ultra":B.new(0),
		"mega":B.new(0),
		"hyper":B.new(0),
		"prestige_points": B.new(0),

		"resets": {
			"prestige": {
				"count" : B.new(0),
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
		s["crates"][crate] = 0
		for reward in Config.crates[crate]["rewards"]:
			s["crate_rewards"][reward["name"]] = 0

	return s

#endregion

#region Crates
## Increments the player's crate rewards by the reward-amount key-value pairs passed
func increase_crate_rewards(reward_dict:Dictionary):
	for k in reward_dict:
		player.crate_rewards[k] += reward_dict[k]["amt"]


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


## Clears all crates and their rewards according to the tag provided.
## Tags can be found in each crate under Config.gd
func wipe_crates_by_tag(tag:String) -> void:
	
	for crate in Config.crates:
		
		var crate_data = Config.crates[crate]
		
		if not ("reset_tags" in crate_data and crate_data.reset_tags.has(tag)):
			continue
		
		player.crates[crate] = 0
		
		for reward in crate_data.rewards:
			player.crate_rewards[reward.name] = 0
#endregion

#region Stat Management

#region Changing stats
## Get the amount that a stat would be increased by accounting for multipliers.
func get_stat_increase(key:String, val:B):

	if key not in player:
		print_debug("Warning: Key not found for increase.")
	
	if key in _all_multipliers:
		return val.multiply(_all_multipliers[key].val)

	return val


## Increase a stat accounting for multipliers. The stat is assumed to be a direct key of player
func increase_stat(key:String, val:Variant):

	if val is float or val is int:
		val = B.new(val)
	elif val is not B:
		printerr("Non-number passed to increase stat!")
		return

	if key not in Globals.game.player:
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
	player[stat] = Globals.game.NUM_0


## Sets all reset layers to 0, including cash.
func wipe_reset_layers() -> void:
	
	for layer in Config.RESET_LAYERS:
		zero_stat(layer)
		
	set_stat("cash", B.new(0))

#endregion

#region Multiplier caching
## Multiply a cached value if present, creating objects if needed to do so.
func _multiply_cache_multi(k:String,v:B,src_string:String):
	#if v.isEqualTo(1):
		#return
	if k in _all_multipliers:
		_all_multipliers[k].val.multiplyEquals(v)
		_all_multipliers[k].source.append(src_string.capitalize() + ": x" + str(v))
	elif not k in _all_multipliers:
		_all_multipliers[k] = {
			"val": v,
			"source": [src_string.capitalize() + ": x" + str(v)],
		}


## Calculate all stat multipliers. Should be called each frame once.
func _cache_multis():
	_all_multipliers = {}
	
	# Reset layers (multiplier, rebirths, etc.)
	for stat in Config.reset_stat_multis:
		for source in Config.reset_stat_multis[stat]:
			_multiply_cache_multi(stat, get_stat(source[0]).multiply(source[1]).plus(1), "Reset - " + source[0])
	
	# Upgrades
	for upgrade in Config.upgrades:
		if "get_multi" in Config.upgrades[upgrade]:
			var multipliers = Config.upgrades[upgrade].get_multi.call(get_upgrade_count(upgrade))
			for multiplier in multipliers:
				_multiply_cache_multi(multiplier, multipliers[multiplier], "Upgrade - " + upgrade)
	
	# Crates (A tad ugly, I know)
	for crate in Config.crates:
		for reward in Config.crates[crate]["rewards"]:
			for multi in reward["multi"]:
				_multiply_cache_multi(
					multi, 
					B.new(player.crate_rewards[reward["name"]]*reward["multi"][multi]+1),
					"Crate Reward - " + reward["name"]
				)
	
	#print("----------")
	#return
#endregion

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

## Clears all crates and their rewards according to the tag provided.
## Tags can be found in each crate under Config.gd
##
## Note that this uses reset_tag and not tag like it does in
## get_upgrades_by_tag()
func wipe_upgrades_by_tag(tag:String) -> void:
	
	for upgrade in Config.upgrades:
		
		var upgrade_data = Config.upgrades[upgrade]
		
		if not ("reset_tags" in upgrade_data and upgrade_data.reset_tags.has(tag)):
			continue
		
		reset_upgrade_count(upgrade)


#endregion

#region Rank
func get_rank() -> int:
	return int(player.rank)

func get_rank_data(key) -> Dictionary:
	return Config.ranks[key]
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
func _process(delta: float) -> void:
	_cached_stat_increases = {} # Reset cache every frame

	# Update buy speed
	var buy_speed = Config.BASE_BUY_SPEED
	buy_speed *= pow(0.8, get_upgrade_count("PP Buy speed"))
	buy_speed *= get_upgrade_effect("Token Buy speed")
	player.buy_speed = buy_speed
	player.autobuy_speed = buy_speed*4
	
	player.time += delta

	_cache_multis()

func _ready() -> void:
	if not player:
		print("No player found. Loading default..")
		player = get_player_data()
	
	player = Globals.main.fill_dict(player, get_player_data())

	_cache_multis()
	
	%GameTabs.tab_clicked.connect(func(_idx:int): SoundManager.play_audio("res://Assets/Sound/UI SFX/Click1.wav", "SFX", randf_range(0.9,1.1)))
	%GameTabs.tab_clicked.connect(func(idx:int): SignalBus.TabSelected.emit(%GameTabs.get_tab_control(idx)))
	%SaveAndExit.pressed.connect(save_and_exit.emit)

	# TODO Auto save every n minutes
	# TODO Create settings menu
	#          - Visual effect options
	#          - Audio sliders
	#          - Different button display layouts
	#          - Tabbar position
#endregion


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_U:
					print(JSON.stringify(_all_multipliers, "\t"))
