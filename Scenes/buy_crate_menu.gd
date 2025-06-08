extends CenterContainer
## A buy menu for various crates.
## Not all crates wil be bought here, but just some of the basic ones.

func open():
	$PanelContainer/VBoxContainer/UpgradeContainer.open()
	show()

func close():
	$PanelContainer/VBoxContainer/UpgradeContainer.close()
	hide()

func _ready():
	$PanelContainer/Exit.pressed.connect(close)
