extends Node2D

class_name deck_class

const LETTER_SCENE2D = preload("res://Entities/Letters/Letter2D/Ally/AllyLetter2D.tscn")

var GRID_COLUMNS = 13  # 13 x 4 grid for 52 letters
const CELL_SIZE = Vector2(250, 280)
var rand_index = null

@export var letter_stats: LetterStats

@export var deck: Array = []
@export var letter_instances: Dictionary = {}

func _ready():
	pass
	
func get_all_letter_instances() -> Array:
	var all_instances = []
	for instances_array in letter_instances.values():
		for target_letter in instances_array:
			all_instances.append(target_letter)
	return all_instances
	
func initialize_deck():
	deck.clear()
	var all_letters = letter_stats.LETTER_STATS.keys()
	all_letters.sort()
	for letter in all_letters:
		deck.append(letter)
		deck.append(letter)
func fill_deck():
	letter_instances.clear()
	for i in range(deck.size()):
		var letter2Dinstance = LETTER_SCENE2D.instantiate()
		var row = i / GRID_COLUMNS
		var col = i % GRID_COLUMNS
		letter2Dinstance.position = (Vector2(col, row) * CELL_SIZE)
		add_child(letter2Dinstance)
		letter2Dinstance.init_letter(deck[i], false)
		
		if not letter_instances.has(deck[i]):
			letter_instances[deck[i]] = []
		letter_instances[deck[i]].append(letter2Dinstance)

func get_instances_of_letter(target_letter: String) -> Array:
	return letter_instances.get(target_letter, [])


func get_random_letter_instance() -> Node2D:
	if deck.is_empty():
		return null
	var letter = get_child(pick_random_deck_child())
	deck.remove_at(rand_index)

	return letter
		
func pick_random_deck_child():
	while not (deck.is_empty()):
		rand_index = randi() % deck.size()
		if get_child(rand_index):
			return rand_index

func append_to_deck(letter: Node2D):
	var total_letters = get_child_count() 
	var row = total_letters / GRID_COLUMNS
	var col = total_letters % GRID_COLUMNS
	deck.append(letter.properties.letter)
	letter.reparent(self)
	letter.position = Vector2(col, row) * CELL_SIZE
	letter.properties.grid_x = 0
	letter.properties.grid_y = 0
	letter.is_active = true
	
func refill_main_deck(deckFROM: deck_class, deckTO: deck_class):
	deckFROM.deck.clear()
	var letterArray = deckFROM.get_children()
	for letterIndex in letterArray:
		letterIndex.reparent(deckTO)
		deckTO.deck.append(letterIndex.properties.letter)
	arrange_deck()
		
func arrange_deck():
	deck.sort()
	var index = 0
	for letter_group in letter_instances.values():
		for letter in letter_group:
			var row = index / GRID_COLUMNS
			var col = index % GRID_COLUMNS
			letter.position = Vector2(col, row) * CELL_SIZE
			index+=1
	
func _compare_letters_alphabetically(a: Node2D, b: Node2D) -> bool:
	if not (a is letter2Dclass and b is letter2Dclass):
		return false
	
	# Get the first character of each letter (assuming letter is a String property)
	var a_char = a.properties.letter.unicode_at(0) if a.properties.letter.length() > 0 else 0
	var b_char = b.properties.letter.unicode_at(0) if b.properties.letter.length() > 0 else 0
	
	# Case-insensitive comparison by converting to uppercase
	return a_char < b_char

func set_all_letters_inactive():
	for letter in deck:
		letter.is_active = false
