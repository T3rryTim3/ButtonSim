extends PanelContainer

func update(progress:float, multi:B, current:B, item_name) -> void:
	$VBoxContainer/ProgressBar.value = progress
	$VBoxContainer/name.text = item_name.capitalize() + " - lvl. " + str(current)
	$VBoxContainer/HBoxContainer2/current.text = "Current Multiplier: " + str(multi)
