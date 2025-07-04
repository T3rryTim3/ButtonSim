class_name B
extends RefCounted
## B number class for use in idle / incremental games and other games that needs very large numbers
##
## Can format large numbers using a variety of notation methods:[br]
## AA notation like AA, AB, AC etc.[br]
## Metric symbol notation k, m, G, T etc.[br]
## Metric name notation kilo, mega, giga, tera etc.[br]
## Long names like octo-vigin-tillion or millia-nongen-quin-vigin-tillion (based on work by Landon Curt Noll)[br]
## Scientic notation like 13e37 or 42e42[br]
## Long strings like 4200000000 or 13370000000000000000000000000000[br][br]
## Please note that this class has limited precision and does not fully support negative exponents[br]

const base_suffixes = [
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

## B Number Mantissa
var mantissa: float
## B Number Exponent
var exponent: int

## Metric Symbol Suffixes
const suffixes_metric_symbol: Dictionary = {
	"0": "", 
	"1": "k", 
	"2": "M", 
	"3": "G", 
	"4": "T", 
	"5": "P", 
	"6": "E", 
	"7": "Z", 
	"8": "Y", 
	"9": "R", 
	"10": "Q",
}
## Metric Name Suffixes
const suffixes_metric_name: Dictionary = {
	"0": "", 
	"1": "kilo", 
	"2": "mega", 
	"3": "giga", 
	"4": "tera", 
	"5": "peta", 
	"6": "exa", 
	"7": "zetta", 
	"8": "yotta", 
	"9": "ronna", 
	"10": "quetta", 
}

## AA suffixes keps in dictionary to prevent generating each of them again and again
static var suffixes_aa: Dictionary = {
	"0": "", 
	"1": "k", 
	"2": "m", 
	"3": "b", 
	"4": "t", 
	"5": "aa", 
	"6": "ab", 
	"7": "ac", 
	"8": "ad", 
	"9": "ae", 
	"10": "af", 
	"11": "ag", 
	"12": "ah", 
	"13": "ai", 
	"14": "aj", 
	"15": "ak", 
	"16": "al", 
	"17": "am", 
	"18": "an", 
	"19": "ao", 
	"20": "ap", 
	"21": "aq", 
	"22": "ar", 
	"23": "as", 
	"24": "at", 
	"25": "au", 
	"26": "av", 
	"27": "aw", 
	"28": "ax", 
	"29": "ay", 
	"30": "az", 
	"31": "ba", 
	"32": "bb", 
	"33": "bc", 
	"34": "bd", 
	"35": "be", 
	"36": "bf", 
	"37": "bg", 
	"38": "bh", 
	"39": "bi", 
	"40": "bj", 
	"41": "bk", 
	"42": "bl", 
	"43": "bm", 
	"44": "bn", 
	"45": "bo", 
	"46": "bp", 
	"47": "bq", 
	"48": "br", 
	"49": "bs", 
	"50": "bt", 
	"51": "bu", 
	"52": "bv", 
	"53": "bw", 
	"54": "bx", 
	"55": "by", 
	"56": "bz", 
	"57": "ca"
}

## AA Alphabet
const alphabet_aa: Array[String] = [
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
	"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
]

## Latin Ones Prefixes
const latin_ones: Array[String] = [
	"", "un", "duo", "tre", "quattuor", "quin", "sex", "septen", "octo", "novem"
]
## Latin Tens Prefixes
const latin_tens: Array[String] = [
	"", "dec", "vigin", "trigin", "quadragin", "quinquagin", "sexagin", "septuagin", "octogin", "nonagin"
]
## Latin Hundreds Prefixes
const latin_hundreds: Array[String] = [
	"", "cen", "duocen", "trecen", "quadringen", "quingen", "sescen", "septingen", "octingen", "nongen"
]
## Latin Special Prefixes
const latin_special: Array[String] = [
	"", "mi", "bi", "tri", "quadri", "quin", "sex", "sept", "oct", "non"
]

## Various options to control the string presentation of B Numbers
static var options = {
	"dynamic_decimals": false, 
	"dynamic_numbers": 4, 
	"small_decimals": 2, 
	"thousand_decimals": 2, 
	"big_decimals": 2, 
	"scientific_decimals": 2, 
	"logarithmic_decimals": 2, 
	"maximum_trailing_zeroes": 3,
	"thousand_separator": ",", 
	"decimal_separator": ".", 
	"suffix_separator": "", 
	"reading_separator": "", 
	"thousand_name": "thousand"
}

## Maximum B Number Mantissa
const MANTISSA_MAX: float = 1209600.0
## B Number Mantissa floating-point precision
const MANTISSA_PRECISION: float = 0.00001 # Note: Removed 2 0s for optimization

## int (signed 64-bit) minimum value
const INT_MIN: int = -9223372036854775808
## int (signed 64-bit) maximum value
const INT_MAX: int = 9223372036854775807

func _init(m: Variant = 1.0, e: int = 0) -> void:
	if m is B:
		mantissa = m.mantissa
		exponent = m.exponent
	elif typeof(m) == TYPE_STRING:
		var scientific: PackedStringArray = m.split("e")
		mantissa = float(scientific[0])
		exponent = int(scientific[1]) if scientific.size() > 1 else 0
	else:
		if typeof(m) != TYPE_INT and typeof(m) != TYPE_FLOAT:
			printerr("B Error: Unknown data type passed as a mantissa!")
		mantissa = m
		exponent = e
	B._sizeCheck(mantissa)
	B.normalize(self)

## Verifies (or converts) an argument into a B number
static func _typeCheck(n) -> B:
	if n is B:
		return n
	var result := B.new(n)
	return result

## Warns if B number's mantissa exceeds max
static func _sizeCheck(m: float) -> void:
	if m > MANTISSA_MAX:
		printerr("B Error: Mantissa \"" + str(m) + "\" exceeds MANTISSA_MAX. Use exponent or scientific notation")


## [url=https://en.wikipedia.org/wiki/Normalized_number]Normalize[/url] a B number
static func normalize(big: B) -> void:
	# Store sign if negative
	var is_negative := false
	if big.mantissa < 0:
		is_negative = true
		big.mantissa *= -1
		
	if big.mantissa < 1.0 or big.mantissa >= 10.0:
		var diff: int = floor(log10(big.mantissa))
		if diff > -10 and diff < 248:
			var div = 10.0 ** diff
			if div > MANTISSA_PRECISION:
				big.mantissa /= div
				big.exponent += diff
	while big.exponent < 0:
		big.mantissa *= 0.1
		big.exponent += 1
	while big.mantissa >= 10.0:
		big.mantissa *= 0.1
		big.exponent += 1
	if big.mantissa == 0:
		big.mantissa = 0.0
		big.exponent = 0
	big.mantissa = snapped(big.mantissa, MANTISSA_PRECISION)
	
	# Return sign if negative
	if (is_negative):
		big.mantissa *= -1


## Returns the absolute value of a number in B format
static func absolute(x) -> B:
	var result := B.new(x)
	result.mantissa = abs(result.mantissa)
	return result


## Adds two numbers and returns the B number result [br][br]
static func add(x, y) -> B:
	x = B._typeCheck(x)
	y = B._typeCheck(y)
	var result := B.new(x)
	
	var exp_diff: float = y.exponent - x.exponent
	
	if exp_diff < 248.0:
		var scaled_mantissa: float = y.mantissa * 10 ** exp_diff
		result.mantissa = x.mantissa + scaled_mantissa
	elif x.isLessThan(y): # When difference between values is too big, discard the smaller number
		result.mantissa = y.mantissa 
		result.exponent = y.exponent
	B.normalize(result)
	return result

## Subtracts two numbers and returns the B number result
static func subtract(x, y) -> B:
	x = B._typeCheck(x)
	y = B._typeCheck(y)
	var negated_y := B.new(-y.mantissa, y.exponent)
	return add(negated_y, x)


## Multiplies two numbers and returns the B number result
static func times(x, y) -> B:
	x = B._typeCheck(x)
	y = B._typeCheck(y)
	var result := B.new()

	var new_exponent: int = y.exponent + x.exponent
	var new_mantissa: float = y.mantissa * x.mantissa
	while new_mantissa >= 10.0:
		new_mantissa /= 10.0
		new_exponent += 1
	result.mantissa = new_mantissa
	result.exponent = new_exponent
	B.normalize(result)
	return result


## Divides two numbers and returns the B number result
static func division(x, y) -> B:
	x = B._typeCheck(x)
	y = B._typeCheck(y)
	var result := B.new(x)
	
	if y.mantissa > -MANTISSA_PRECISION and y.mantissa < MANTISSA_PRECISION:
		printerr("B Error: Divide by zero or less than " + str(MANTISSA_PRECISION))
		return x
	var new_exponent = x.exponent - y.exponent
	var new_mantissa = x.mantissa / y.mantissa
	while new_mantissa > 0.0 and new_mantissa < 1.0:
		new_mantissa *= 10.0
		new_exponent -= 1
	result.mantissa = new_mantissa
	result.exponent = new_exponent
	B.normalize(result)
	return result


## Raises a B number to the nth power and returns the B number result
static func powers(x: B, y) -> B:
	var result := B.new(x)
	if typeof(y) == TYPE_INT:
		if y <= 0:
			if y < 0:
				printerr("B Error: Negative exponents are not supported!")
			result.mantissa = 1.0
			result.exponent = 0
			return result
		
		var y_mantissa: float = 1.0
		var y_exponent: int = 0
		
		while y > 1:
			B.normalize(result)
			if y % 2 == 0:
				result.exponent *= 2
				result.mantissa **= 2
				y = y / 2
			else:
				y_mantissa = result.mantissa * y_mantissa
				y_exponent = result.exponent + y_exponent
				result.exponent *= 2
				result.mantissa **= 2
				y = (y - 1) / 2
		
		result.exponent = y_exponent + result.exponent
		result.mantissa = y_mantissa * result.mantissa
		B.normalize(result)
		return result
	elif typeof(y) == TYPE_FLOAT:
		if result.mantissa == 0:
			return result
		
		# fast track
		var temp: float = result.exponent * y
		var newMantissa = result.mantissa ** y
		if (round(y) == y
				and temp <= INT_MAX
				and temp >= INT_MIN
				and is_finite(temp)
		):
			if is_finite(newMantissa):
				result.mantissa = newMantissa
				result.exponent = int(temp)
				B.normalize(result)
				return result
		
		# a bit slower, still supports floats
		var newExponent: int = int(temp)
		var residue: float = temp - newExponent
		newMantissa = 10 ** (y * B.log10(result.mantissa) + residue)
		if newMantissa != INF and newMantissa != -INF:
			result.mantissa = newMantissa
			result.exponent = newExponent
			B.normalize(result)
			return result
		
		if round(y) != y:
			printerr("B Error: Power function does not support large floats, use integers!")
		
		return powers(x, int(y))
	elif y is B:
		# warning - this might be slow!
		if y.isEqualTo(0):
			return B.new(1)
		if y.isLessThan(0):
			printerr("B Error: Negative exponents are not supported!")
			return B.new(0)

		var exponent_decremented:B = y.minus(1)
		while exponent_decremented.isGreaterThan(0):
			result.multiplyEquals(x)
			exponent_decremented.minusEquals(1)

		return result
	else:
		printerr("B Error: Unknown/unsupported data type passed as an exponent in power function!")
		return x


## Square Roots a given B number and returns the B number result
static func root(x: B) -> B:
	var result := B.new(x)
	
	if result.exponent % 2 == 0:
		result.mantissa = sqrt(result.mantissa)
		@warning_ignore("integer_division")
		result.exponent = result.exponent / 2
	else:
		result.mantissa = sqrt(result.mantissa * 10)
		@warning_ignore("integer_division")
		result.exponent = (result.exponent - 1) / 2
	B.normalize(result)
	return result


## Modulos a number and returns the B number result
static func modulo(x, y) -> B:
	var result := B.new(x.mantissa, x.exponent)
	y = B._typeCheck(y)
	var big = { "mantissa": x.mantissa, "exponent": x.exponent }
	B.division(result, y)
	B.roundDown(result)
	B.times(result, y)
	B.subtract(result, big)
	result.mantissa = abs(result.mantissa)
	return result


## Rounds down a B number
static func roundDown(x: B) -> B:
	if x.exponent == 0:
		x.mantissa = floor(x.mantissa)
	else:
		var precision := 1.0
		for i in range(min(8, x.exponent)):
			precision /= 10.0
		if precision < MANTISSA_PRECISION:
			precision = MANTISSA_PRECISION
		x.mantissa = floor(x.mantissa / precision) * precision
	return x


## Equivalent of [code]min(B, B)[/code]
static func minValue(m, n) -> B:
	m = B._typeCheck(m)
	if m.isLessThan(n):
		return m
	else:
		return n


## Equivalent of [code]max(B, B)[/code]
static func maxValue(m, n) -> B:
	m = B._typeCheck(m)
	if m.isGreaterThan(n):
		return m
	else:
		return n


## Equivalent of [code]B + n[/code]
func plus(n) -> B:
	return B.add(self, n)


## Equivalent of [code]B += n[/code]
func plusEquals(n) -> B:
	var new_value = B.add(self, n)
	mantissa = new_value.mantissa
	exponent = new_value.exponent
	return self

## Equivalent of [code]B - n[/code]
func minus(n) -> B:
	return B.subtract(self, n)


## Equivalent of [code]B -= n[/code]
func minusEquals(n) -> B:
	var new_value: B = B.subtract(self, n)
	mantissa = new_value.mantissa
	exponent = new_value.exponent
	return self

## Equivalent of [code]B * n[/code]
func multiply(n) -> B:
	return B.times(self, n)

## Equivalent of [code]B *= n[/code]
func multiplyEquals(n) -> B:
	var new_value: B = B.times(self, n)
	mantissa = new_value.mantissa
	exponent = new_value.exponent
	return self


## Equivalent of [code]B / n[/code]
func divide(n) -> B:
	return B.division(self, n)


## Equivalent of [code]B /= n[/code]
func divideEquals(n) -> B:
	var new_value: B = B.division(self, n)
	mantissa = new_value.mantissa
	exponent = new_value.exponent
	return self


## Equivalent of [code]B % n[/code]
func mod(n) -> B:
	return B.modulo(self, n)


## Equivalent of [code]B %= n[/code]
func modEquals(n) -> B:
	var new_value := B.modulo(self, n)
	mantissa = new_value.mantissa
	exponent = new_value.exponent
	return self


## Equivalent of [code]B ** n[/code]
func power(n) -> B:
	return B.powers(self, n)


## Equivalent of [code]B **= n[/code]
func powerEquals(n) -> B:
	var new_value: B = B.powers(self, n)
	mantissa = new_value.mantissa
	exponent = new_value.exponent
	return self


## Equivalent of [code]sqrt(B)[/code]
func squareRoot() -> B:
	return B.root(self)


## Equivalent of [code]B = sqrt(B)[/code]
func squared() -> B:
	var new_value := B.root(self)
	mantissa = new_value.mantissa
	exponent = new_value.exponent
	return self


## Equivalent of [code]B == n[/code]
func isEqualTo(n) -> bool:
	n = B._typeCheck(n)
	B.normalize(n)
	return n.exponent == exponent and is_equal_approx(n.mantissa, mantissa)


## Equivalent of [code]B > n[/code]
func isGreaterThan(n) -> bool:
	return !isLessThanOrEqualTo(n)


## Equivalent of [code]B >== n[/code]
func exceeds(n) -> bool:
	return !isLessThan(n)


## Equivalent of [code]B < n[/code]
func isLessThan(n) -> bool:
	n = B._typeCheck(n)
	B.normalize(n)
	if (mantissa == 0
			and (n.mantissa > MANTISSA_PRECISION or mantissa < MANTISSA_PRECISION)
			and n.mantissa == 0
	):
		return false
	if exponent < n.exponent:
		if exponent == n.exponent - 1 and mantissa > 10*n.mantissa:	
			return false #9*10^3 > 0.1*10^4
		return true
	elif exponent == n.exponent:
		if mantissa < n.mantissa:
			return true
		return false
	else:
		if exponent == n.exponent + 1 and mantissa * 10 < n.mantissa:
			return true
		return false


## Equivalent of [code]B <= n[/code]
func isLessThanOrEqualTo(n) -> bool:
	n = B._typeCheck(n)
	B.normalize(n)
	if isLessThan(n):
		return true
	if n.exponent == exponent and is_equal_approx(n.mantissa, mantissa):
		return true
	return false


static func log10(x) -> float:
	return log(x) * 0.4342944819032518


func absLog10() -> float:
	return exponent + B.log10(abs(mantissa))


func ln() -> float:
	return 2.302585092994045 * logN(10)


func logN(base) -> float:
	return (2.302585092994046 / log(base)) * (exponent + B.log10(mantissa))


func pow10(value: int) -> void:
	mantissa = 10 ** (value % 1)
	exponent = int(value)


## Sets the Thousand name option
static func setThousandName(name: String) -> void:
	options.thousand_name = name


## Sets the Thousand Separator option
static func setThousandSeparator(separator: String) -> void:
	options.thousand_separator = separator


## Sets the Decimal Separator option
static func setDecimalSeparator(separator: String) -> void:
	options.decimal_separator = separator


## Sets the Suffix Separator option
static func setSuffixSeparator(separator: String) -> void:
	options.suffix_separator = separator


## Sets the Reading Separator option
static func setReadingSeparator(separator: String) -> void:
	options.reading_separator = separator


## Sets the Dynamic Decimals option
static func setDynamicDecimals(d: bool) -> void:
	options.dynamic_decimals = d


## Sets the Dynamic numbers digits option
static func setDynamicNumbers(d: int) -> void:
	options.dynamic_numbers = d


## Sets the maximum trailing zeroes option
static func setMaximumTrailingZeroes(d: int) -> void:
	options.maximum_trailing_zeroes = d


## Sets the small decimal digits option
static func setSmallDecimals(d: int) -> void:
	options.small_decimals = d


## Sets the thousand decimal digits option
static func setThousandDecimals(d: int) -> void:
	options.thousand_decimals = d


## Sets the big decimal digits option
static func setBDecimals(d: int) -> void:
	options.big_decimals = d


## Sets the scientific notation decimal digits option
static func setScientificDecimals(d: int) -> void:
	options.scientific_decimals = d


## Sets the logarithmic notation decimal digits option
static func setLogarithmicDecimals(d: int) -> void:
	options.logarithmic_decimals = d


## Converts the B Number into a string
func toString() -> String:
	var mantissa_decimals := 0
	if str(mantissa).find(".") >= 0:
		mantissa_decimals = str(mantissa).split(".")[1].length()
	if mantissa_decimals > exponent:
		if exponent < 248:
			return str(mantissa * 10 ** exponent)
		else:
			return toPlainScientific()
	else:
		var mantissa_string := str(mantissa).replace(".", "")
		for _i in range(exponent-mantissa_decimals):
			mantissa_string += "0"
		return mantissa_string


## Converts the B Number into a string (in plain Scientific format)
func toPlainScientific() -> String:
	return str(mantissa) + "e" + str(exponent)


## Converts the B Number into a string (in Scientific format)
func toScientific(no_decimals_on_small_values = false, force_decimals = false) -> String:
	if exponent < 3:
		var decimal_increments: float = 1 / (10 ** options.scientific_decimals / 10)
		var value := str(snappedf(mantissa * 10 ** exponent, decimal_increments))
		var split := value.split(".")
		if no_decimals_on_small_values:
			return split[0]
		if split.size() > 1:
			for i in range(options.logarithmic_decimals):
				if split[1].length() < options.scientific_decimals:
					split[1] += "0"
			return split[0] + options.decimal_separator + split[1].substr(0,min(options.scientific_decimals, options.dynamic_numbers - split[0].length() if options.dynamic_decimals else options.scientific_decimals))
		else:
			return value
	else:
		var split := str(mantissa).split(".")
		if split.size() == 1:
			split.append("")
		if force_decimals:
			for i in range(options.scientific_decimals):
				if split[1].length() < options.scientific_decimals:
					split[1] += "0"
		return split[0] + options.decimal_separator + split[1].substr(0,min(options.scientific_decimals, options.dynamic_numbers-1 - str(exponent).length() if options.dynamic_decimals else options.scientific_decimals)) + "e" + str(exponent)

func toSuffix() -> String:
	var rounded_num = round(mantissa * pow(10, 2)) / pow(10, 2)
	@warning_ignore("integer_division")
	if exponent / 3 < len(base_suffixes):
		@warning_ignore("integer_division")
		return str(rounded_num * pow(10, exponent % 3)) + "" + str(base_suffixes[exponent / 3])
	else:
		return toScientific()

## Converts the B Number into a string (in Logarithmic format)
func toLogarithmic(no_decimals_on_small_values = false) -> String:
	var decimal_increments: float = 1 / (10 ** options.logarithmic_decimals / 10)
	if exponent < 3:
		var value := str(snappedf(mantissa * 10 ** exponent, decimal_increments))
		var split := value.split(".")
		if no_decimals_on_small_values:
			return split[0]
		if split.size() > 1:
			for i in range(options.logarithmic_decimals):
				if split[1].length() < options.logarithmic_decimals:
					split[1] += "0"
			return split[0] + options.decimal_separator + split[1].substr(0,min(options.logarithmic_decimals, options.dynamic_numbers - split[0].length() if options.dynamic_decimals else options.logarithmic_decimals))
		else:
			return value
	var dec := str(snappedf(abs(log(mantissa) / log(10) * 10), decimal_increments))
	dec = dec.replace(".", "")
	for i in range(options.logarithmic_decimals):
		if dec.length() < options.logarithmic_decimals:
			dec += "0"
	var formated_exponent := formatExponent(exponent)
	dec = dec.substr(0, min(options.logarithmic_decimals, options.dynamic_numbers - formated_exponent.length() if options.dynamic_decimals else options.logarithmic_decimals))
	return "e" + formated_exponent + options.decimal_separator + dec


## Formats an exponent for string format
func formatExponent(value) -> String:
	if value < 1000:
		return str(value)
	var string := str(value)
	var string_mod := string.length() % 3
	var output := ""
	for i in range(0, string.length()):
		if i != 0 and i % 3 == string_mod:
			output += options.thousand_separator
		output += string[i]
	return output


## Converts the B Number into a float
func toFloat() -> float:
	return snappedf(float(str(mantissa) + "e" + str(exponent)),0.01)


func toPrefix(no_decimals_on_small_values = false, use_thousand_symbol=true, force_decimals=true, scientic_prefix=false) -> String:
	var number: float = mantissa
	if not scientic_prefix:
		var hundreds = 1
		for _i in range(exponent % 3):
			hundreds *= 10
		number *= hundreds

	var split := str(number).split(".")
	if split.size() == 1:
		split.append("")
	if force_decimals:
		var max_decimals = max(max(options.small_decimals, options.thousand_decimals), options.big_decimals)
		for i in range(max_decimals):
			if split[1].length() < max_decimals:
				split[1] += "0"
	
	if no_decimals_on_small_values and exponent < 3:
		return split[0]
	elif exponent < 3:
		if options.small_decimals == 0 or split[1] == "":
			return split[0]
		else:
			return split[0] + options.decimal_separator + split[1].substr(0,min(options.small_decimals, options.dynamic_numbers - split[0].length() if options.dynamic_decimals else options.small_decimals))
	elif exponent < 6:
		if options.thousand_decimals == 0 or (split[1] == "" and use_thousand_symbol):
			return split[0]
		else:
			if use_thousand_symbol: # when the prefix is supposed to be using with a K for thousand
				for i in range(options.maximum_trailing_zeroes):
					if split[1].length() < options.maximum_trailing_zeroes:
						split[1] += "0"
				return split[0] + options.decimal_separator + split[1].substr(0,min(options.thousand_decimals, options.dynamic_numbers - split[0].length() if options.dynamic_decimals else 3))
			else:
				for i in range(options.maximum_trailing_zeroes):
					if split[1].length() < options.maximum_trailing_zeroes:
						split[1] += "0"
				return split[0] + options.thousand_separator + split[1].substr(0,3)
	else:
		if options.big_decimals == 0 or split[1] == "":
			return split[0]
		else:
			return split[0] + options.decimal_separator + split[1].substr(0,min(options.big_decimals, options.dynamic_numbers - split[0].length() if options.dynamic_decimals else options.big_decimals))


func _latinPower(european_system) -> int:
	if european_system:
		@warning_ignore("integer_division")
		return int(exponent / 3) / 2
	@warning_ignore("integer_division")
	return int(exponent / 3) - 1


func _latinPrefix(european_system) -> String:
	var ones := _latinPower(european_system) % 10
	var tens := int(_latinPower(european_system) / floor(10)) % 10
	@warning_ignore("integer_division")
	var hundreds := int(_latinPower(european_system) / 100) % 10
	@warning_ignore("integer_division")
	var millias := int(_latinPower(european_system) / 1000) % 10

	var prefix := ""
	if _latinPower(european_system) < 10:
		prefix = latin_special[ones] + options.reading_separator + latin_tens[tens] + options.reading_separator + latin_hundreds[hundreds]
	else:
		prefix = latin_hundreds[hundreds] + options.reading_separator + latin_ones[ones] + options.reading_separator + latin_tens[tens]

	for _i in range(millias):
		prefix = "millia" + options.reading_separator + prefix

	return prefix.lstrip(options.reading_separator).rstrip(options.reading_separator)


func _tillionOrIllion(european_system) -> String:
	if exponent < 6:
		return ""
	var powerKilo := _latinPower(european_system) % 1000
	if powerKilo < 5 and powerKilo > 0 and _latinPower(european_system) < 1000:
		return ""
	if (
			powerKilo >= 7 and powerKilo <= 10
			or int(powerKilo / floor(10)) % 10 == 1
	):
		return "i"
	return "ti"


func _llionOrLliard(european_system) -> String:
	if exponent < 6:
		return ""
	if int(exponent/floor(3)) % 2 == 1 and european_system:
		return "lliard"
	return "llion"


func getLongName(european_system = false, prefix="") -> String:
	if exponent < 6:
		return ""
	else:
		return prefix + _latinPrefix(european_system) + options.reading_separator + _tillionOrIllion(european_system) + _llionOrLliard(european_system)


## Converts the B Number into a string (in American Long Name format)
func toAmericanName(no_decimals_on_small_values = false) -> String:
	return toLongName(no_decimals_on_small_values, false)


## Converts the B Number into a string (in European Long Name format)
func toEuropeanName(no_decimals_on_small_values = false) -> String:
	return toLongName(no_decimals_on_small_values, true)


## Converts the B Number into a string (in Latin Long Name format)
func toLongName(no_decimals_on_small_values = false, european_system = false) -> String:
	if exponent < 6:
		if exponent > 2:
			return toPrefix(no_decimals_on_small_values) + options.suffix_separator + options.thousand_name
		else:
			return toPrefix(no_decimals_on_small_values)

	var suffix = _latinPrefix(european_system) + options.reading_separator + _tillionOrIllion(european_system) + _llionOrLliard(european_system)

	return toPrefix(no_decimals_on_small_values) + options.suffix_separator + suffix


## Converts the B Number into a string (in Metric Symbols format)
func toMetricSymbol(no_decimals_on_small_values = false) -> String:
	@warning_ignore("integer_division")
	var target := int(exponent / 3)

	if not suffixes_metric_symbol.has(str(target)):
		return toScientific()
	else:
		return toPrefix(no_decimals_on_small_values) + options.suffix_separator + suffixes_metric_symbol[str(target)]


## Converts the B Number into a string (in Metric Name format)
func toMetricName(no_decimals_on_small_values = false) -> String:
	@warning_ignore("integer_division")
	var target := int(exponent / 3)

	if not suffixes_metric_name.has(str(target)):
		return toScientific()
	else:
		return toPrefix(no_decimals_on_small_values) + options.suffix_separator + suffixes_metric_name[str(target)]


## Converts the B Number into a string (in AA format)
func toAA(no_decimals_on_small_values = false, use_thousand_symbol = true, force_decimals=false) -> String:
	@warning_ignore("integer_division")
	var target := int(exponent / 3)
	var aa_index := str(target)
	var suffix := ""

	if not suffixes_aa.has(aa_index):
		var offset := target + 22
		var base := alphabet_aa.size()
		while offset > 0:
			offset -= 1
			var digit := offset % base
			suffix = alphabet_aa[digit] + suffix
			offset /= base
		suffixes_aa[aa_index] = suffix
	else:
		suffix = suffixes_aa[aa_index]

	if not use_thousand_symbol and target == 1:
		suffix = ""

	var prefix = toPrefix(no_decimals_on_small_values, use_thousand_symbol, force_decimals)

	return prefix + options.suffix_separator + suffix

func _to_string() -> String:
	return toSuffix()

func to_json() -> Dictionary:
	return {
		"_type": "bignum",
		"mantissa": mantissa,
		"exp": exponent
	}

static func from_json(dict:Dictionary) -> B:
	if "_type" in dict and dict._type == "bignum":
		return B.new(dict.mantissa, dict.exp)
	printerr("Invalid data passed for from_json! Returning 0 as fallback")
	return B.new(0)
