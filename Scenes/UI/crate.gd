extends Control

@onready var crate_button = $Crate

@export var float_distance:int = 15
@export var float_speed:float = 1

var float_prog:float = 0

var stress = 0
var max_shake_strength:Vector2 = Vector2(100, 100)
var start_pos:Vector2
var shake_decay:float = 0.02

var current_crate:Dictionary = {}
var health:float = 1

var buy_count:int = 1

func weighted_random_select(weighted_array: Array) -> Dictionary:
	# Calculate total weight
	var total_weight = 0.0
	for item in weighted_array:
		total_weight += item["weight"]
	
	# Pick a random value between 0 and total_weight
	var rand = randf() * total_weight
	
	# Iterate to find which item corresponds to the random value
	var cumulative_weight = 0.0
	for item in weighted_array:
		cumulative_weight += item["weight"]
		if rand <= cumulative_weight:
			return item
	
	# Fallback (should not happen if weights are positive)
	return weighted_array[-1]

func get_damage() -> float:
	return 1.0

func _process(delta: float) -> void:
	
	float_prog = fmod(float_prog + delta, 2*PI/float_speed)
	
	crate_button.position = start_pos
	crate_button.position.y += float_distance*sin(float_prog*float_speed)
	crate_button.position += Vector2(
		randi_range(-max_shake_strength.x*stress, max_shake_strength.x*stress),
		randi_range(-max_shake_strength.y*stress, max_shake_strength.y*stress)
	)

	stress *= pow(shake_decay, delta)

func _open() -> void:
	stress = 0
	crate_button.hide()
	#$GPUParticles2D.position = get_viewport_transform().origin
	#$GPUParticles2D.emitting = true

	var open_count = min(buy_count, Game.get_crate_count(current_crate["id"]))

	# Select rewards
	var rewards = {}
	for x in range(buy_count * open_count):

		var reward = weighted_random_select(current_crate["rewards"])

		if not reward["name"] in rewards:
			rewards[reward["name"]] = {
				"amt": 1,
				"dict": reward
			}
		else:
			rewards[reward["name"]].amt += 1

	# Sort rewards using the crate rewards array order
	var new_rewards = {}
	for val in current_crate["rewards"]:
		if val["name"] in rewards:
			new_rewards[val["name"]] = rewards[val["name"]]
	rewards = new_rewards

	# Load reward display
	for child in $VBoxContainer.get_children():
		child.queue_free()

	var i := 0
	for k in rewards:
		#var reward_disp = $Reward.duplicate()
		#reward_disp.text = str(rewards[k].amt) + " " + k
		#reward_disp.self_modulate = rewards[k].dict.color
		#$VBoxContainer.add_child(reward_disp)
		#reward_disp.show()
		var theta = (2*PI)/len(rewards)*i - PI/2
		var dir = Vector2(cos(theta), sin(theta))
		Game.currency_popup(str(rewards[k].amt) + " " + k, rewards[k].dict.color, null, 3, dir, 1)
		i += 1

	Game.increase_crate_rewards(rewards)
	Game.decrease_crate_count(current_crate["id"], open_count)

	if Game.get_crate_count(current_crate["id"]) <= 0:
		$Label.text = "No crates remaining."
		$Label.modulate = Color(1,0,0)
	else:
		$Label.text = "Open again?"
		$Label.modulate = Color(1,1,1)

	SignalBus.CrateOpened.emit()

func _hit() -> void:

	if Game.get_crate_count(current_crate["id"]) <= 0:
		stress = 0.05
		return

	stress = 0.3
	health -= 1
	if health <= 0:
		_open()

func load_crate(crate:Dictionary={}) -> void:
	current_crate = crate

	if len(crate) <= 0:
		visible = false
		return
	visible = true

	if "health" in crate:
		health = crate["health"]
	else:
		health = 5

	if "img" in crate:
		crate_button.texture_normal = load(crate["img"])
	else:
		crate_button.texture_normal = load("res://Assets/Textures/Crates/crate.png")

	if Game.get_crate_count(current_crate["id"]) <= 0:
		$Label.text = "You do not own this crate."
		$Label.modulate = Color(1,0,0)
	else:
		$Label.text = "Click the crate repeatedly to open it!"
		$Label.modulate = Color(1,1,1)

	# Clear reward display
	for child in $VBoxContainer.get_children():
		child.queue_free()

	$Crate.show()

func _ready() -> void:

	start_pos = crate_button.position
	crate_button.pressed.connect(_hit)

	$Label.pressed.connect(func(): if not $Crate.visible: load_crate(current_crate))

	load_crate() # Load default values
