extends Control

class_name LetterDisplayClass

#Default letter stats
var stats: Dictionary
@export var letter_stats_path = "res://resources/letter_stats.tres"
@export var letter_stats = load(letter_stats_path)

#Letter face and stats
@onready var letter_label = $Panel/LetterLabel
@onready var ATK_label = $Panel/ATKLabel
@onready var HP_label = $Panel/DefLabel
var current_letter = "G"
var current_element = "Neutral"
var letter_unit
@export var base_atk :int
@export var base_hp :int
@export var current_hp :int
var is_enemy:bool

#On ready
func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	await get_tree().process_frame
	
#Change letter to another from stats
func change_letter(character: String):
	current_letter = character
	change_element(current_letter)
	letter_label.text = str(character)
	stats = letter_stats.get_stats(character)
	
	update_stats(int(stats["atk"]), int(stats["hp"]))
	get_parent().get_parent().letter_unit.initialize(current_letter, is_enemy, base_atk, base_hp, current_element)
	#ATK_label.add_theme_font_size_override("font_size", 25 + (current_atk*0.2))
	#ATK_label.add_theme_constant_override("outline_size", 5+ (current_atk*0.2))
	
	#DEF_label.add_theme_font_size_override("font_size", 25 + (current_hp * 0.2))
	#DEF_label.add_theme_constant_override("outline_size", 5 + (current_hp*0.2))

func change_element(letterToElement: String):
	current_element = letter_stats.get_element_for_letter(letterToElement)
	change_font(current_element)
	get_parent().get_parent().update_element_style()

func change_font(element: String):
	var font: Font = null
	match element:
		"Water":
			font = load("res://fonts/VarelaRound-Regular.ttf")
		"Fire":
			font = load("res://fonts/PirataOne-Regular.ttf")
		"Electric":
			font = load("res://fonts/Orbitron-VariableFont_wght.ttf")
		"Earth":
			font = load("res://fonts/AlfaSlabOne-Regular.ttf")
			letter_label.add_theme_font_size_override("font_size", 60)
			
	if font:
		letter_label.add_theme_font_override("font", font)

func update_stats(attack: int, hp: int):
	base_atk = attack
	base_hp = hp
	ATK_label.text = str(attack)
	HP_label.text = str(hp)
	var unit = get_parent().get_parent().return_unit()
	unit.update_stats(attack, hp)

func return_stats():
	return [base_atk, current_hp]
	
func return_letter():
	return $Panel/LetterLabel.text

func return_element():
	return current_element
