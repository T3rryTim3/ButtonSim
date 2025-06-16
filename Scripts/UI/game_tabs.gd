extends TabContainer
## Script attatched to the main TabContainer of the game.
## Manages what is or isn't shown through metadata.


func _update_tabs() -> void:
	for i in range(get_tab_count()):
		var tab = get_tab_control(i)
		
		if tab is not GameTab:
			continue

		if tab.unlock_required:
			set_tab_hidden(i, not Config.has_unlock(tab.unlock))


func _process(delta: float) -> void:
	_update_tabs()


func _ready() -> void:
	pass
