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

## A number consisted of a float value and exponent (equal to num * 10^exp). Used for big numbers.
class BigNum:
	var num:float
	var exp:int

	func _init(start_num:float, start_exp:int=0) -> void:
		self.num = start_num
		self.exp = start_exp

	#region Operators
	## Normalizes the number to scientific notation (1 ≤ |num| < 10).
	func _normalize():
		while abs(self.num) >= 10.0:
			self.num /= 10.0
			self.exp += 1
		while abs(self.num) < 1.0 and self.num != 0.0:
			self.num *= 10.0
			self.exp -= 1

	## Adds another BigNum to this one.
	func add(other: BigNum):
		var exp_dif = other.exp - self.exp
		self.exp = max(other.exp, self.exp)
		if exp_dif > 0:
			self.num = other.num + (self.num / pow(10, exp_dif))
		elif exp_dif == 0:
			self.num = other.num + self.num
		elif exp_dif < 0:
			self.num = self.num + (other.num / pow(10, -exp_dif))
		_normalize()

	## Subtracts another BigNum from this one.
	func subtract(other: BigNum):
		var exp_dif = other.exp - self.exp
		self.exp = max(other.exp, self.exp)
		if exp_dif > 0:
			self.num = (self.num / pow(10, exp_dif)) - other.num
		elif exp_dif == 0:
			self.num = self.num - other.num
		elif exp_dif < 0:
			self.num = self.num - (other.num / pow(10, -exp_dif))
		_normalize()

	## Multiplies this BigNum by another.
	func multiply(other: BigNum):
		self.num *= other.num
		self.exp += other.exp
		_normalize()

	## Divides this BigNum by another.
	func divide(other: BigNum):
		self.num /= other.num
		self.exp -= other.exp
		_normalize()

	#endregion
	
	#region Comparison
	## Returns true if this BigNum is greater than or equal to another.
	func exceeds(other: BigNum) -> bool:
		if self.exp > other.exp:
			return true
		elif self.exp < other.exp:
			return false
		else:
			return self.num >= other.num

	## Returns true if this BigNum is less than another.
	func less_than(other: BigNum) -> bool:
		if self.exp < other.exp:
			return true
		elif self.exp > other.exp:
			return false
		else:
			return self.num < other.num

	## Returns true if this BigNum is greater than another.
	func greater_than(other: BigNum) -> bool:
		if self.exp > other.exp:
			return true
		elif self.exp < other.exp:
			return false
		else:
			return self.num > other.num
	#endregion

	#region Display
	func to_scientific_notation() -> String:
		var rounded_num = round(self.num * pow(10, Util.BASE_ROUND_DIGITS)) / pow(10, Util.BASE_ROUND_DIGITS) 
		var formatted_num = str(rounded_num)
		if self.exp != 0:
			formatted_num += "e" + str(self.exp)
		return formatted_num

	## Returns the BigNum as a string in typical suffix notation (k, M, B, etc.).
	func to_suffix_notation() -> String:
		var rounded_num = round(self.num * pow(10, Util.BASE_ROUND_DIGITS)) / pow(10, Util.BASE_ROUND_DIGITS) 
		if self.exp / 3 < len(Util.base_suffixes):
			return str(rounded_num) + " " + str(Util.base_suffixes[self.exp / 3])
		else:
			return to_scientific_notation()
	#endregion

func _ready() -> void:
	var test1 = BigNum.new(5.976987,2078963)
	var test2 = BigNum.new(5,5)
	#test1.multiply(test2)
	#print(test1.num)
	#print(test1.exp)
	print(test1.to_suffix_notation())
