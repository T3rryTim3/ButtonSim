extends Node

var multiplier: 
	set(new):
		Globals.game.player.multiplier = new
	get():
		return Globals.game.player.multiplier
