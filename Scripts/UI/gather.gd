extends Control

@onready var vbox_gather_locations = %GatherLocations
@onready var vbox_maerial_display = %MaterialDisplayVBox

var scn_gather_location = preload("res://Scenes/UI/gather_location.tscn")
var scn_material_display = preload("res://Scenes/UI/material_display.tscn")


func _ready() -> void:
	
	if not Globals.game.is_node_ready():
		await Globals.game.ready
	
	load_gather_locations()
	
	SignalBus.MaterialGained.connect(update_material_display)


## Load the gather locations specified in Config.gather_locations.
func load_gather_locations() -> void:
	
	for location in vbox_gather_locations.get_children():
		location.queue_free()
	
	for location in Config.gather_locations:
		
		var dict = Config.gather_locations[location]
		if not dict.unlocked.call(): continue
		
		var new_node = scn_gather_location.instantiate()
		
		new_node.GatherPressed.connect( Globals.game.start_gathering.bind(location))
		
		vbox_gather_locations.add_child(new_node)
		
		new_node.location = location


## Updates the material display for the passed material,
## and creates one if needed.
func update_material_display(key:String) -> void:
	print(key)
	var target : PanelContainer
	
	for child in vbox_maerial_display.get_children():
		if child.name == key:
			target = child
			break
	
	if not target:
		target = scn_material_display.instantiate()
		target.name = key
		vbox_maerial_display.add_child(target)
	
	target.update_display()
