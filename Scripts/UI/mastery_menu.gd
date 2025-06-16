extends PanelContainer

@onready var mastery_vbox = $HSplitContainer/VBoxContainer
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

func _process(delta: float) -> void:
	
	if not is_visible_in_tree():
		return
	
	for child in mastery_vbox.get_children():
		
		if not child.has_meta("key"):
			continue
		
		var key = child.get_meta("key")
		var mastery = Globals.game.get_mastery(key)
		
		var prog:float
		var multi:B
		var current:B
		
		if mastery:
			prog = min(1, B.division(mastery.progress, Config.mastery[key].max).toFloat())
			multi = mastery.multi
			current = mastery.current
		
		else:
			prog = 0
			multi = B.new(2)
			current = B.new(0)
		
		child.update(prog, multi, current, key)

func _ready() -> void:
	load_mastery_items()
