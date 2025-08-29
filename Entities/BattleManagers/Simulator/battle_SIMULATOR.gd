extends Node
@export var player_backup: Array = []
@export var enemy_backup: Array = []

signal changes_to_ui_applied
signal enemy_actions_finished

### BACKUPS ###

func save_backups():
	for letter in enemy_backup:
		if letter == null:
			enemy_backup.erase(letter)
	
	if GlobalOptions.in_battle == true:
		var backup = Global.board_scene.return_letters_from_the_board()
		
		for letter in backup:
			if letter.is_enemy:
				enemy_backup.append(letter)
			else:
				player_backup.append(letter)

func load_backups():
	for letter in enemy_backup:
		if letter == null:
			enemy_backup.erase(letter)
	
	if GlobalOptions.in_battle == true:
		var new_data = Global.board_scene.return_letters_from_the_board()
		
		for new_letter in new_data:
			for old_letter in enemy_backup:
				if new_letter == old_letter:
					new_letter.current_hp = old_letter.current_hp
					apply_calculated_changes_to_ui(new_letter, true)
				
### PREVIEW ###

func simuilate_preview(letter2D: letter2Dclass):
	load_backups()
	var action_queue = []

	var target = find_target(letter2D, enemy_backup)
	if target == null:
		action_queue.append({
			"type": "face_attack",
			"attacker": letter2D.properties,
			"target": "face",
			"damage": letter2D.properties.attack
			})
	elif target is Dictionary:
		action_queue.append({
			"type": "aoe_attack",
			"attacker": letter2D.properties,
			"targets": target.keys(),
			"damage": target.values()
			})
	else:
		action_queue.append({
			"type": "attack",
			"attacker": letter2D.properties,
			"target": target,
			"damage": letter2D.properties.attack
			})
	calculate_preview_damage(action_queue)

func find_target(letter2D: letter2Dclass, enemy_letters: Array):
	var potential_targets = []
	var attacker = letter2D.properties
	for enemy in enemy_letters:
		if (enemy.grid_x == attacker.grid_x and 
		enemy.grid_y < attacker.grid_y and 
		!enemy.is_dead and 
		enemy.is_enemy != attacker.is_enemy):
			potential_targets.append(enemy)
			
	if potential_targets.is_empty():
		return null
		
	var lowest_target = potential_targets[0]
	
	for target in potential_targets:
		if target.grid_y > lowest_target.grid_y:
			lowest_target = target
	
	if letter2D.properties.element_type == "Water":
		var targets_array = {}
		targets_array[lowest_target] = letter2D.properties.attack
		
		for enemy in enemy_letters:
			if (enemy.grid_y  == lowest_target.grid_y  and
				(enemy.grid_x == lowest_target.grid_x + 1 or
				enemy.grid_x == lowest_target.grid_x - 1) and
				!enemy.is_dead and 
				enemy.is_enemy != attacker.is_enemy):
					targets_array[enemy] = ceili(letter2D.properties.attack * 0.2)
		return targets_array
		
	return lowest_target
	
func calculate_preview_damage(action_queue: Array):
	for action in action_queue:
		if action["type"] == "attack":
			var attacker = action.attacker
			var target = action.target
			if !is_instance_valid(attacker) or attacker.is_dead: 
				print("Invalid attacker")
				continue
			if !is_instance_valid(target) or target.is_dead or !target.is_enemy: 
				print("Invalid target")
				continue
				
			var target_hp = max(0, target.current_hp - action.damage)
			target.letterDisplay.update_stats(target.attack, target_hp)
			target.letterParent.update_frame_bar(target_hp*100/target.max_hp, false)
			if target_hp <= 0:
				target.letterParent.modulate.a = 0.5
				target.letterDisplay.death_mark.visible = true
		
		elif action["type"] == "aoe_attack":
			var attacker = action.attacker
			if !is_instance_valid(attacker) or attacker.is_dead: 
				print("Invalid attacker")
				continue
			
			for i in range(action.targets.size()):
				var target = action.targets[i]
				if !is_instance_valid(target) or target.is_dead or !target.is_enemy: 
					print("Invalid target")
					continue
				
				var damage = action.damage[i]
				var target_hp = max(0, target.current_hp - damage)
				
				target.letterDisplay.update_stats(target.attack, target_hp)
				target.letterParent.update_frame_bar(target_hp*100/target.max_hp, false)
				
				if target_hp <= 0:
					target.letterParent.modulate.a = 0.5
					target.letterDisplay.death_mark.visible = true
			
				
