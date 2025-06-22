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
	enable_ui(false)
	Global.battle_simulator.run_simulation(true)
	round_end()

func round_end():
	Global.hand_scene.fill_hand()
	enable_ui(true)
	current_round += 1
	update_round_label()
	before_round()

func update_round_label():
	if has_node("Panel/roundLabel"):
		$Panel/roundLabel.text = str(current_round)

func enable_ui(value: bool):
	Global.board_scene.set_board_enabled(value)
	Global.hand_scene.set_hand_enabled(value)

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
		enemy.init_letter(Global.letter_stats.return_random_letter(), true)
		slot.current_letter = enemy
		slot.letter_is_placed()
		enemy.position += Vector2(80,80)
		enemy.properties.grid_x = slot.slotColumn
		enemy.properties.grid_y = slot.slotRow
		#enemy.modulate = Color(1, 0.8, 0.8, 1)
		Global.board_scene.enemy_letters.append(enemy)
		Global.sfx_manager.play_sfx("stone1", enemy.position)
		await get_tree().create_timer(0.3).timeout
	
