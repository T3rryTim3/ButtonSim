extends MarginContainer

@onready var scn_crate_select = preload("res://Scenes/UI/crate_select_option.tscn")

var current_progress:float = 0

func _crate_selected(selected:PanelContainer):
	%Crate.load_crate(selected.crate_data)

func _load_crate_selections() -> void:
	for child in %CrateContainer.get_children():
		child.queue_free()

	for crate in Config.crates:
		var scn = scn_crate_select.instantiate()
		%CrateContainer.add_child(scn)
		scn.load_crate(Config.crates[crate])
		scn.clicked.connect(func(): _crate_selected(scn))

func _reload_crate_select_data() -> void:
	for child in %CrateContainer.get_children():
		child.load_crate(child.crate_data)

func _process(delta: float) -> void:
	
	# I have no idea what this is but im scared to delete it
	#if $HSplitContainer.split_offset <= get_viewport_rect().size.x/6:
		#for child in %CrateContainer.get_children():
			#child.show_data = false
	#else:
		#for child in %CrateContainer.get_children():
			#child.show_data = true

	# Update the health display background
	if "health" in %Crate.current_crate:
		var goal = %Crate.health / %Crate.current_crate["health"]
		current_progress = lerpf(current_progress, goal, 0.2)
	else:
		current_progress = 0
	
	$ProgressBar2.value = current_progress


func _ready() -> void:
	_load_crate_selections()
	$HSplitContainer/ScrollContainer/VBoxContainer/ShowStatIndex.pressed.connect($CrateStatIndex.open)
	SignalBus.CrateGained.connect(_reload_crate_select_data)
