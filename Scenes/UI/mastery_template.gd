extends PanelContainer

signal PrestigeClicked

@onready var prestige_button = $VBoxContainer/HBoxContainer2/PrestigeButton

func update(key:String) -> void:
	
		var mastery = Globals.game.get_mastery(key)
		
		var prog:float
		var multi:B
		var current:B
		var prestige:B
		
		if mastery:
			prog = Globals.game.get_mastery_percent(key)
			multi = mastery.multi
			current = mastery.current
			prestige = mastery.prestige
		
		else:
			prog = 0
			multi = B.new(1)
			current = B.new(0)
			prestige = B.new(0)
	
		$VBoxContainer/ProgressBar.value = prog
		$VBoxContainer/HBoxContainer2/current.text = "Current Multiplier: " + str(multi)
		
		# Show the P-X display only if the player has more than zero prestiges
		if prestige.exceeds(1):
			$VBoxContainer/name.text = "P-" + str(prestige).trim_suffix(".0") + " " + key.capitalize() + " - lvl. " + str(current)
		else:
			$VBoxContainer/name.text = key.capitalize() + " - lvl. " + str(current)
		
		prestige_button.disabled = not Globals.game.can_prestige_mastery(key)

func _ready() -> void:
	prestige_button.pressed.connect(PrestigeClicked.emit)
