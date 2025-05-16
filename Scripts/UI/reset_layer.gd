extends PanelContainer

@onready var button_container:VBoxContainer = $ScrollContainer/VBoxContainer/Buttons

var reset_key:String

func _reload() -> void:
	pass

func _ready() -> void:
	# Create buttons
	for x in range(20):
		var button = Button.new()
		
		var currency = Config.RESET_LAYERS[reset_key]["cost"]["currency"]
		var cost = B.new(Config.RESET_LAYERS[reset_key]["cost"]["init"] * pow(Config.RESET_LAYERS[reset_key]["cost"]["scale"], x))
		var gain = B.new(Config.RESET_LAYERS[reset_key]["init_val"] * pow(Config.RESET_LAYERS[reset_key]["scale_val"], x))
		
		button.text = "Buy " + str(gain.to_scientific_notation()) + " " + reset_key + " - " + str(cost.to_scientific_notation()) + " " + currency
		
		# Button purchasing
		button.pressed.connect(
			func():

				# Checreset_key if req met
				if not Game.player[currency].exceeds(cost):
					return

				# Pay cost
				Game.player[currency] = Game.player[currency].subtract(cost)
				for reset in Config.RESET_LAYERS[reset_key]["reset"]:
					Game.player[reset] = B.new(0)

				_increase_stat(reset_key, gain)
		)
		button.mouse_entered.connect(
			func():
				gain = B.new(Config.RESET_LAYERS[reset_key]["init_val"] * pow(Config.RESET_LAYERS[reset_key]["scale_val"], x))
				gain = _get_stat_increase(reset_key, gain)
				button.text = "Buy " + str(gain.to_scientific_notation()) + " " + reset_key + " - " + str(cost.to_scientific_notation()) + " " + currency
		)

		l.get_node("ScrollContainer/VBoxContainer/Buttons").add_child(button)
