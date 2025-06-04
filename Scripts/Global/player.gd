extends Node

class Player:
	var currencies:Dictionary[String, Util.BigNum] = {
		"cash": Util.BigNum.new()
	}
	var upgrades:Dictionary[String, Dictionary] = {
		"": {}
	}
	
	func _init() -> void:
		pass
