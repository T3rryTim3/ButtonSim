extends RefCounted
class_name B

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

func _clone() -> B:
	return B.new(num, exp)

#region Arithmetic Operations
func add(other: B) -> B:
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

	var result = B.new(new_num, new_exp)
	result._normalize()
	return result

func subtract(other: B) -> B:
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

	var result = B.new(new_num, new_exp)
	result._normalize()
	return result

func multiply(other: B) -> B:
	var result = B.new(num * other.num, exp + other.exp)
	result._normalize()
	return result

func divide(other: B) -> B:
	var result = B.new(num / other.num, exp - other.exp)
	result._normalize()
	return result
#endregion

#region Comparison
func exceeds(other: B) -> bool:
	other._normalize()
	_normalize()
	if exp > other.exp:
		return true
	elif exp < other.exp:
		return false
	else:
		return num >= other.num

func less_than(other: B) -> bool:
	if exp < other.exp:
		return true
	elif exp > other.exp:
		return false
	else:
		return num < other.num

func greater_than(other: B) -> bool:
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
	var rounded_num = round(num * pow(10, Util.BASE_ROUND_DIGITS)) / pow(10, Util.BASE_ROUND_DIGITS)
	if exp / 3 < len(Util.base_suffixes):
		return str(rounded_num * pow(10, exp % 3)) + "" + str(Util.base_suffixes[exp / 3])
	else:
		return to_scientific_notation()

func _to_string() -> String:
	return to_suffix_notation()
#endregion
