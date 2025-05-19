extends Button

var reset_layer:ResetLayer
var button_idx:int
var key:String
var currency:String

var gain:B
var cost:B

var update_cooldown:float = 2
var current_update_cooldown:float = 0

var init_cost:float
var init_gain:float
var button_cost:B ## Cost of the button after multiplying by index
var button_gain:B ## Gain of the button after muiltiplying by index

var buying:bool = false
var bought:int = 0 ## Amount of times bought
var buy_time:float = 0.0 ## Current time spent buying. Used to calculate buy amounts

## Returns the hold-buy speed
func _get_buy_speed() -> float:
	return 1

func can_buy() -> bool:
	update_stats()
	return Game.get_stat(currency).exceeds(cost)

func _get_button_cost(button_index:int):

	var c = B.new(init_cost)
	c = c.multiply(B.new(Config.RESET_LAYERS[key]["cost"]["scale"]).power(button_index))

	if "exp_growth" in Config.RESET_LAYERS[key]["cost"]:
		c = c.power(Config.RESET_LAYERS[key]["cost"]["exp_growth"] * button_index+1)

	return c

func _get_button_gain(button_index:int):

	var g = B.new(init_gain)
	g.multiplyEquals(B.new(Config.RESET_LAYERS[key]["scale_val"]).power(button_index))

	if "exp_growth" in Config.RESET_LAYERS[key]:
		g = g.power(Config.RESET_LAYERS[key]["exp_growth"] * button_index+1)

	return g

## When a button is pressed to purchase the reset layer. Bulk determines the number of times bought
func buy(bulk:int=1):

	if bulk <= 0:
		return

	for i in range(bulk):
		if not can_buy():
			return

		if Game.get_upgrade_count("PP Free Cost") <= Game.get_reset_idx(key):
			Game.set_stat(currency, Game.player[currency].minus(cost))
			for reset in Config.RESET_LAYERS[key]["reset"]:
				Game.zero_stat(reset)

		Game.increase_stat(key, gain)
		bought += 1

func update_stats() -> void: # Updates internal cost and gain values
	button_cost = _get_button_cost(button_idx)
	button_gain = _get_button_gain(button_idx)
	cost = button_cost
	gain = button_gain

## Update a button's data
func update():

	text = "Buy " + str(gain) + " " + key + " - " + str(cost) + " " + currency

	disabled = not Game.get_stat(currency).exceeds(cost)

func _process(delta: float) -> void:
	#current_update_cooldown += delta
	#if current_update_cooldown > update_cooldown:
		#current_update_cooldown = 0
	gain = Game.get_stat_increase(key, button_gain)

	## Hold-to-buy
	if buying:
		if not disabled:
			var to_buy = buy_time / Game.get_stat("buy_speed")
			buy_time += delta
			buy(max(0, to_buy - bought))

		if (!button_pressed) and not disabled:
			buying = false

	update()

func _ready():
	currency = Config.RESET_LAYERS[key]["cost"]["currency"]
	init_cost = Config.RESET_LAYERS[key]["cost"]["init"]
	init_gain = Config.RESET_LAYERS[key]["init_val"]

	button_down.connect(func(): buy_time = 0; buying = true; bought = 0)

	update_stats()
