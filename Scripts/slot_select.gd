extends Control

@onready var slot_container : VBoxContainer = $ScrollContainer/VBoxContainer/Slots
@onready var new_slot_button : Button = $ScrollContainer/VBoxContainer/New

var save_slot : PackedScene = preload("res://Scenes/UI/save_slot.tscn")

func load_slots():
	
	for child in slot_container.get_children():
		child.queue_free()
	
	var save_data = Globals.main.save_manager.get_all_save_data()

	var i = 0
	for slot in save_data["slots"]:
		
		var node_slot = save_slot.instantiate()
		node_slot.load_slot_data(slot)
		node_slot.set_meta("idx", i)
		
		node_slot.NameChanged.connect( func(new): Globals.save_manager.change_slot_name(i, new) )
		node_slot.WipeClicked.connect( func(): Globals.save_manager.delete_slot(i) ; load_slots() )
		node_slot.PlayClicked.connect( func(): Globals.main.load_game_from_slot(i) )
		
		slot_container.add_child(node_slot)
		i += 1

func _ready() -> void:
	new_slot_button.pressed.connect( func(): Globals.save_manager.new_slot() ; load_slots() )
