extends PanelContainer

@onready var mastery_vbox = $HSplitContainer/ScrollContainer/VBoxContainer
@onready var mastery_template = preload("res://Scenes/UI/mastery_template.tscn")


func load_mastery_items() -> void:
	
	for child in mastery_vbox.get_children():
		child.queue_free()
	
	for layer in Config.RESET_LAYERS:
		
		var layer_data = Config.RESET_LAYERS[layer]
		var mastery = mastery_template.instantiate()
		
		mastery.modulate = layer_data.color
		mastery.set_meta("key", layer)
		
		mastery_vbox.add_child(mastery)
		mastery.PrestigeClicked.connect(prestige_mastery.bind(layer))


func prestige_mastery(key:String) -> void:
	
	var mastery = Globals.game.get_mastery(key)
	
	if not mastery:
		return
	
	Globals.game.prestige_mastery(key)
	
	%MasteryPointsDisplay.text = "You have " + str(Globals.game.get_stat("mastery_points")).trim_suffix(".0") + " Mastery points."


func _process(delta: float) -> void:
	
	if not is_visible_in_tree():
		return
	
	for child in mastery_vbox.get_children():
		
		if not child.has_meta("key"):
			continue
		
		var key = child.get_meta("key")
		
		child.update(key)


func _ready() -> void:
	load_mastery_items()
	%MasteryPointsDisplay.text = "You have " + str(Globals.game.get_stat("mastery_points")).trim_suffix(".0") + " Mastery points."
