extends Control

@onready var tree:Tree = $PanelContainer/VBoxContainer/AllCratesTree

var root:TreeItem

const round_amt:int = 3

## Loads the "All tree" tree with all of the crate and reward data.
func load_tree() -> void:
	tree.columns = 4
	root = tree.create_item()
	tree.hide_root = true
	tree.set_column_title(0, "Name")
	tree.set_column_title(1, "Owned")
	tree.set_column_title(2, "Base Multi")
	tree.set_column_title(3, "Total Multi")

	for crate_name in Config.crates:

		var crate = Config.crates[crate_name]
		var crate_item = tree.create_item(root)
		var reward_total_weight := 0.0

		crate_item.set_text(0, crate.name)
		crate_item.set_selectable(0, false)

		for reward in crate.rewards:
			reward_total_weight += reward.weight

		for reward in crate.rewards:

			var reward_item = tree.create_item(crate_item)
	
			# Calculate chance
			var chance:float = (reward.weight / reward_total_weight) * 100
			
			# Round to n digits
			chance *= pow(10, round_amt)
			chance = roundf(chance)
			chance /= pow(10, round_amt)
			
			# Set data displayed
			reward_item.set_text(0, reward.name + " - " + str(chance) + "%")
			reward_item.set_text(1, "0 Owned")
	
			# Set defaults
			var text = ""
			for multi in reward.multi:
				text += ", " + multi.capitalize() + " x" + str(reward.multi[multi]+1)
			text = text.lstrip(", ")
			reward_item.set_text(2, text)
	
			for x in range(4):
				reward_item.set_text_alignment(x, HORIZONTAL_ALIGNMENT_CENTER)
				reward_item.set_autowrap_mode(x, TextServer.AUTOWRAP_WORD)
				reward_item.set_selectable(x, false)
				reward_item.set_custom_color(x, reward.color)
				reward_item.set_custom_bg_color(x, Color(0.2,0.2,0.2), true)

			reward_item.set_meta("reward_data", reward)

func update_tree() -> void:
	for crate in root.get_children():
		for reward_item in crate.get_children():
			if reward_item.has_meta("reward_data"):
				# Show current multiplier
				var reward = reward_item.get_meta("reward_data")
				var reward_count = Globals.game.get_crate_rewards()[reward["name"]]
				var text = ""
				
				if reward_count > 0:
					for multi in reward.multi:
						text += ", " + multi.capitalize() + " x" + str(reward.multi[multi] * reward_count + 1)
					text = text.lstrip(", ")
				else:
					text = "N/A"
				
				reward_item.set_text(3, text)
				reward_item.set_text(1, str(reward_count) + " Owned")

func open() -> void:
	update_tree()
	show()	

func _ready():
	if not Globals.game.ready:
		await Globals.game.ready
	load_tree()

	$PanelContainer/VBoxContainer/ExitButton.pressed.connect(hide)