func apply_calculated_changes_to_ui(target: LetterUnit, permanent: bool):
	target.letterDisplay.update_stats(target.attack, target.current_hp)
	target.letterParent.update_frame_bar(target.current_hp*100/target.max_hp, permanent)
	
	if target.current_hp <= 0:
		target.is_dead = true
		target.letterParent.modulate.a = 0.5
		target.letterDisplay.death_mark.visible = true
	else:
		target.is_dead = false
		target.letterParent.modulate.a = 1
		if target.always_dead == false:
			target.letterDisplay.death_mark.visible = false
### PLAYER LETTER ACTIONS ###


func execute_letter_action(letter: Node2D) -> void:
	load_backups()
	player_backup.append(letter.properties)
	var unit = letter.properties
	var target = find_target(letter, enemy_backup)
	var action_queue = []
	if target == null:
		action_queue.append({
			"type": "face_attack",
			"attacker": unit,
			"target": "face",
			"damage": unit["attack"]
			})
	elif target is Dictionary:
		action_queue.append({
			"type": "aoe_attack",
			"attacker": unit,
			"targets": target.keys(),
			"damage": target.values()
			})
	else:
		action_queue.append({
			"type": "attack",
			"attacker": unit,
			"target": target,
			"damage": unit["attack"]
			})
	execute_actions(action_queue)

func execute_actions(action_queue: Array) -> void:
	for action in action_queue:
		var attacker = action.attacker
		if !is_instance_valid(attacker) or attacker.is_dead: 
			print("Invalid attacker")
			continue
				
		if "Weakness" in attacker.status_effects.keys():
			action.damage = int(action.damage*0.4)
		if "Blindness" in attacker.status_effects.keys():
			var roll_blindness = randi() % 10 + 1
			if roll_blindness <= 4:
				action.damage = 0
		if "Panic" in attacker.status_effects.keys():
			action["type"] = "skip_turn"
			action.damage = 0
				
		if action["type"] == "attack": 
			var target = action.target
			if !is_instance_valid(target) or target.is_dead: continue
				
			target.current_hp = max(0, target.current_hp - action.damage)
			target.is_dead = target.current_hp <= 0
			
			
		elif action["type"] == "aoe_attack":
			
			for i in range(action.targets.size()):
				var target = action.targets[i]
				if !is_instance_valid(target) or target.is_dead or !target.is_enemy: 
					print("Invalid target")
					continue
				
				var damage = action.damage[i]
				target.current_hp = max(0, target.current_hp - damage)
				target.is_dead = target.current_hp <= 0
		
	save_backups()
	
	Global.battle_animator.apply_animation_effects(action_queue)
	await Global.battle_animator.animations_completed
		
### ENEMY LETTER ACTIONS ###
		

func simulate_enemy_attacks() -> void:
	load_backups()
	var simulation_data: Array = Global.board_scene.return_letters_from_the_board()
	simulation_data.sort_custom(func(a, b): 
		return a.grid_y > b.grid_y or (a.grid_y == b.grid_y and a.grid_x < b.grid_x))
	
	if simulation_data.is_empty():
		return
	
	for unit in simulation_data:
		var action_queue = []
		if unit.is_dead or not unit.is_enemy: continue
		var target = _find_player_target(unit, Global.board_scene.return_letters_from_the_board())
		
		if target != null:
			action_queue.append({
				"type": "attack",
				"attacker": unit,
				"target": target,
				"damage": unit.attack
				})
		else:
			action_queue.append({
				"type": "enemy_face_attack",
				"attacker": unit,
				"damage": unit.attack
				})
		execute_actions(action_queue)
		await Global.battle_animator.action_is_completed
	enemy_actions_finished.emit()


func _find_player_target(attacker: LetterUnit, all_units: Array):
	var potential_targets = []
	for unit in all_units:
		if (unit.grid_x == attacker.grid_x and 
		unit.grid_y > attacker.grid_y and 
		!unit.is_dead and 
		unit.is_enemy != attacker.is_enemy):
			potential_targets.append(unit)
			
	if potential_targets.is_empty():
		return null

	var lowest_target = potential_targets[0]
	
	for target in potential_targets:
		if target.grid_y < lowest_target.grid_y:
			lowest_target = target

	return lowest_target
			
