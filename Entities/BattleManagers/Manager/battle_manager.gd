extends Node2D

var current_round: int = 1
@onready var ENEMY_LETTER_2D = preload("res://Entities/Letters/Letter2D/Enemy/EnemyLetter2D.tscn")


func _ready():
	pass
	
	
func before_round():
	var enemy_count = Global.board_scene.enemy_letters.size()
	Global.ui_manager._refill_energy()
	if current_round <=3:
		init_enemies(3)
	else:
		init_enemies(current_round + 1)
	
func room_cleared():
	pass
	
func round_start():
	Global.ui_manager.set_ui_enabled(false)
	if not Global.board_scene.enemy_letters.is_empty():	
		Global.battle_simulator.simulate_enemy_attacks()
		await Global.battle_animator.animations_completed
	Global.hand_scene.fill_hand()
	Global.ui_manager.set_ui_enabled(true)
	current_round += 1
	Global.ui_manager.update_round_label()
	before_round()
	
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
		slot.letter_is_placed(enemy)
		
		enemy.properties.grid_x = slot.slotColumn
		enemy.properties.grid_y = slot.slotRow
		#enemy.modulate = Color(1, 0.8, 0.8, 1)
		
		Global.board_scene.enemy_letters.append(enemy)
		Global.sfx_manager.play_sfx("stone1", enemy.position)
		
		var roll = randi() % 6 + 1
		if roll >= 4:
			enemy.coins.visible = true
			enemy._change_coins_count(roll-3)
		
		await get_tree().create_timer(0.3).timeout
		
		
	Global.battle_simulator.save_backups()
	Global.ui_manager.set_ui_enabled(true)
