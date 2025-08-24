class_name LetterUnit 
extends Node2D

# Identifiers
@export var letter: String = ""
@export var is_enemy: bool = false
@export var grid_x: int = 0
@export var grid_y: int = 0
@onready var letterParent = get_parent()
@onready var letterDisplay: letterDisplayClass 
@export var is_an_object: bool = false
# Combat stats
@export var current_hp: int = 20
@export var max_hp: int = 20
@export var attack: int = 10
@export var is_dead: bool = false
@export var always_dead: bool = false

# Effects / Buffs
@export var element_type: String = "" # Optional: "Fire", "Water", etc.
@export var locked: bool = false
@export var current_upgrade: String = ""
@export var NSAB: bool = false
@export var status_effects: Array = []

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
	

func update_stats(atk_val: int, hp_val: int):
	attack = atk_val
	max_hp = hp_val
	current_hp = hp_val
