extends PanelContainer

signal GatherPressed

var location: String : set = _location_set
var location_data: Dictionary

func _location_set(new: String) -> void:
	
	if not new in Config.gather_locations:
		print_debug("Attempt to set nonexistent location.")
		return
		
	location_data = Config.gather_locations[new]
	location = new
	
	_reload_data()

func _ready() -> void:
	$VBoxContainer/Button.pressed.connect(GatherPressed.emit)

func _process(_delta: float) -> void:
	$VBoxContainer/ProgressBar.value = Globals.game.get_gather_time(location) / location_data.time

func _reload_data() -> void:
	$VBoxContainer/Button.text = location_data.text
	$VBoxContainer/Button.icon = load(location_data.icon)
