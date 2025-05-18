extends PanelContainer

@onready var upgrade_container:VBoxContainer = $VBoxContainer/ScrollContainer/Upgrades

func open():
	_load_upgrades()
	visible = true

func close():
	visible = false

func _process(delta: float) -> void:
	if !visible:
		return
	$VBoxContainer/Current.text = "You currently have " + str(Game.get_reset("prestige")["points"]) + " PP."

func _load_upgrades() -> void:
	var upgrades = Game.get_upgrades_by_tag("prestige")

	for child in upgrade_container.get_children():
		child.queue_free() 

	for k in upgrades:
		var button:Upgrade = Game.scn_upgrade.instantiate()
		button.upgrade_id = k
		button.upgrade_data = upgrades[k]
		upgrade_container.add_child(button)
