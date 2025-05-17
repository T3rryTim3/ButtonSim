extends PanelContainer
class_name ResetLayer

@onready var button_container:VBoxContainer = $ScrollContainer/VBoxContainer/Buttons
@onready var title_label:Label = $ScrollContainer/VBoxContainer/Label
@onready var desc_vbox:VBoxContainer = $ScrollContainer/VBoxContainer/Desc/VBoxContainer

var reset_button = preload("res://Scenes/UI/reset_button.tscn")

var key:String

## The type of currency needed to buy this layer
var currency:String

func _reload() -> void:
	# Update total bonuses
	for child in desc_vbox.get_children():
		if child.has_meta("mult"):
			var mult = child.get_meta("mult")
			child.text = mult.capitalize() + ": x" + str((Game.get_stat(key).multiply(Config.RESET_LAYERS[key]["multiplies"][mult])))

func _process(delta: float) -> void:
	_reload()

func _ready() -> void:
	# Set base stuff up
	title_label.text = key.capitalize()
	modulate = Config.RESET_LAYERS[key]["color"]

	currency = Config.RESET_LAYERS[key]["cost"]["currency"]

	# Create buttons
	for x in range(60):
		var button = reset_button.instantiate()
		button.key = key
		button.button_idx = x
		button.reset_layer = self
		button_container.add_child(button)

	# Create the total bonuses display
	for mult in Config.RESET_LAYERS[key]["multiplies"]:
		var label = Label.new()
		label.set_meta("mult", mult)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_vbox.add_child(label)

	_reload()
