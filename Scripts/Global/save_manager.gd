extends Node

## Convert a value to json accounting for bignums or other data types as
## they are added.
func _to_json(d:Variant) -> Variant:
	var new

	if d is Dictionary:
		new = {}
		for k in d:
			new[k] = _to_json(d[k])
	elif d is Array:
		new = []
		for i in d:
			new.append(_to_json(i))
	elif d is B:
		new = d.to_json()
	else:
		return d

	return new


## Converts a JSON-converted dictionary back into a regular dictionary.
func _from_json(d:Variant) -> Variant:
	var new

	if d is Dictionary:
		if not "_type" in d:
			new = {}
			for k in d:
				new[k] = _from_json(d[k])
		elif d._type == "bignum":
			new = B.from_json(d)
	
	elif d is Array:
		new = []
		for i in d:
			new.append(_from_json(i))
	else:
		return d

	return new


## Saves the game to a JSON file. A player data dictionary must be passed.
func save_game(player, slot : int = 0) -> void:
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	# FIXME Doesnt load data before altering it.
	var savedata = {
		"slots": [
			{
				"name": "Default",
				"data": {}
			}
		]
	}
	
	var new_save = _to_json(player)

	savedata.slots[0]["data"] = new_save

	save_file.store_line(JSON.stringify(savedata))
	save_file.close()

	print("Game successfully saved.")

## Returns a dictionary of all save data.
func get_all_save_data() -> Dictionary:
	if not FileAccess.file_exists("user://savegame.save"):
		print("No save data found.")
		return {}
	
	var json = JSON.new()
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var parse_result = json.parse(save_file.get_as_text())

	if not parse_result == OK:
		printerr("Error parsing save data!")
		print(json.get_error_message())
		return {}
	
	return json.data
