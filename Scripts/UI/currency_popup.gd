extends Control

var anim_time:float = 0.5
var current_anim_time:float = 0
var anim_y_dist:float = 30

var offset:Vector2

var playing:bool

var dir:Vector2

func play() -> void:
	current_anim_time = 0
	playing = true

func set_text(text:String):
	$Label.text = text

func set_color(color:Color):
	$Label.add_theme_color_override("font_color", color)

func set_label_offset(new_offset:Vector2i):
	offset = new_offset

func _process(delta:float) -> void:
	if playing:
		current_anim_time += delta
		modulate.a = sin(current_anim_time*PI/(anim_time))
		$Label.position += dir * delta*(anim_y_dist/anim_time)
		if current_anim_time >= anim_time:
			queue_free()

func _ready() -> void:
	modulate.a = 0
	z_index = 10
