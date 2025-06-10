extends Button

var reset_layer:ResetLayer
var button_idx:int
var key:String
var currency:String

var gain:B
var cost:B

var token_ready:bool = false
var token_time_remaining:float

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
	return Globals.game.get_stat(currency).exceeds(cost)

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

func _reset_token_time() -> void:
	token_time_remaining = randf_range(Config.TOKEN_DELAY_INTERVAL[0], Config.TOKEN_DELAY_INTERVAL[1])

## When a button is pressed to purchase the reset layer. Bulk determines the number of times bought
func buy(bulk:int=1, auto:bool=false):

	if bulk <= 0:
		return

	if not auto:
		Globals.game.currency_popup("+" + str(gain) + " " + key.capitalize(), Config.RESET_LAYERS[key]["color"])
		if token_ready:
			
			var gain_amt = randi_range(Config.TOKEN_GAIN_INTERVAL[0],Config.TOKEN_GAIN_INTERVAL[1])
			
			token_ready = false
			_reset_token_time()
			$TokenOutline.visible = false
			
			Globals.game.currency_popup("+" + str(gain_amt) + " Token", Color.YELLOW)
			Globals.game.increase_stat("tokens", gain_amt)
			SoundManager.play_audio("res://Assets/Sound/UI SFX/Token2.wav", "SFX")
			
		else: # Avoid both sounds playing at once (It sounds weird)
			SoundManager.play_audio("res://Assets/Sound/UI SFX/StatBuy2.wav", "SFX", randf_range(0.4,1.1))

	for i in range(bulk):
		if not can_buy():
			return

		if Globals.game.get_upgrade_count("PP Free Cost") <= Globals.game.get_reset_idx(key):
			Globals.game.set_stat(currency, Globals.game.player[currency].minus(cost))
			for reset in Config.RESET_LAYERS[key]["reset"]:
				Globals.game.zero_stat(reset)

		Globals.game.increase_stat(key, gain)
		bought += 1

func update_stats() -> void: # Updates internal cost and gain values
	button_cost = _get_button_cost(button_idx)
	button_gain = _get_button_gain(button_idx)
	cost = button_cost
	gain = button_gain

## Update a button's data
func update():

	text = "Buy " + str(gain) + " " + key + " - " + str(cost) + " " + currency

	disabled = not Globals.game.get_stat(currency).exceeds(cost)

func _process(delta: float) -> void:
	#current_update_cooldown += delta
	#if current_update_cooldown > update_cooldown:
		#current_update_cooldown = 0
	gain = Globals.game.get_stat_increase(key, button_gain)

	## Hold-to-buy
	if buying:
		if not disabled:
			var to_buy = buy_time / Globals.game.get_stat("buy_speed")
			buy_time += delta
			buy(max(0, to_buy - bought))

		if (!button_pressed) and not disabled:
			buying = false

	if disabled or not token_ready:
		$TokenOutline.visible = false
	elif not disabled and token_ready:
		$TokenOutline.visible = true

	token_time_remaining = max(0, token_time_remaining - delta)
	if token_time_remaining <= 0 and not token_ready:
		token_ready = true
		# Set different time for the token to expire
		token_time_remaining = randf_range(Config.TOKEN_EXPIRE_INTERVAL[0],Config.TOKEN_EXPIRE_INTERVAL[1])
	elif token_time_remaining <= 0 and token_ready:
		token_ready = false
		_reset_token_time()

	update()

func _ready():
	currency = Config.RESET_LAYERS[key]["cost"]["currency"]
	init_cost = Config.RESET_LAYERS[key]["cost"]["init"]
	init_gain = Config.RESET_LAYERS[key]["init_val"]

	button_down.connect(func(): buy_time = 0; buying = true; bought = 0)

	$TokenOutline.visible = false

	update_stats()
	_reset_token_time()
