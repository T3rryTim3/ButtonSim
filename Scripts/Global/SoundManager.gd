extends Node
## A sound manager for godot projects.
##
## Must be made global to be used.

var current_sounds:Node

func play_audio(path:String,bus:StringName="Master", pitch_scale:float=1) -> void:
	var player = AudioStreamPlayer.new()
	var stream = load(path)

	if stream is not AudioStream:
		printerr("Invalid input passed to play_audio. (" + path + ")")
		return

	for s in current_sounds.get_children():
		if s.stream == stream:
			s.queue_free()
	
	current_sounds.add_child(player)
	player.stream = stream
	player.bus = bus
	player.name = path.get_file()
	player.pitch_scale = pitch_scale
	player.play()
	player.finished.connect(player.queue_free)

# Used for testing
#func _input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#if event.pressed:
			#match event.keycode:
				#KEY_H:
					#play_audio("res://Assets/Sound/UI SFX/CrateOpen.wav")
				#KEY_J:
					#play_audio("res://Assets/Sound/UI SFX/CrateHit.wav")

func _ready():
	current_sounds = Node.new()
	add_child(current_sounds)
