extends PanelContainer

@onready var upgrade_container:VBoxContainer = $VBoxContainer/ScrollContainer/Upgrades

func open():
	visible = true

func close():
	visible = false

func _process(delta: float) -> void:
	if !visible:
		return
	$VBoxContainer/Current.text = "You currently have " + str(Game.get_reset("prestige")["points"]) + " PP."
