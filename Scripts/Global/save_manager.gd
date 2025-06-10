extends Node
## Manages save data.
##
## Data is kept is separate "slots", and those slots can be modified using
## the functions within this node. Slots are based on index in the save data
## dictionary, and thus can have duplicate names and be made in an
## unlimited amount.

var SAVE_TEMPLATE = {
	"slots": [],
}

var SLOT_TEMPLATE = {
	"name": "Slot",
	"data": {
		"time": 0.0
	},
}

#region JSON Conversion
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


## Converts a JSON-converted dictionary (_to_json) back into a regular dictionary.
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
#endregion

#region Slot management
## Change the slot name at a given index
func change_slot_name(idx:int, new_name:String) -> void:
	var savedata:Dictionary = get_all_save_data()

	if idx >= len(savedata["slots"]):
		printerr("Can't change slot name: No slot found at index " + str(idx) + ".")
		return

	savedata.slots[idx]["name"] = new_name
	_write_to_save(savedata)
	print(savedata)
	return

## Change the slot name at a given index
func new_slot() -> void:
	var savedata:Dictionary = get_all_save_data()
	savedata.slots.append(SLOT_TEMPLATE)
	_write_to_save(savedata)
	print(savedata)
	return

## Delete slot at a passed index. Use with caution!
func delete_slot(idx:int=0) -> void:
	
	var savedata:Dictionary = get_all_save_data()
	
	if idx >= len(savedata["slots"]):
		printerr("Can't change slot name: No slot found at index " + str(idx) + ".")
		return
	
	savedata.slots.pop_at(idx)
	_write_to_save(savedata)

#endregion

#region Save Data
## Writes to the savedata file directly. Use with caution!
## This does not validate the structure of the data passed.
func _write_to_save(savedata:Dictionary):
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(savedata))

## Saves the game to a JSON file. A player data dictionary must be passed.
func save_game(player, slot : int = 0) -> void:
	var savedata = get_all_save_data()
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	print(player)
	print(slot)
	# Ensure game save data structure is valid
	savedata = Globals.main.fill_dict(savedata, SAVE_TEMPLATE, true, false)
	for i in savedata.slots:
		i = Globals.main.fill_dict(i, SLOT_TEMPLATE, true, false)
	print("--")
	
	
	var new_save = _to_json(player)

	savedata.slots[0]["data"] = new_save

	save_file.store_line(JSON.stringify(savedata))
	save_file.close()

	print("Game successfully saved.")

## Returns a dictionary of all save data.
func get_all_save_data() -> Dictionary:
	if not FileAccess.file_exists("user://savegame.save"):
		print_debug("No save data found. Returning template data...")
		return SAVE_TEMPLATE
	
	var json = JSON.new()
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var parse_result = json.parse(save_file.get_as_text())

	if not parse_result == OK:
		printerr("Error parsing save data!")
		print(json.get_error_message())
		return {}
	
	return json.data
#endregion
