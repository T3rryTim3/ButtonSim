extends Node
## Main scene node. Manages data loading and general game properties.

@onready var save_manager = $SaveManager

var game_path = "res://Scenes/game.tscn"

var current_game:Control
var current_slot:int

# TODO Auto save on quit

#region Utility
## Fills in a dictionary's missing keys and values based on a
## passed template. 
##
## If match_type is enabled (default), the item
## will be replaced if its value differs in type from source.
##
## If delete_unused is enabled (default), keys in target not present
## in source will also be deleted.
func fill_dict(target:Dictionary, source:Dictionary, match_type:bool=true, delete_unused:bool=true) -> Dictionary:
	
	for k in source:
		
		if k not in target:
			target[k] = source[k]
			continue
		
		if ( typeof(source[k]) != typeof(target[k]) ) and match_type:
			target[k] = source[k]
			continue
		
		if typeof(source[k]) == TYPE_DICTIONARY:
			target[k] = fill_dict(target[k], source[k], match_type, delete_unused)
	
	if delete_unused:
		for k in target:
			if k not in source:
				target.erase(k)
	
	return target


#endregion

## Save the current game into the current slot's data.
func save_current_game() -> void:
	
	if current_game:
		
		if current_slot != -1:
			save_manager.save_game(current_game.player, current_slot)
			return
		
		print("Game not saved; current_slot == -1")

func _notification(what: int) -> void:
	
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_current_game()
		get_tree().quit()


## Loads in the game from a passed dictionary of player data.
## If save slot is not passed, the game will not save.
func load_game_from_data(player:Dictionary, save_slot:int=-1) -> void:
	
	if current_game:
		current_game.queue_free()
	
	current_slot = save_slot
	
	current_game = load(game_path).instantiate()
	current_game.player = player
	
	Globals.game = current_game

	add_child(current_game)

## Load in the game from a save slot index.
func load_game_from_slot(slot:int) -> void:
	
	var savedata = save_manager.get_all_save_data()
	
	current_slot = slot
	load_game_from_data(savedata["slots"][slot]["data"], slot)


# Debug controls; delete during production
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_P:
					save_manager.save_game(Globals.game.player, 0)


func _ready() -> void:
	get_tree().auto_accept_quit = false
	Globals.main = self
	Globals.save_manager = save_manager
	
	$Select/MarginContainer/VBoxContainer/SlotSelect.load_slots()
	
	# Detects if the game can persist data across sections.
	# This should trigger if a browser is blocking cookies, 
	# and thus can't access user://
	if not OS.is_userfs_persistent():
		$Select/Warning.show()
	
	#load_game_from_data({})
