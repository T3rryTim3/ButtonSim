extends PanelContainer
class_name Upgrade

@onready var button:Button = $VBoxContainer2/Button

enum DisplayTypes {
	PRESTIGE,
	TOKEN
}

var display:DisplayTypes

var upgrade_id:String
var upgrade_data:Dictionary
var upgrade_count:int
var cost:B

func _update_cost() -> void:
	cost = upgrade_data.get_cost.call(upgrade_count)

func _update_upgrade_count() -> void:
	upgrade_count = Game.get_upgrade_count(upgrade_id)

func _can_buy() -> bool:
	if upgrade_count >= upgrade_data["get_max"].call():
		return false
	return !upgrade_data["get_player_currency"].call().isLessThan(cost)

func _load_data() -> void:

	_update_upgrade_count()
	_update_cost()

	$VBoxContainer2/HBoxContainer/Title.text = upgrade_data.name
	$VBoxContainer2/HBoxContainer/Purchased.text = str(Game.get_upgrade_count(upgrade_id)) + "/" + str(upgrade_data["get_max"].call())
	if upgrade_count < upgrade_data["get_max"].call():
		$VBoxContainer2/Desc.text = upgrade_data["get_desc"].call(upgrade_count)
	else:
		$VBoxContainer2/Desc.text = "Max purchases reached."
	button.text = "Purchase - " + str(cost) + " " + upgrade_data["currency_name"]

func _update() -> void:
	if _can_buy():
		button.modulate = Color(0, 1, 0)
		button.disabled = false
	else:
		button.modulate = Color(1, 0, 0)
		button.disabled = true

func _process(delta: float) -> void:
	_update()

func purchase() -> void:
	_update_upgrade_count()
	_update_cost()

	if not _can_buy():
		return

	upgrade_data["spend_currency"].call(cost)
	Game.increase_upgrade_count(upgrade_id)

	if "prestige" in upgrade_data["tags"]:
		SignalBus.PrestigeUpgradeBought.emit()

	_load_data()

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
