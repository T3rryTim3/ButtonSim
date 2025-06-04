extends Node

var base_suffixes = [
	"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No",       # 0–10
	"Dc", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", # 11–20
	"Vg", "Uvg", "Dvg", "Tvg", "Qavg", "Qivg", "Sxvg", "Spvg", "Ocvg", "Novg", # 21–30
	"Tg", "Utg", "Dtg", "Ttg", "Qatg", "Qitg", "Sxtg", "Sptg", "Octg", "Notg", # 31–40
	"Qg", "Uqg", "Dqg", "Tqg", "Qaqg", "Qiqg", "Sxqg", "Spqg", "Ocqg", "Noqg", # 41–50
	"Sg", "Usg", "Dsg", "Tsg", "Qasg", "Qisg", "Sxsg", "Spsg", "Ocsg", "Nosg", # 51–60
	"Sag", "Usag", "Dsag", "Tsag", "Qasag", "Qisag", "Sxsag", "Spsag", "Ocsag", "Nosag", # 61–70
	"Og", "Uog", "Dog", "Tog", "Qaog", "Qiog", "Sxog", "Spog", "Ocog", "Noog", # 71–80
	"Ng", "Ung", "Dng", "Tng", "Qang", "Qing", "Sxng", "Spng", "Ocng", "Nong", # 81–90
	"Ct", "Uct", "Dct", "Tct", "Qact", "Qict", "Sxct", "Spct", "Occt", "Noct"  # 91–100
]

var BASE_ROUND_DIGITS:int = 2

class BigNum:
	var num: float
	var exp: int

	func _init(start_num: float = 0, start_exp: int = 0) -> void:
		num = start_num
		exp = start_exp
		_normalize()

	func _normalize() -> void:
		while abs(num) >= 10.0:
			num /= 10.0
			exp += 1
		while abs(num) < 1.0 and num != 0.0:
			num *= 10.0
			exp -= 1

	func _clone() -> BigNum:
		return BigNum.new(num, exp)

	#region Arithmetic Operations
	func add(other: BigNum) -> BigNum:
		var new_num = num
		var new_exp = exp
		var exp_dif = other.exp - exp
		new_exp = max(exp, other.exp)

		if exp_dif > 0:
			new_num = other.num + (num / pow(10, exp_dif))
		elif exp_dif == 0:
			new_num = num + other.num
		else:
			new_num = num + (other.num / pow(10, -exp_dif))

		var result = BigNum.new(new_num, new_exp)
		result._normalize()
		return result

	func subtract(other: BigNum) -> BigNum:
		var new_num = num
		var new_exp = exp
		var exp_dif = other.exp - exp
		new_exp = max(exp, other.exp)

		if exp_dif > 0:
			new_num = (num / pow(10, exp_dif)) - other.num
		elif exp_dif == 0:
			new_num = num - other.num
		else:
			new_num = num - (other.num / pow(10, -exp_dif))

		var result = BigNum.new(new_num, new_exp)
		result._normalize()
		return result

	func multiply(other: BigNum) -> BigNum:
		var result = BigNum.new(num * other.num, exp + other.exp)
		result._normalize()
		return result

	func divide(other: BigNum) -> BigNum:
		var result = BigNum.new(num / other.num, exp - other.exp)
		result._normalize()
		return result
	#endregion

	#region Comparison
	func exceeds(other: BigNum) -> bool:
		if exp > other.exp:
			return true
		elif exp < other.exp:
			return false
		else:
			return num >= other.num

	func less_than(other: BigNum) -> bool:
		if exp < other.exp:
			return true
		elif exp > other.exp:
			return false
		else:
			return num < other.num

	func greater_than(other: BigNum) -> bool:
		if exp > other.exp:
			return true
		elif exp < other.exp:
			return false
		else:
			return num > other.num
	#endregion

	#region Display
	func to_scientific_notation(round_digits:int=1) -> String:

		if exp <= 5:
			return str(round(num*pow(10, exp) * pow(10, round_digits)) / pow(10, round_digits))

		var rounded_num = round(num * pow(10, Util.BASE_ROUND_DIGITS)) / pow(10, Util.BASE_ROUND_DIGITS)
		var formatted_num = str(rounded_num)
		if exp != 0:
			formatted_num += "e" + str(exp)
		return formatted_num

	func to_suffix_notation() -> String:
		@warning_ignore("integer_division")
		var rounded_num = round(num * pow(10, Util.BASE_ROUND_DIGITS)) / pow(10, Util.BASE_ROUND_DIGITS)
		if exp / 3 < len(Util.base_suffixes):
			return str(rounded_num) + " " + str(Util.base_suffixes[exp / 3])
		else:
			return to_scientific_notation()
	#endregion


## A value used for managing a player currency. Can be converted to and from json.
class Currency:
	var val:BigNum
	var id:String

	func _init(currency_id:String, currency_val:BigNum=null) -> void:

		id = currency_id

		if currency_val:
			val = currency_val
		else:
			val = BigNum.new(0)

	## Exports the DataVal to a json format.
	func to_json() -> Dictionary:
		return {
			"id": id,
			"obj": val # TODO: Make object also convert into json.
		}

	## Imports the DataVal from a json format.
	func from_json(dict:Dictionary) -> void:
		id = dict["id"]
		val = dict["obj"]

func _ready() -> void:
	pass
