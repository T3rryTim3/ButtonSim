extends Node
class_name GameTab
## Base script for nodes under the main game tab container.
## See game_tabs.gd for how it is used.

@export var unlock_required:bool = false
@export var unlock:Config.Unlocks
