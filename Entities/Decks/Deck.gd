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
	
func initialize_deck():
	deck.clear()
	var all_letters = letter_stats.LETTER_STATS.keys()
	all_letters.sort()
	for letter in all_letters:
		deck.append(letter)
		#deck.append(letter)

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

func update_letter_instances(letterToCheck):
	var all_instances = get_instances_of_letter(letterToCheck.letter)
	for instance in all_instances:
		instance.properties.update_stats(letterToCheck.attack, letterToCheck.max_hp)
		
		

func get_instances_of_letter(target_letter: String) -> Array:
	return letter_instances.get(target_letter, [])


func get_random_letter_instance() -> Node2D:
	if deck.is_empty():
		return null
	var letter = get_child(pick_random_deck_child())
	deck.remove_at(rand_index)
	#print(deck)
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
	
func refill_main_deck(deckFROM: deck_class, deckTO: deck_class):
	deckFROM.deck.clear()
	var letterArray = deckFROM.get_children()
	for letterIndex in letterArray:
		letterIndex.reparent(deckTO)
		deckTO.deck.append(letterIndex.properties.letter)
	arrange_deck()
		
func arrange_deck():
	deck.sort()
	for j in deck.size():
		var letter2Dinstance = get_child(j)
		letter2Dinstance.set_letter(deck[j])
		var row = j / GRID_COLUMNS
		var col = j % GRID_COLUMNS
		letter2Dinstance.position = Vector2(col, row) * CELL_SIZE

func set_all_letters_inactive():
	for letter in deck:
		letter.is_active = false
