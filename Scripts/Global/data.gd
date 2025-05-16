extends Node

var data = {
	"Stats": {
		"Currencies": [
		]
	},
	"Achievements": {
		
	},
	"Unlocks": {
		
	}
}

## Exports data to a json format.
func to_json(data:Dictionary) -> String:
	return ""	

## Inverse of to_json; Converts a json string into a dictionary of data.
func from_json(json:String) -> Dictionary:
	return {}

#region Stat Management
## Returns the index of the passed stat id if present in the passed array. Returns -1 if not present.
func stat_present(stat:String, arr:Array) -> bool:

	var idx:int = 0

	for k in arr:
		if k is Util.Currency and k.id == stat:
			return idx
		idx += 1

	return -1

## Returns the dataval of a stat, or creates it (set to 0e0) if not already there.
func get_currency(stat:String) -> Util.Currency:

	var idx = stat_present(stat, data["Stats"]["Currencies"])
	if idx >= 0: # If the stat was found
		return data["Stats"]["Currencies"][idx]
	return null

## Gets the bignum of a currency. Returns 1 if not present.
func get_currency_val(stat:String) -> Util.BigNum:
	var curr = get_currency(stat)
	if curr:
		return curr.val
	return Util.BigNum.new(1)

## Gets the value that would be added to a stat
func get_add_val(stat:String, val:Util.BigNum) -> Util.BigNum:
	var add_val = Util.BigNum.new(val.num, val.exp)
	match stat:
		"cash":
			return data["Stats"][stat]
	return add_val

#endregion

#
#func _ready() -> void:
	#print(get_currency("cash").to_scientific_notation())
