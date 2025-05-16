extends PanelContainer

@onready var button_container:VBoxContainer = $ScrollContainer/VBoxContainer/Buttons
@onready var title_label:Label = $ScrollContainer/VBoxContainer/Label
@onready var desc_vbox:VBoxContainer = $ScrollContainer/VBoxContainer/Desc/VBoxContainer

var key:String

## The type of currency needed to buy this layer
var currency:String

func _get_button_cost(button_index:int):
	var cost = B.new(Config.RESET_LAYERS[key]["cost"]["init"])
	cost = cost.multiply(B.new(pow(Config.RESET_LAYERS[key]["cost"]["scale"], button_index)))
	#if "exp_growth" in Config.RESET_LAYERS[key]["cost"]:
		#cost = cost.to_pow(Config.RESET_LAYERS[key]["cost"]["exp_growth"] * button_index)
	return cost

func _get_button_gain(button_index:int):
	var gain = B.new(Config.RESET_LAYERS[key]["init_val"])
	gain = gain.multiply(B.new(pow(Config.RESET_LAYERS[key]["scale_val"], button_index)))
	#if "exp_growth" in Config.RESET_LAYERS[key]["cost"]:
		#gain = gain.to_pow(Config.RESET_LAYERS[key]["cost"]["exp_growth"] * button_index)
	gain = Game.get_stat_increase(key, gain)
	return gain

## Update a button's data
func _update_button(button:Button):
	var button_index = button.get_meta("idx", 0)

	var cost = _get_button_cost(button_index)
	var gain = _get_button_gain(button_index)
	gain = Game.get_stat_increase(key, gain)

	button.text = "Buy " + str(gain) + " " + key + " - " + str(cost) + " " + currency

	button.disabled = not Game.get_stat(currency).exceeds(cost)

## When a button is pressed to purchase the reset layer.
func _button_pressed(button:Button):
	var button_index = button.get_meta("idx", 0)
	
	var cost = _get_button_cost(button_index)
	var gain = _get_button_gain(button_index)

	if not Game.get_stat(currency).exceeds(cost):
		return

	Game.set_stat(currency, Game.player[currency].subtract(cost))
	for reset in Config.RESET_LAYERS[key]["reset"]:
		Game.zero_stat(reset)

	Game.increase_stat(key, gain)

func _reload() -> void:

	# Update Buttons
	for button in button_container.get_children():
		if button is not Button:
			continue
		_update_button(button)

	# Update total bonuses
	for child in desc_vbox.get_children():
		if child.has_meta("mult"):
			var mult = child.get_meta("mult")
			child.text = mult.capitalize() + ": x" + str((Game.get_stat(key).multiply(B.new(Config.RESET_LAYERS[key]["multiplies"][mult]))).add(B.new(1)))

func _process(delta: float) -> void:
	_reload()

func _ready() -> void:
	# Set base stuff up
	title_label.text = key.capitalize()
	modulate = Config.RESET_LAYERS[key]["color"]

	currency = Config.RESET_LAYERS[key]["cost"]["currency"]

	# Create buttons
	for x in range(20):
		var button = Button.new()
		button.set_meta("idx", x)
		button.pressed.connect(_button_pressed.bind(button))
		_update_button(button)
		button_container.add_child(button)

	# Create the total bonuses display
	for mult in Config.RESET_LAYERS[key]["multiplies"]:
		var label = Label.new()
		label.set_meta("mult", mult)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_vbox.add_child(label)

	_reload()
