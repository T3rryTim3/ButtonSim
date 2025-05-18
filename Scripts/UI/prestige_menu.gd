extends CenterContainer

func open():
	show()

func close():
	hide()

func _prestige() -> void:
	Game.set_stat("cash", B.new(0))
	for k in Config.RESET_LAYERS:
		Game.set_stat(k, B.new(0))
	Game.player.resets.prestige.count.plusEquals(1)
	Game.player.resets.prestige.points.plusEquals(_get_pp_gain())

func _get_pp_gain() -> B:
	var num = B.new(0)
	num.plusEquals(Game.get_stat("score"))
	return num

func _prestige_button_pressed():
	_prestige()

func _process(delta: float) -> void:
	if !visible:
		return
	$Prestige/VBoxContainer/Current.text = "You currently have " + str(Game.get_reset("prestige")["points"]) + " PP."
	$Prestige/VBoxContainer/Gain.text = "If you prestiged now, you would gain " + str(_get_pp_gain()) + " PP."

func _ready() -> void:
	$Prestige/Exit.pressed.connect(close)
	%PrestigeButton.pressed.connect(_prestige_button_pressed)
