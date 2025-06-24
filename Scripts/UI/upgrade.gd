extends PanelContainer
class_name Upgrade
## An upgrade object which uses the Config.Upgrades data to alter the player's stats.
## Crated automatically from the upgrade_container.tscn node.
##
## This node should generally not be created manually. Use UpgradeContainer for this.


@onready var button:Button = $VBoxContainer2/Button

enum DisplayTypes {
	PRESTIGE,
	TOKEN,
	CRATE,
	MASTERY
}

#region Properties
var display:DisplayTypes
var upgrade_id:String
var upgrade_data:Dictionary
var upgrade_count:int
var cost:B
#endregion

## Update the cost of the upgrade based on the upgrade data.
func _update_cost() -> void:
	cost = upgrade_data.get_cost.call(upgrade_count)


## Upgrade the internal amount bought value.
func _update_upgrade_count() -> void:
	upgrade_count = Globals.game.get_upgrade_count(upgrade_id)


## Check if the player's purchase count exceeds the maximum.
func _exceeds_max() -> bool:
	var max_purchase = upgrade_data["get_max"].call()
	return upgrade_count >= max_purchase and max_purchase != -1


## Returns true if the player has enough currency to buy the upgrade.
func _can_buy() -> bool:
	if _exceeds_max(): # Max is -1 if unlimited
		return false
	return !Globals.game.get_stat(upgrade_data["currency"]).isLessThan(cost)


## Load the upgrade data into the display for the upgrade.
func _load_data() -> void:
	_update_upgrade_count()
	_update_cost()

	var max_purchase = upgrade_data["get_max"].call()
	var max_text := str(max_purchase)
	if max_purchase == -1:
		max_text = 'inf'
	
	upgrade_count = Globals.game.get_upgrade_count(upgrade_id)
	
	var count_display = str(upgrade_count) + "/" + max_text

	$VBoxContainer2/HBoxContainer/Title.text = upgrade_data.name
	$VBoxContainer2/HBoxContainer/Purchased.text = count_display
	
	if not _exceeds_max():
		$VBoxContainer2/Desc.text = upgrade_data["get_desc"].call(upgrade_count)
	else:
		$VBoxContainer2/Desc.text = "Max purchases reached."
	
	button.text = "Purchase - " + str(cost) + " " + upgrade_data["currency_name"]


## Update the purchase display depending on whether or not the upgrade can be bought.
func _update() -> void:
	if _can_buy():
		button.modulate = Color(0, 1, 0)
		button.disabled = false
	else:
		button.modulate = Color(1, 0, 0)
		button.disabled = true


## Purchase the upgrade and update where neccessary. Checks for affordability within the function.
func purchase() -> void:
	_update_upgrade_count()
	_update_cost()
	
	if not _can_buy():
		SoundManager.play_audio("res://Assets/Sound/UI SFX/Error1.wav", "SFX")
		return
	
	Globals.game.minus_stat(upgrade_data["currency"], cost)
	Globals.game.increase_upgrade_count(upgrade_id)
	
	if "prestige" in upgrade_data["tags"]:
		SignalBus.PrestigeUpgradeBought.emit()
	
	if "on_buy" in upgrade_data:
		upgrade_data.on_buy.call(Globals.game.get_upgrade_count(upgrade_id))
	
	SoundManager.play_audio("res://Assets/Sound/UI SFX/Upgrade1.wav", "SFX")
	_load_data()


#region Base functions
func _process(_delta: float) -> void:
	_update()


func _ready() -> void:
	button.pressed.connect(purchase)
	_load_data()
	match display:
		DisplayTypes.PRESTIGE:
			self_modulate = Color("a057ff")
			$VBoxContainer2/HBoxContainer/Title.add_theme_color_override("font_color", Color("d428ff"))
			$VBoxContainer2/HBoxContainer/Purchased.add_theme_color_override("font_color", Color("d428ff"))
		DisplayTypes.TOKEN:
			self_modulate = Color("fffb10")
			$VBoxContainer2/HBoxContainer/Title.add_theme_color_override("font_color", Color("fffb29"))
			$VBoxContainer2/HBoxContainer/Purchased.add_theme_color_override("font_color", Color("fffb29"))
		DisplayTypes.CRATE:
			self_modulate = Color("ffbd24")
			$VBoxContainer2/HBoxContainer/Title.add_theme_color_override("font_color", Color("2c1d02"))
			$VBoxContainer2/HBoxContainer/Purchased.add_theme_color_override("font_color", Color("2c1d02"))
		DisplayTypes.MASTERY:
			self_modulate = Color("81a7e3")
			$VBoxContainer2/HBoxContainer/Title.add_theme_color_override("font_color", Color("b8bcff"))
			$VBoxContainer2/HBoxContainer/Purchased.add_theme_color_override("font_color", Color("966ffe"))
#endregion
