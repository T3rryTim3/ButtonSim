extends PanelContainer

func _process(_delta: float) -> void:
	if !visible:
		return
	$VBoxContainer/CurrentTokens.text = "You currently have " + str(Globals.game.get_stat("tokens")) + " tokens."
