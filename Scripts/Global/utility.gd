extends Node

## Given a dictionary of key-weight pairs, chooses `bulk` number of keys
## from the dictionary according to the weight given.
func bulk_weighted_choice(rarity_dict: Dictionary, bulk: int) -> Dictionary:
	var total_weight = 0.0
	for weight in rarity_dict.values():
		total_weight += weight

	var result := {}
	for key in rarity_dict.keys():
		result[key] = 0  # Initialize count to 0

	for i in range(bulk):
		var rand = randf() * total_weight
		var cumulative = 0.0
		for rarity in rarity_dict.keys():
			cumulative += rarity_dict[rarity]
			if rand <= cumulative:
				result[rarity] += 1
				break

	return result
	
	# Fallback (shouldn't hit unless there's a floating point error)
	return rarity_dict.keys()[0]
