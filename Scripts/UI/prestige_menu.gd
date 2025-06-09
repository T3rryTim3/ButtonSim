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
	Game.set_stat("cash", B.new(0))
	for k in Config.RESET_LAYERS:
		Game.set_stat(k, B.new(0))

	# Update prestige data
	Game.player.resets.prestige.count.plusEquals(1)
	Game.increase_stat("prestige_points", _get_pp_gain())

func _get_pp_gain() -> B:
	var num = B.new(0)
	num.plusEquals(Game.get_stat("score"))
	num.powerEquals(2)
	num.minusEquals(100)
	#num.multiplyEquals(Game.get_upgrade_count("PP PP Multi") + 1)
	#num.multiplyEquals(Game.get_upgrade_effect("Token PP Multi"))
	#num = Game._get_crate_reward_multi(num, "prestige_points")
	num = Game.get_stat_increase("prestige_points", num)
	
	return num

func _prestige_button_pressed():
	if Game.get_stat("score").isGreaterThan(1):
		_prestige()

func _process(_delta: float) -> void:
	if !visible:
		return

	$Prestige/VBoxContainer/Current.text = "You currently have " + str(Game.get_stat("prestige_points")) + " PP."
	$Prestige/VBoxContainer/Gain.text = "If you prestiged now, you would gain " + str(_get_pp_gain()) + " PP."

	if Game.get_stat("score").isGreaterThan(Config.MIN_PRESTIGE_SCORE):
		%PrestigeButton.disabled = false
		%PrestigeButton.text = "Prestige! - " + str(_get_pp_gain()) + " PP"
	else:
		%PrestigeButton.disabled = true
		%PrestigeButton.text = "Minimum " + str(Config.MIN_PRESTIGE_SCORE) + " score to prestige."

	var bonus_display_str = ""
	var bonuses = Config.upgrades["PP Boost"].get_multi.call(Game.get_upgrade_count("PP Boost"))
	var i:int = 0
	for k in bonuses:
		bonus_display_str += k.capitalize() + ": x" + str(Game.get_prestige_bonuses()[k])

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
