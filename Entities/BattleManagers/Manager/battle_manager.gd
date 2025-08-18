extends Node2D

var current_round: int = 1
@onready var ENEMY_LETTER_2D = preload("res://Entities/Letters/Letter2D/Enemy/EnemyLetter2D.tscn")


func _ready():
	pass
	
	
func before_round():
	var enemy_count = Global.board_scene.enemy_letters.size()
	Global.ui_manager._refill_energy()
	if current_round <=3:
		init_enemies(9)
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
		
		Global.board_scene.enemy_letters.append(enemy)
		Global.sfx_manager.play_sfx("stone1", enemy.position)
		
		var roll = randi() % 6 + 1
		if roll >= 4:
			enemy.coins.visible = true
			enemy._change_coins_count(roll-3)
		
		await get_tree().create_timer(0.3).timeout
		
		
	Global.battle_simulator.save_backups()
	Global.ui_manager.set_ui_enabled(true)

func _letter_has_killed(letter2D):
	if letter2D.properties.current_upgrade == "Assassin":
			var roll = randi() % 2
			match roll:
				0:
					letter2D.properties.update_stats(letter2D.properties.attack+1, letter2D.properties.max_hp)
				1:
					letter2D.properties.update_stats(letter2D.properties.attack, letter2D.properties.max_hp+1)
			letter2D.letterDisplay.update_stats()

func _letter_is_dead(target2D):
	target2D.current_selected_slot.letter_is_taken()
	var grave_copy = null
	
	var death_copy = target2D.duplicate()
	death_copy.modulate.a = 1.0
	death_copy.scale = target2D.scale
	Global.board_scene.add_child(death_copy)
	death_copy.global_position = target2D.global_position
	death_copy.letterDisplay.death_mark.visible = true
	
	if target2D.properties.is_enemy:
		if target2D.coins_count > 0:
			Global.ui_manager.update_coins(target2D.coins_count)
		Global.board_scene.enemy_letters.erase(target2D)
		Global.enemy_deck_disc_scene.append_to_deck(target2D)
	else:
		Global.board_scene.ally_letters.erase(target2D)
		Global.deck_disc_scene.append_to_deck(target2D)
	
	if target2D.properties.current_upgrade == "Pierce":
		grave_copy = target2D.duplicate()
		Global.board_scene.add_child(grave_copy)
		grave_copy.init_letter(target2D.properties.letter, target2D.properties.is_enemy)
		grave_copy.properties.is_an_object = true
		grave_copy.properties.update_stats(0,5)
		grave_copy.letterDisplay.update_stats(0,5)
		grave_copy.global_position = death_copy.global_position
		grave_copy.letterDisplay.death_mark.visible = true
		grave_copy.closest_slot = target2D.current_selected_slot
		grave_copy.visible = false
		grave_copy.is_active = false
		

	await Global.battle_animator._play_death_anim(death_copy)
	death_copy.queue_free()
	if not grave_copy == null:
		grave_copy.snap_to_slot()
		grave_copy.visible = true
		var temp_scale = grave_copy.scale
		grave_copy.scale = Vector2(0, 0)
		var tween := create_tween()
		tween.tween_property(grave_copy, "scale", temp_scale, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	
