extends Control


## Gets the player's current rank.
func get_rank() -> int:
	return Globals.game.get_rank()


## Gets the dictionary data of a passed rank key. Pulled from Config.gd
func get_rank_data(key) -> Dictionary:
	return Globals.game.get_rank_data(key)

#region UI
## Update the rank menu display
func _update_rank_data() -> void:

	var next_rank = get_rank() + 1
	var next_rank_data = get_rank_data(next_rank)
	var progress = next_rank_data.requirement.get_progress.call()

	%RankUnlockDisplay.text = "Next rank will unlock: " + next_rank_data.unlock
	%RankReqDisplay.text = "Req. " + next_rank_data.requirement.text + " (" + str(int(progress*100)) + "%)"


	if progress >= 1:
		%RankReqDisplay.add_theme_color_override("font_color", Color(0,1,0))
		%RankUpButton.self_modulate = Color(.2,1,.2)
		$Gradient.self_modulate = Color(.2,1,.2) 
	else:
		%RankReqDisplay.add_theme_color_override("font_color", Color(1,0,0))
		%RankUpButton.self_modulate = Color(1,0,0)
		$Gradient.self_modulate = Color(1,0,0)
#endregion

#region Ranking
## Increases the rank of the player and resets/unlocks as needed.
func _rank_up():

	var next_rank = get_rank() + 1
	var next_rank_data = get_rank_data(next_rank)
	var progress = next_rank_data.requirement.get_progress.call()
	
	if progress < 1:
		return
	
	Globals.game.wipe_reset_layers()
	Globals.game.wipe_crates_by_tag("rank")
	Globals.game.wipe_upgrades_by_tag("rank")
	Globals.game.zero_stat("prestige_points")
	Globals.game.zero_stat("tokens")
	
	_update_rank_data()
	
	print("Done.")

#endregion

func _ready() -> void:
	SignalBus.TabSelected.connect(func(new): if new == self: _update_rank_data())
	%RankUpButton.pressed.connect(_rank_up)
