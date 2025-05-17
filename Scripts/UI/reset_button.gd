extends Button

var reset_layer:ResetLayer
var button_idx:int
var key:String
var currency:String

var gain:B
var cost:B

var update_cooldown:float = 2
var current_update_cooldown:float = 0

## Returns the hold-buy speed
func _get_buy_speed() -> float:
	return 1

func _get_button_cost(button_index:int):

	var c = B.new(Config.RESET_LAYERS[key]["cost"]["init"])
	c = c.multiply(B.new(Config.RESET_LAYERS[key]["cost"]["scale"]).power(button_index))

	if "exp_growth" in Config.RESET_LAYERS[key]["cost"]:
		c = c.power(Config.RESET_LAYERS[key]["cost"]["exp_growth"] * button_index+1)

	return c

func _get_button_gain(button_index:int):

	var g = B.new(Config.RESET_LAYERS[key]["init_val"])
	g.multiplyEquals(B.new(Config.RESET_LAYERS[key]["scale_val"]).power(button_index))

	if "exp_growth" in Config.RESET_LAYERS[key]["cost"]:
		g = g.power(Config.RESET_LAYERS[key]["cost"]["exp_growth"] * button_index+1)

	g = Game.get_stat_increase(key, g)

	return g

## When a button is pressed to purchase the reset layer.
func _button_pressed():
	
	var cost = _get_button_cost(button_idx)
	var gain = _get_button_gain(button_idx)

	if not Game.get_stat(currency).exceeds(cost):
		return

	Game.set_stat(currency, Game.player[currency].minus(cost))
	for reset in Config.RESET_LAYERS[key]["reset"]:
		Game.zero_stat(reset)

	Game.increase_stat(key, gain)

func update_stats() -> void: # Updates internal cost and gain values
	cost = _get_button_cost(button_idx)
	gain = _get_button_gain(button_idx)

## Update a button's data
func update():

	text = "Buy " + str(gain) + " " + key + " - " + str(cost) + " " + currency

	disabled = not Game.get_stat(currency).exceeds(cost)

func _process(delta: float) -> void:
	update_stats()
	update()

func _ready():
	currency = Config.RESET_LAYERS[key]["cost"]["currency"]
