class_name LetterUnit 
extends Node2D

# Identifiers
@export var letter: String = ""
@export var is_enemy: bool = false
@export var grid_x: int
@export var grid_y: int 
@onready var letterParent = get_parent()
@onready var letterDisplay: letterDisplayClass 
@export var is_an_object: bool = false
# Combat stats
@export var current_hp: int
@export var max_hp: int
@export var attack: int
@export var is_dead: bool = false
@export var always_dead: bool = false

# Effects / Buffs
@export var element_type: String = "" # Optional: "Fire", "Water", etc.
@export var locked: bool = false
@export var current_upgrade: String = ""
@export var NSAB: bool = false
@export var status_effects: Dictionary

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

func apply_status(status_name: String, duration: int, applied_by: LetterUnit):
	status_effects[status_name] = {
		"duration": status_effects.get(status_name, {"duration": 0})["duration"] + duration,
		"applied_by": applied_by}

func trigger_end_of_the_round_statuses():
	for key in status_effects.keys():
		match key:
			"Burning":
				trigger_burning()
			"Weakness":
				pass
				
	
func status_effects_reduce():
	for key in status_effects.keys():
		status_effects[key]["duration"] -= 1
		if status_effects[key]["duration"] <= 0:
			status_effects.erase(key)

func trigger_burning():
	#add burning animation
	current_hp= max(current_hp-1, 0)
	letterDisplay.update_stats()
	letterParent.update_frame_bar(current_hp*100/max_hp, true)
	
	
	var letter2Dattacker = status_effects["Burning"]["applied_by"].letterParent
		
	Global.battle_manager.letter_got_hit_by(letterParent, letter2Dattacker)
	if current_hp <= 0 and not is_dead:
		is_dead = true
		letterParent.modulate.a = 0.5
		letterDisplay.death_mark.visible = true
		Global.battle_manager._letter_has_killed(letter2Dattacker, letterParent)
		Global.battle_manager._letter_is_dead(letterParent)
	
	
	
