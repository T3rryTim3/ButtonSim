extends Control

signal WipeClicked
signal PlayClicked
signal NameChanged
signal DuplicateClicked

func load_slot_data(slot:Dictionary):
	$Name.text = slot["name"]
	
	if not slot["data"]:
		printerr("Slot not found! Cannot load data!")
		return
		
	$Name/TimePlayed.text = str(Globals.main.format_time(slot["data"]["time"]))

func _ready() -> void:
	$Name/Buttons1/Wipe.pressed.connect(WipeClicked.emit)
	$Name/Buttons1/Duplicate.pressed.connect(DuplicateClicked.emit)
	$Name/Play.pressed.connect(PlayClicked.emit)
	$Name.text_submitted.connect(NameChanged.emit)
