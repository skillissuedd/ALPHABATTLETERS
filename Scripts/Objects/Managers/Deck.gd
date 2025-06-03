extends Node2D

class_name deck_class

const LETTER_SCENE2D = preload("res://objects/Letters/AllyLetter2D.tscn")

const GRID_COLUMNS = 13  # 13 x 4 grid for 52 letters
const CELL_SIZE = Vector2(200, 200)
var rand_index = null

var row = null
var col = null
@onready var current_letter = "A"
@export var letter_stats: LetterStats
@onready var all_letters = letter_stats.LETTER_STATS.keys()

var letter2Dinstance = null

var deck: Array = []

func _ready():
	pass
	
func initialize_deck():
	deck.clear()
	all_letters.sort()
	for letter in all_letters:
		deck.append(letter)
		deck.append(letter)

func fill_deck():
	for i in range(deck.size()):
		letter2Dinstance = LETTER_SCENE2D.instantiate()
		row = i / GRID_COLUMNS
		col = i % GRID_COLUMNS
		letter2Dinstance.position = Vector2(col, row) * CELL_SIZE
		add_child(letter2Dinstance)
		letter2Dinstance.set_letter(deck[i])
		letter2Dinstance.update_element_style()

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
	var total_letters = get_child_count()  # сколько уже добавлено
	row = total_letters / GRID_COLUMNS
	col = total_letters % GRID_COLUMNS
	deck.append(letter.return_letter())
	letter.reparent(self)
	letter.position = Vector2(col, row) * CELL_SIZE
	
func refill_main_deck(deckFROM: deck_class, deckTO: deck_class):
	deckFROM.deck.clear()
	var letterArray = deckFROM.get_children()
	for letterIndex in letterArray:
		letterIndex.reparent(deckTO)
		deckTO.deck.append(letterIndex.return_letter())
	arrange_deck()
		
func arrange_deck():
	deck.sort()
	for j in deck.size():
		letter2Dinstance = get_child(j)
		letter2Dinstance.set_letter(deck[j])
		row = j / GRID_COLUMNS
		col = j % GRID_COLUMNS
		letter2Dinstance.position = Vector2(col, row) * CELL_SIZE
