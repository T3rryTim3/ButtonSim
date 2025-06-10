extends HBoxContainer

signal WipeClicked
signal PlayClicked

func load_slot_data(slot:Dictionary):
	$VBoxContainer/Name.text = slot["name"]
	$VBoxContainer/TimePlayed.text = str(slot["data"]["time"])

func _ready() -> void:
	$Wipe.pressed.connect(WipeClicked.emit)
	$Play.pressed.connect(PlayClicked.emit)
