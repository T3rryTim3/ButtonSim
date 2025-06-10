extends Node
## Main scene node. Manages data loading and general game properties.

@onready var save_manager = $SaveManager

var game_path = "res://Scenes/game.tscn"

var current_game:Control
var current_slot:int

# TODO Auto save on quit

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#save_game()
		get_tree().quit()


## Loads in the game from a passed dictionary of player data.
func load_game_from_data(player:Dictionary) -> void:
	
	if current_game:
		current_game.queue_free()
	
	current_game = load(game_path).instantiate()
	current_game.player = player
	
	Globals.game = current_game

	add_child(current_game)


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
	
	#load_game_from_data({})
