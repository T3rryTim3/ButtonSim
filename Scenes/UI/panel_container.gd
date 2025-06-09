extends PanelContainer

func _process(_delta: float) -> void:
	if !visible:
		return
	$VBoxContainer/CurrentTokens.text = "You currently have " + str(Game.get_stat("tokens")) + " tokens."
