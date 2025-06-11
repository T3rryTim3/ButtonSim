extends PanelContainer

@onready var stat_option = $VBoxContainer/StatOption
@onready var line_edit = $VBoxContainer/LineEdit

var game : Control

func _load_options() -> void:
	stat_option.clear()
	for stat in game.player:
		if game.player[stat] is B:
			stat_option.add_item(stat)


func _ready() -> void:
	
	if not Globals.game.is_node_ready():
		await Globals.game.ready
	game = Globals.game
	
	_load_options()


func _set_stat(input, stat_name):
	if input == "0":
		game.set_stat(stat_name, B.new(0))
	
	elif int(input) == 0:
		line_edit.text = ""
		return
	
	elif len(input.split("e")) == 2:
		
		var split = input.split("e")
		
		if int(split[0]) == 0 or int(split[1]) == 0:
			line_edit.text = ""
			return
		
		var num = B.new(int(split[0]), int(split[1]))
		game.set_stat(stat_name, num)
	
	elif int(input) != 0:
		game.set_stat(stat_name, B.new(int(input)))


func _on_button_pressed() -> void:
	var input:String = line_edit.text
	var stat_name = stat_option.get_item_text(stat_option.selected)
	_set_stat(input, stat_name)


func _on_set_all_pressed() -> void:
	var input:String = line_edit.text
	for stat in game.player:
		if game.player[stat] is B:
			_set_stat(input, stat)
