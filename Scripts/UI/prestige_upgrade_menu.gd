extends PanelContainer

@onready var upgrade_container:VBoxContainer = $VBoxContainer/ScrollContainer/Upgrades

func open():
	visible = true

func close():
	visible = false

func _process(_delta: float) -> void:
	if !visible:
		return
	$VBoxContainer/Current.text = "You currently have " + str(Globals.game.get_stat("prestige_points")) + " PP."
