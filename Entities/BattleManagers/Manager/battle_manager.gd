extends Node2D

var current_round: int = 1
var enemy_waves_cleared: int = 0
var max_waves_per_room: int = 2
@onready var ENEMY_LETTER_2D = preload("res://Entities/Letters/Letter2D/Enemy/EnemyLetter2D.tscn")


func _ready():
	update_round_label()
	
func before_round():
	var enemy_count = Global.board_scene.enemy_letters.size()
	
	if enemy_count == 0:
		enemy_waves_cleared += 1
		if enemy_waves_cleared >= max_waves_per_room:
			room_cleared()
		else:
			init_enemies(current_round + 4)

func room_cleared():
	pass
	
func round_start():
	lock_in(true)
	var letters = Global.board_scene.return_letters()
	
	for letter in letters:
		if letter:
			letter.attack()
			await get_tree().create_timer(1.0).timeout
	
	await get_tree().create_timer(1.0).timeout
	round_end()

func round_end():
	Global.hand_scene.fill_hand()
	lock_in(false)
	current_round += 1
	update_round_label()
	before_round()

func update_round_label():
	if has_node("Panel/roundLabel"):
		$Panel/roundLabel.text = str(current_round)

func lock_in(value: bool):
	get_parent().button1.disabled = value
	Global.board_scene.unlock(!value)
	Global.hand_scene.unlock_hand(!value)

func init_enemies(enemy_count: int):
	var board_width = Global.board_scene.rows
	var rows_to_use = int(board_width/2)-1
	
	var candidate_slots: Array = []
	
	for slot in Global.board_scene.get_children():
		if not slot.is_in_group("slots") or slot.is_selected:
			continue

		var slot_index := slot.get_index()
		var row = (slot_index / board_width)

		if row > rows_to_use:
			candidate_slots.append(slot)
	
	candidate_slots.shuffle()

	for i in range(min(enemy_count, candidate_slots.size())):
		var slot = candidate_slots[i]
		var enemy = ENEMY_LETTER_2D.instantiate()
		slot.add_child(enemy)
		enemy.finish_letter_preparation("A")
		slot.current_letter = enemy
		slot.letter_is_placed()
		enemy.position += Vector2(80,80)
		enemy.letter_unit.grid_x = slot.slotColumn
		enemy.letter_unit.grid_y = slot.slotRow
		
		enemy.modulate = Color(1, 0.8, 0.8, 1)
		Global.board_scene.enemy_letters.append(enemy.letter_unit)
		
	
