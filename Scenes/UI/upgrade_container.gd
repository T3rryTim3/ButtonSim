extends ScrollContainer
class_name UpgradeContainer
## Holds upgrades within a vboxcontainer to be purchased.
## All visual properties and function are done automatically.
##
## upgrade_tags must be set in order to load upgrades. A placeholder will be
## loaded if not set.

#region Node refs
@onready var upgrade_container:VBoxContainer = $Upgrades
#endregion

#region Exports
## An array of tags which represent all upgrades that can be bought.
## Defined individually within Config.Upgrades
@export var upgrade_tags:Array[String]

## A corresponding array to UpgradeTags which hold the display data for the upgrades.
## The enums are defined within the Upgrade scene, and must be changed there.
@export var display_types:Array[Upgrade.DisplayTypes]
#endregion

#region Public functions
## Open the menu and load the upgrade data.
func open():
	_load_upgrades()
	visible = true


## Hides the menu.
## Done seperately incase other implementations are needed during close.
func close():
	visible = false
#endregion

#region Internal functions
## Load all of the upgrade data from upgrade_tags.
## This deletes all nodes that are currently inside of the VBoxContainer.
func _load_upgrades() -> void:
	for tag in range(len(upgrade_tags)):
		var upgrades = Game.get_upgrades_by_tag(upgrade_tags[tag])

		# Clear placeholders / previously loaded upgrades
		for child in upgrade_container.get_children():
			child.queue_free() 

		for k in upgrades:
			var button:Upgrade = Game.scn_upgrade.instantiate()
			button.display = display_types[tag]
			button.upgrade_id = k
			button.upgrade_data = upgrades[k]
			upgrade_container.add_child(button)
#endregion

func _ready() -> void:
	if not Game.ready:
		await Game.ready
	_load_upgrades()
