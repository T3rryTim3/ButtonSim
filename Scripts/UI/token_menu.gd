extends CenterContainer

func open():
	if visible:
		close()
		return
	SoundManager.play_audio("res://Assets/Sound/UI SFX/MenuOpen.wav", "SFX")
	show()

func close():
	SoundManager.play_audio("res://Assets/Sound/UI SFX/MenuClose.wav", "SFX")
	hide()

func _ready():
	$PanelContainer/Exit.pressed.connect(close)
