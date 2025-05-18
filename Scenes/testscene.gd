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
		score.plusEquals(Game.get_stat(k).absLog10()+1)

	Game.set_stat("score", score)

	%Labels/Score.text = "Score: " + str(score)

func _process(delta: float) -> void:

	Game.increase_stat("cash", 10*delta)

	_update_score()

	#$PanelContainer/MarginContainer/VBoxContainer/Label.text = Game.player.cash.to_scientific_notation()
	%Labels/Cash.text = "Cash: " + str(Game.player.cash)

	for k in Config.RESET_LAYERS:
		%Labels.get_node(k).text = k.capitalize() + ": " + str(Game.get_stat(k))

func _ready() -> void:

	if not Game.ready:
		await Game.ready

	for k in Config.RESET_LAYERS:
		# Create label
		var label = Label.new()
		label.name = k
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		%Labels.add_child(label)

		# Create purchase panel
		var l = reset_layer.instantiate()
		l.key = k

		%ResetLayers.add_child(l)

	%OpenPrestigeMenu.pressed.connect(%PrestigeMenu.open)
