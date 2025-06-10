extends CenterContainer
## A buy menu for various crates.
## Not all crates wil be bought here, but just some of the basic ones.

func open():
	$PanelContainer/VBoxContainer/UpgradeContainer.open()
	SoundManager.play_audio("res://Assets/Sound/UI SFX/MenuOpen.wav", "SFX")
	show()

func close():
	$PanelContainer/VBoxContainer/UpgradeContainer.close()
	SoundManager.play_audio("res://Assets/Sound/UI SFX/MenuClose.wav", "SFX")
	hide()

func _ready():
	$PanelContainer/Exit.pressed.connect(close)
