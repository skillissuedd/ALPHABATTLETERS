class_name LetterUnit 
extends Node2D

# Identifiers
var letter: String = ""
var is_enemy: bool = false
var grid_x: int = 0
var grid_y: int = 0
@onready var letterParent = get_parent()
# Combat stats
var current_hp: int = 20
var max_hp: int = 20
var attack: int = 10
var is_dead: bool = false

# Effects / Buffs
var element_type: String = "" # Optional: "Fire", "Water", etc.
var locked: bool = false
var current_upgrade: String = ""

func initialize(
	letter_char: String,
	is_enemy_state: bool,
	atk: int,
	hp_val: int,
	element: String = ""
) -> void:
	letter = letter_char
	is_enemy = is_enemy_state
	attack = atk
	max_hp = hp_val
	current_hp = hp_val
	element_type = element
	is_dead = false
	locked = false
	
func show_stats():
	print("letter: " , letter)
	print( " is_enemy: ", is_enemy)
	print( " atk: ", attack,)
	print( " max_hp: ", 	max_hp,)
	print( " hp: ", current_hp,)
	print("element: ", 	element_type)
	print (is_dead)
	print (locked)
	
# Animation hooks (can be overridden or attached in script later)
func animate_attack(target: LetterUnit) -> void:
	print("%s attacks %s" % [letter, target.letter])

func animate_damage(amount: int) -> void:
	print("%s takes %d damage" % [letter, amount])

func animate_death() -> void:
	print("%s has died." % letter)

func update_stats(atk_val: int, hp_val: int):
	attack = atk_val
	max_hp = hp_val
	current_hp = hp_val
