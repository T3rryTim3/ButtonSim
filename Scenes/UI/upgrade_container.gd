extends ScrollContainer

@onready var upgrade_container:VBoxContainer = $Upgrades

@export var upgrade_tags:Array[String]
@export var display_types:Array[Upgrade.DisplayTypes]

func open():
	_load_upgrades()
	visible = true

func close():
	visible = false

func _ready() -> void:
	if not Game.ready:
		await Game.ready
	_load_upgrades()

func _load_upgrades() -> void:
	for tag in range(len(upgrade_tags)):
		var upgrades = Game.get_upgrades_by_tag(upgrade_tags[tag])

		for child in upgrade_container.get_children():
			child.queue_free() 

		for k in upgrades:
			var button:Upgrade = Game.scn_upgrade.instantiate()
			button.display = display_types[tag]
			button.upgrade_id = k
			button.upgrade_data = upgrades[k]
			upgrade_container.add_child(button)
