extends Control

@onready var input_field : LineEdit = $MarginContainer/VBoxContainer/LineEdit
@onready var submit_button : Button = $MarginContainer/VBoxContainer/Button
@onready var used_codes : VBoxContainer = $MarginContainer/VBoxContainer/UsedCodes/ScrollContainer/VBoxContainer

func _ready() -> void:
	
	submit_button.pressed.connect(_enter_code)
	input_field.text_submitted.connect(func(_x): _enter_code())
	_reload_used_codes()

func _reload_used_codes() -> void:
	
	for child in used_codes.get_children():
		if child.name != "Title": child.queue_free()
	
	for code in Globals.game.get_used_codes():
		var new = Label.new()
		new.text = code + " - " + Config.codes[code]["reward_text"]
		new.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		used_codes.add_child(new)

func _enter_code() -> void:
	
	var code = input_field.text
	
	if Globals.game.has_used_code(code):
		Globals.game.currency_popup("Code already used!", Color.RED) ; return
	elif code not in Config.codes:
		Globals.game.currency_popup("Invalid Code!", Color.RED) ; return
	
	Globals.game.use_code(code)
	Globals.game.currency_popup(Config.codes[code]["reward_text"], Color.TURQUOISE)
	
	input_field.text = ""
	
	_reload_used_codes()
