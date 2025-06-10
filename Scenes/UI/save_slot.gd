extends Control

signal WipeClicked
signal PlayClicked
signal NameChanged

func load_slot_data(slot:Dictionary):
	$HBoxContainer/VBoxContainer/Name.text = slot["name"]
	
	if not slot["data"]:
		printerr("Slot not found! Cannot load data!")
		return
		
	$HBoxContainer/VBoxContainer/TimePlayed.text = str(slot["data"]["time"])

func _ready() -> void:
	$HBoxContainer/Wipe.pressed.connect(WipeClicked.emit)
	$HBoxContainer/Play.pressed.connect(PlayClicked.emit)
	$HBoxContainer/VBoxContainer/Name.text_submitted.connect(NameChanged.emit)
