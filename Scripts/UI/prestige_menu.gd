extends CenterContainer

func open():
	if visible:
		close()
		return
	SoundManager.play_audio("res://Assets/Sound/UI SFX/MenuOpen.wav", "SFX")
	$Prestige.show()
	visible = true

func close():
	SoundManager.play_audio("res://Assets/Sound/UI SFX/MenuClose.wav", "SFX")
	$Prestige.hide()
	$Prestige2.hide()
	visible = false

func _open_upgrades():
	$Prestige.hide()
	$Prestige2.open()

func _close_upgrades():
	$Prestige.show()
	$Prestige2.close()

func _prestige() -> void:

	# Wipe stats
	Globals.game.set_stat("cash", B.new(0))
	for k in Config.RESET_LAYERS:
		Globals.game.set_stat(k, B.new(0))

	# Update prestige data
	Globals.game.player.resets.prestige.count.plusEquals(1)
	Globals.game.increase_stat("prestige_points", _get_base_pp_gain())

func _get_base_pp_gain() -> B:
	var num = B.new(0)
	num.plusEquals(Globals.game.get_stat("score"))
	num.powerEquals(2)
	num.minusEquals(100)
	return num

func _get_pp_gain() -> B:
	var num = _get_base_pp_gain()
	num = Globals.game.get_stat_increase("prestige_points", num)
	
	return num

func _prestige_button_pressed():
	if Globals.game.get_stat("score").isGreaterThan(1):
		_prestige()

func _process(_delta: float) -> void:
	if !visible:
		return

	$Prestige/VBoxContainer/Current.text = "You currently have " + str(Globals.game.get_stat("prestige_points")) + " PP."
	$Prestige/VBoxContainer/Gain.text = "If you prestiged now, you would gain " + str(_get_pp_gain()) + " PP."

	if Globals.game.get_stat("score").isGreaterThan(Config.MIN_PRESTIGE_SCORE):
		%PrestigeButton.disabled = false
		%PrestigeButton.text = "Prestige! - " + str(_get_pp_gain()) + " PP"
	else:
		%PrestigeButton.disabled = true
		%PrestigeButton.text = "Minimum " + str(Config.MIN_PRESTIGE_SCORE) + " score to prestige."

	var bonus_display_str = ""
	var bonuses = Config.upgrades["PP Boost"].get_multi.call(Globals.game.get_upgrade_count("PP Boost"))
	var i:int = 0
	for k in bonuses:
		bonus_display_str += k.capitalize() + ": x" + str(bonuses[k])

		# Only add commas before the end
		if i < len(bonuses) - 1:
			bonus_display_str += ", "

		i += 1

	if bonus_display_str:
		%PPBonusesDisplay.text = bonus_display_str
		$Prestige/VBoxContainer/Bonuses.visible = true
	else:
		$Prestige/VBoxContainer/Bonuses.visible = false

func _ready() -> void:
	$Prestige/Exit.pressed.connect(close)
	%PrestigeButton.pressed.connect(_prestige_button_pressed)
	%OpenPrestigeUpgrades.pressed.connect(_open_upgrades)
	%ExitPrestigeUpgrades.pressed.connect(_close_upgrades)
