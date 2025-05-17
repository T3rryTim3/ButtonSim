extends CenterContainer

func open():
	show()

func close():
	hide()

func _prestige() -> void:
	pass

func _ready() -> void:
	$Prestige/Exit.pressed.connect(close)
