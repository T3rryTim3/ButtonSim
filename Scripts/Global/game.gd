extends Node

var player = {}

func get_player_data():
	var s = {
		"time": 0,

		"cash": B.new(),
		"multiplier": B.new(),
		"rebirths": B.new()
	}

	return s

func _ready() -> void:
	player = get_player_data()
