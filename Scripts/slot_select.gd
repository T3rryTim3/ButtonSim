extends Control

@onready var slot_container : VBoxContainer = $ScrollContainer/VBoxContainer/Slots

var save_slot : PackedScene = preload("res://Scenes/UI/save_slot.tscn")

func load_slots():
	
	for child in slot_container.get_children():
		child.queue_free()
	
	var save_data = Globals.main.save_manager.get_all_save_data()
#
	for slot in save_data["slots"]:
		var node_slot = save_slot.instantiate()
		node_slot.load_slot_data(slot)
		slot_container.add_child(node_slot)
