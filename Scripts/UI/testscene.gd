extends Control

var reset_layer = preload("res://Scenes/UI/reset_layer.tscn")

@onready var player = Game.player

## Used to determine the next update frame
var update_prog:float = 0

func _update_score():
	var score = B.new(1)

	for k in Config.RESET_LAYERS:
		if Game.get_stat(k).isLessThanOrEqualTo(0):
			continue
		score.plusEquals(B.new(Game.get_stat(k).absLog10()+1).multiply(pow(2,Game.get_reset_idx(k))))

	Game.set_stat("score", score)

	%Labels/Score.text = "Score: " + str(score)

func _process(delta: float) -> void:

	Game.increase_stat("cash", 10*delta)

	_update_score()

	#$PanelContainer/MarginContainer/VBoxContainer/Label.text = Game.player.cash.to_scientific_notation()
	%Labels/Cash.text = "Cash: " + str(Game.player.cash)

	if Game.get_stat("score").isGreaterThan(Config.MIN_PRESTIGE_SCORE):
		%OpenPrestigeMenu.self_modulate = Color(0,1,0)
		%OpenPrestigeMenu.text = "Prestige - " + str(%PrestigeMenu._get_pp_gain()) + "PP"
	else:
		%OpenPrestigeMenu.self_modulate = Color(1,0,0)
		%OpenPrestigeMenu.text = "Prestige \n(" + str(Config.MIN_PRESTIGE_SCORE) + " score req.)"

	for k in Config.RESET_LAYERS:
		%Labels.get_node(k).text = k.capitalize() + ": " + str(Game.get_stat(k))

func _update_reset_layers() -> void:
	var idx = 0

	for k in Config.RESET_LAYERS:

		var l
		if %ResetLayers.has_node(k):
			l = %ResetLayers.get_node(k)

		if l and l.reset_idx > Game.get_upgrade_count("PP Layers")+2:
			l.queue_free()
			continue
		elif l:
			l.update_button_count(l._get_button_count())
		elif not l and idx <= Game.get_upgrade_count("PP Layers")+2:
			l = reset_layer.instantiate()
			l.name = k
			l.key = k
			l.reset_idx = idx
			%ResetLayers.add_child(l)

		idx += 1

func _reload_reset_layers() -> void:
	var idx = 0

	for child in %ResetLayers.get_children():
		child.queue_free()

	for k in Config.RESET_LAYERS:
		# Create label
		var label = Label.new()
		label.name = k
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.self_modulate = Config.RESET_LAYERS[k]["color"]
		%Labels.add_child(label)

		# Create purchase panel
		var l = reset_layer.instantiate()
		l.name = k
		l.key = k
		l.reset_idx = idx

		%ResetLayers.add_child(l)
		idx += 1

func _ready() -> void:

	if not Game.ready:
		await Game.ready

	_reload_reset_layers()
	_update_reset_layers()

	SignalBus.PrestigeUpgradeBought.connect(_update_reset_layers)

	%OpenPrestigeMenu.pressed.connect(%PrestigeMenu.open)
	%OpenTokenMenu.pressed.connect(%TokenMenu.open)
	%OpenBuyCrateMenu.pressed.connect(%BuyCrateMenu.open)
