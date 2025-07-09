extends PanelContainer

@onready var container = $VBoxContainer/GridContainer

var tier_labels = {}

func _ready() -> void:
	_update_visibility()
	$VBoxContainer/Title.pressed.connect(_update_visibility)


func _update_visibility() -> void:
	container.visible = $VBoxContainer/Title.button_pressed


func update_display() -> void:
	
	var material_data = Globals.game.get_material_tiers(name)
	var total_amount = 0
	
	if not material_data: print_debug("Attempt to update nonexistent material!") ; return
	
	for tier in material_data:
		var label : Label
		
		if tier in tier_labels:
			label = tier_labels[tier]
		else:
			label = Label.new()
			label.add_theme_font_size_override("font_size", 20)
			tier_labels[tier] = label
			container.add_child(label)
		
		label.text = tier + "-Tier: " + str(material_data[tier])
		total_amount += material_data[tier]
		
	$VBoxContainer/Title.text = name.capitalize() + ": " + str(total_amount)
