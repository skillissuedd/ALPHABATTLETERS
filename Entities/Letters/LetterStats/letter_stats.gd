extends Resource

class_name LetterStats
const stats_script = preload("res://Entities/Letters/LetterStats/letter_stats.gd")

func _ready():
	pass

var LETTER_STATS = {
	"A": { "atk": 5, "hp": 0 },
	"B": { "atk": 1, "hp": 5 },
	"C": { "atk": 1, "hp": 4 },
	"D": { "atk": 2, "hp": 3 },
	"E": { "atk": 1, "hp": 5 },
	"F": { "atk": 5, "hp": 0 },
	"G": { "atk": 1, "hp": 4 },
	"H": { "atk": 2, "hp": 3 },
	"I": { "atk": 0, "hp": 6 },
	"J": { "atk": 6, "hp": 0 },
	"K": { "atk": 5, "hp": 0 },
	"L": { "atk": 1, "hp": 5 },
	"M": { "atk": 6, "hp": 0 },
	"N": { "atk": 4, "hp": 0 },
	"O": { "atk": 1, "hp": 4 },
	"P": { "atk": 5, "hp": 0 },
	"Q": { "atk": 7, "hp": 0 },
	"R": { "atk": 4, "hp": 0 },
	"S": { "atk": 5, "hp": 0 },
	"T": { "atk": 1, "hp": 5 },
	"U": { "atk": 4, "hp": 0 },
	"V": { "atk": 6, "hp": 0 },
	"W": { "atk": 7, "hp": 0 },
	"X": { "atk": 6, "hp": 0 },
	"Y": { "atk": 4, "hp": 0 },
	"Z": { "atk": 2, "hp": 3 }
}

const ELEMENT_MAP = {
	"Water": ["C", "O", "S", "U", "G", "Q", "J"],
	"Electricity": ["Z", "I", "X", "L", "E", "T", "V"],
	"Fire": ["A", "W", "H", "M", "R", "K"],
	"Nature": ["B", "F", "N", "P", "Y", "D"]
}

const UPGRADE_LIST = {
	"Tier 3": ["The Vector", "The Assassin", "The Rebirth", "The Pierce"],
	"Tier 2": ["The Trajectory", "The Halo", "The Dart"],
	"Tier 1": ["The Berserker", "The Line", "The Scar"],
	"Tier S": ["The Mirror"],
	"Tier Catharsis": ["The Catharsis"]
}

func _nerf_all_letters():
	for letter in LETTER_STATS:
		LETTER_STATS[letter]["atk"] = 2
		LETTER_STATS[letter]["hp"] = 1
		

func update_global_stat(letter: String, stat: String, value: int):
	if LETTER_STATS.has(letter) and LETTER_STATS[letter].has(stat):
		LETTER_STATS[letter][stat] = value
		

func get_element_for_letter(current_letter: String):
	current_letter = current_letter.to_upper()
	for element in ELEMENT_MAP.keys():
		if current_letter in ELEMENT_MAP[element]:
			return element
	return


func get_stats(letter: String) -> Dictionary:
	if LETTER_STATS.has(letter):
		return LETTER_STATS[letter] 
	else:
		return {"atk": 0, "hp": 0}  # fallback in case letter is not found

func return_random_letter():
	var keys = LETTER_STATS.keys()
	return keys[randi() % keys.size()]
