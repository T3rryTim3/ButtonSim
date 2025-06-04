extends PanelContainer

signal clicked

@onready var data_container:VBoxContainer = $MarginContainer/HSplitContainer/VBoxContainer

var crate_data:Dictionary = {}
var show_data:bool = true

func load_crate(crate:Dictionary = {}):
	crate_data = crate
	if "name" in crate:
		data_container.get_node("Title").text = crate["name"] + " x" + str(Game.get_crate_count(crate_data["id"]))
	if "cost" in crate:
		data_container.get_node("Cost").text = str(crate["cost"]["get_cost"].call()) + " " + crate["cost"]["currency_name"]
	if "desc" in crate:
		data_container.get_node("Desc").text = crate["desc"]

func _process(delta: float) -> void:
	if show_data and data_container.visible == false:
		data_container.visible = true
	if !show_data and data_container.visible == true:
		data_container.visible = false

func _ready() -> void:
	$Button.pressed.connect(clicked.emit)
	SignalBus.CrateOpened.connect(func(): load_crate(crate_data))
