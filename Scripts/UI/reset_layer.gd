extends PanelContainer
class_name ResetLayer

@onready var button_container:VBoxContainer = $ScrollContainer/VBoxContainer/Buttons
@onready var title_label:Label = $ScrollContainer/VBoxContainer/Label
@onready var desc_vbox:VBoxContainer = $ScrollContainer/VBoxContainer/Desc/VBoxContainer/VBoxContainer
@onready var autobuy_button:Button = $ScrollContainer/VBoxContainer/Autobuy

var reset_button = preload("res://Scenes/UI/reset_button.tscn")

var key:String
var reset_idx:int

var autobuying:bool = false
var bought:int = 0 ## Amount of times bought
var buy_time:float = 0.0 ## Current time spent buying. Used to calculate buy amounts

## The type of currency needed to buy this layer
var currency:String

var last_button_count:int = 0

func _get_button_count():
	return 10 + Globals.game.get_upgrade_count("PP Buttons")*5

## Buy the most expensive button
func buy_highest_cost(bulk:int) -> void:

	if bulk <= 0:
		return

	var highest:Button
	var highest_idx:int = -1

	for button in button_container.get_children():
		if button.can_buy() and button.button_idx > highest_idx:
			highest = button
			highest_idx = button.button_idx

	bought += bulk

	if highest:
		highest.buy(bulk, true)

## Reload the text displayed
func _reload() -> void:
	# Update total bonuses
	for child in desc_vbox.get_children():
		if child.has_meta("mult"):
			var mult = child.get_meta("mult")
			child.text = mult.capitalize() + ": x" + str((Globals.game.get_stat(key).multiply(Config.RESET_LAYERS[key]["multiplies"][mult])))

func _update_autobuy():
	var autobuy_tier = Globals.game.get_upgrade_count("PP Auto Buy")

	if autobuy_tier <= reset_idx:
		autobuying = false
		$ScrollContainer/VBoxContainer/Autobuy.visible = false
		return
	$ScrollContainer/VBoxContainer/Autobuy.visible = true

	autobuying = $ScrollContainer/VBoxContainer/Autobuy.button_pressed

func _process(delta: float) -> void:
	_reload()

	_update_autobuy()

	if autobuying:
		buy_time += delta
		var to_buy = buy_time / Globals.game.get_stat("autobuy_speed")
		buy_highest_cost(max(0, to_buy - bought))
	else:
		buy_time = 0
		bought = 0

func update_button_count(count:int=10) -> void:

	if count == last_button_count:
		return
	last_button_count = count

	for button in button_container.get_children():
		button.queue_free()

	for x in range(count):
		if !button_container.find_child(str(x)):
			var button = reset_button.instantiate()
			button.name = str(x)
			button.key = key
			button.button_idx = x
			button.reset_layer = self
			button_container.add_child(button)

func _autobuy_pressed(toggled) -> void:
	SoundManager.play_audio("res://Assets/Sound/UI SFX/Click1.wav", "SFX")
	if toggled:
		autobuy_button.text = "Autobuy - Enabled"
	else:
		autobuy_button.text = "Autobuy - Disabled"

func _ready() -> void:
	if not Globals.game.is_node_ready():
		await Globals.game.ready
	# Set base stuff up
	title_label.text = key.capitalize()
	modulate = Config.RESET_LAYERS[key]["color"]

	currency = Config.RESET_LAYERS[key]["cost"]["currency"]

	# Create buttons
	update_button_count(_get_button_count())

	# Create the total bonuses display
	for mult in Config.RESET_LAYERS[key]["multiplies"]:
		var label = Label.new()
		label.set_meta("mult", mult)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_vbox.add_child(label)

	autobuy_button.toggled.connect(_autobuy_pressed)

	_reload()
