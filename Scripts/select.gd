extends Control

@onready var title = $MarginContainer/VBoxContainer/Title

var menu_bob_progress:float

func _process(delta: float) -> void:
	$Clouds.texture.noise.offset.x += delta * 40
#
	#menu_bob_progress += delta
	#menu_bob_progress = fmod(menu_bob_progress, 2*PI)
	#title.position = title.get_meta("start_pos") + Vector2.UP * (4*sin(menu_bob_progress)-20)

func _ready() -> void:
	title.set_meta("start_pos", title.position)
	
