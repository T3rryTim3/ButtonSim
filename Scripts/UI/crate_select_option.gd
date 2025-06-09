extends PanelContainer

signal clicked

@onready var data_container:VBoxContainer = $MarginContainer/HSplitContainer/VBoxContainer

var crate_data:Dictionary = {}
var show_data:bool = true

func update_crate_display() -> void:
	var count = Game.get_crate_count(crate_data["id"])
	if count <= 0:
		hide()
	else:
		show()
	if "name" in crate_data:
		data_container.get_node("Title").text = crate_data["name"] + " x" + str(Game.get_crate_count(crate_data["id"]))

func load_crate(crate:Dictionary = {}):
	crate_data = crate

	update_crate_display()

	# Cost display removed in favor of crates being bought elsewhere.
	# Kept in code just in case needed later.
	data_container.get_node("Cost").hide()
	#if "cost" in crate_data:
		#data_container.get_node("Cost").text = str(crate_data["cost"]["get_cost"].call()) + " " + crate_data["cost"]["currency_name"]
	
	if "desc" in crate_data:
		data_container.get_node("Desc").text = crate_data["desc"]


func _process(_delta: float) -> void:
	if show_data and data_container.visible == false:
		data_container.visible = true
	if !show_data and data_container.visible == true:
		data_container.visible = false


func _ready() -> void:
	$Button.pressed.connect(clicked.emit)
	SignalBus.CrateOpened.connect(func(): load_crate(crate_data))
