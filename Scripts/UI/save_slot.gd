extends Control

signal WipeClicked
signal PlayClicked
signal NameChanged

func load_slot_data(slot:Dictionary):
	$Name.text = slot["name"]
	
	if not slot["data"]:
		printerr("Slot not found! Cannot load data!")
		return
		
	$Name/TimePlayed.text = str(slot["data"]["time"])

func _ready() -> void:
	$Name/Wipe.pressed.connect(WipeClicked.emit)
	$Name/Play.pressed.connect(PlayClicked.emit)
	$Name.text_submitted.connect(NameChanged.emit)
