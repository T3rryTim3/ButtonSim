extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_F3:
					if visible:
						hide()
					elif not visible:
						# I have no clue if this works or not, 
						# but it should only occur in the editor.
						if OS.has_feature("editor"):
							show()
