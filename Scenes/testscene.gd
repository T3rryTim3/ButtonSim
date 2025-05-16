extends Control

var reset_layer = preload("res://Scenes/UI/reset_layer.tscn")

@onready var player = Game.player

## Used to determine the next update frame
var update_prog:float = 0

## Get the amount that a stat would be increased by accounting for multipliers.
func _get_stat_increase(key:String, val:B):

	if key not in Game.player:
		print_debug("Warning: Key not found for increase.")

	val = val.multiply(_get_reset_multi(key))
	return val

## Increase a stat accounting for multipliers. The stat is assumed to be a direct key of player
func _increase_stat(key:String, val:B):

	if key not in Game.player:
		print_debug("Warning: Key not found for increase.")

	player[key] = player[key].add(_get_stat_increase(key, val))

func _get_reset_multi(key:String) -> B:
	var mul = B.new(1)

	for k in Config.RESET_LAYERS:
		if key not in Config.RESET_LAYERS[k]["multiplies"]:
			continue
		var val = Game.player[k].multiply(B.new(Config.RESET_LAYERS[k]["multiplies"][key]))
		mul = mul.multiply(B.new(1).add(val))

	return mul

func _process(delta: float) -> void:
	
	var cash_multi = B.new(10)

	_increase_stat("cash", cash_multi.multiply(B.new(delta)))

	#$PanelContainer/MarginContainer/VBoxContainer/Label.text = Game.player.cash.to_scientific_notation()
	%Labels/Cash.text = "Cash: " + Game.player.cash.to_suffix_notation()

	for k in Config.RESET_LAYERS:
		%Labels.get_node(k).text = k.capitalize() + ": " + Game.player[k].to_suffix_notation()

func _ready() -> void:
	
	for k in Config.RESET_LAYERS:
		# Create label
		var label = Label.new()
		label.name = k
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		%Labels.add_child(label)

		# Create purchase panel
		var l = reset_layer.instantiate()
		l.get_node("ScrollContainer/VBoxContainer").get_node("Label").text = k.capitalize()

		l.modulate = Config.RESET_LAYERS[k]["color"]

		# Create buttons
		for x in range(20):
			var button = Button.new()
			
			var currency = Config.RESET_LAYERS[k]["cost"]["currency"]
			var cost = B.new(Config.RESET_LAYERS[k]["cost"]["init"] * pow(Config.RESET_LAYERS[k]["cost"]["scale"], x))
			var gain = B.new(Config.RESET_LAYERS[k]["init_val"] * pow(Config.RESET_LAYERS[k]["scale_val"], x))
			
			button.text = "Buy " + str(gain.to_scientific_notation()) + " " + k + " - " + str(cost.to_scientific_notation()) + " " + currency
			
			# Button purchasing
			button.pressed.connect(
				func():

					# Check if req met
					if not Game.player[currency].exceeds(cost):
						return

					# Pay cost
					Game.player[currency] = Game.player[currency].subtract(cost)
					for reset in Config.RESET_LAYERS[k]["reset"]:
						Game.player[reset] = B.new(0)

					_increase_stat(k, gain)
			)
			button.mouse_entered.connect(
				func():
					gain = B.new(Config.RESET_LAYERS[k]["init_val"] * pow(Config.RESET_LAYERS[k]["scale_val"], x))
					gain = _get_stat_increase(k, gain)
					button.text = "Buy " + str(gain.to_scientific_notation()) + " " + k + " - " + str(cost.to_scientific_notation()) + " " + currency
			)

			l.get_node("ScrollContainer/VBoxContainer/Buttons").add_child(button)
			
		$PanelContainer/HSplitContainer/MarginContainer/ScrollContainer/ResetLayers.add_child(l)
