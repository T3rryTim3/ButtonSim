extends CenterContainer

func open():
	show()

func close():
	hide()

func _ready() -> void:
	$Prestige/Exit.pressed.connect(close)
