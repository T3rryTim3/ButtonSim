extends Tree

var root:TreeItem
var hide_unused:bool = true

func _get_multipliers() -> Dictionary:
	return Globals.game._all_multipliers

## Update each item's visibility based on metadata and `hide_unused`
func _update_visibility() -> void:
	
	for child in root.get_children():
		
		if child.has_meta("has_multi"):
			if child.get_meta("has_multi"):
				child.visible = true
			elif hide_unused:
				child.visible = false
		
		for source in child.get_children():
			if source.has_meta("has_multi") and source.get_meta("has_multi"):
				child.visible = true
			elif hide_unused:
				source.visible = false


func _create() -> void:
	
	for child in root.get_children():
		root.remove_child(child)
	
	for k:String in _get_multipliers():
		
		var item = create_item(root)
		var has_multi:bool = false
		
		item.set_selectable(0, false)
		item.set_text(0, k.capitalize())
		item.set_metadata(0, k)
		
		for s in _get_multipliers()[k]["source"]:
			
			var multi = create_item(item)
			multi.set_text(0, s)
			
			if multi.get_text(0).ends_with("x1.0"):
				multi.set_meta("has_multi", false)
			else:
				multi.set_meta("has_multi", true)
				has_multi = true
		
		item.set_meta("has_multi", has_multi)

func _ready() -> void:
	
	if not Globals.game.is_node_ready():
		await Globals.game.ready
		
	root = create_item()
	
	_create()
	_update_visibility()

	# Reload upon tab switch
	SignalBus.TabSelected.connect(func(new): if new == get_parent(): _create();_update_visibility())
	

#func _process(delta: float) -> void:
	#if visible:
		#_create()
