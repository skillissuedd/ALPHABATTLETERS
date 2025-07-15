extends Node
@export var player_backup: Array = []
@export var enemy_backup: Array = []


### BACKUPS ###


func save_backups():
	var backup = Global.board_scene.prepare_simulation_data()
	#Filtering the backup
	player_backup = backup.filter(func(letter): 
		return not letter["is_enemy"])
	enemy_backup = backup.filter(func(letter): 
		return letter["is_enemy"])
	#Sorting the backup
	player_backup.sort_custom(func(a, b):
		return a["y"] > b["y"] or (a["y"] == b["y"] and a["x"] < b["x"]))
	enemy_backup.sort_custom(func(a, b):
		return a["y"] > b["y"] or (a["y"] == b["y"] and a["x"] < b["x"]))
	
func load_backups():
	var new_data = Global.board_scene.prepare_simulation_data().filter(func(a): 
		return a["is_enemy"])
	
	for new_unit in new_data:
		for old_unit in enemy_backup:
			if new_unit["ref"] == old_unit["ref"] and new_unit["ref"].is_changed == true:
				new_unit["ref"].current_hp = old_unit.current_hp
				new_unit["ref"].is_dead = old_unit.is_dead
				new_unit["ref"].is_changed = false
				apply_calculated_changes_to_ui(new_unit["ref"], false)
				new_unit["ref"].letterParent.modulate = Color(0.9, 0.9, 0.9, 1)
				new_unit["ref"].letterDisplay.death_mark.visible = false
				
func apply_calculated_changes_to_ui(target: LetterUnit, apply: bool):
	target.is_changed = true
	target.letterDisplay.update_stats(target.attack, target.current_hp)
	target.letterParent.update_frame_bar((target.current_hp*100.0)/target.max_hp, apply)
	if target.current_hp == 0:
		target.is_dead = true
		target.letterParent.modulate = Color(0.9, 0.9, 0.9, 0.4)
		target.letterDisplay.death_mark.visible = true


### PREVIEW ###


func simuilate_preview():
	load_backups()
	var simulation_data = Global.board_scene.prepare_simulation_data()
	simulation_data.sort_custom(func(a, b): 
		return a["y"] > b["y"] or (a["y"] == b["y"] and a["x"] < b["x"]))
	var action_queue = []

	for unit in simulation_data:
		if unit.is_dead or unit.is_enemy: continue
		var target = find_target_for_preview(unit, simulation_data)
		if target != null:
			action_queue.append({
				"type": "attack",
				"attacker": unit["ref"],
				"target": target["ref"],
				"damage": unit["attack"]
				})
		else:
			action_queue.append({
				"type": "face_attack",
				"attacker": unit["ref"],
				"target": "face",
				"damage": unit["attack"]
				})
	calculate_prevew_damage(action_queue)

func find_target_for_preview(attacker: Dictionary, all_units: Array):
	var potential_targets = []
	for unit in all_units:
		if (unit["x"] == attacker["x"] and 
		unit["y"] < attacker["y"] and 
		!unit["is_dead"] and 
		unit["is_enemy"] != attacker["is_enemy"]):
			potential_targets.append(unit)
			
	if potential_targets.is_empty():
		return null
	var lowest_target = potential_targets[0]
	
	for target in potential_targets:
		if target["y"] > lowest_target["y"]:
			lowest_target = target
	return lowest_target
	
func calculate_prevew_damage(action_queue: Array):
	for action in action_queue:
		if action["type"] == "attack":
			var attacker = action.attacker
			var target = action.target
			if !is_instance_valid(attacker) or attacker.is_dead: continue
			if !is_instance_valid(target) or target.is_dead or !target.is_enemy: continue
			target.current_hp = max(0, target.current_hp - action.damage)
			target.is_changed = true
			if target.current_hp == 0:
				target.is_dead = true
			apply_calculated_changes_to_ui(target, false)
				
				
### PLAYER LETTER ACTIONS ###


func execute_letter_action(letter: Node2D) -> void:
	load_backups()
	player_backup.append(letter.properties)
	var unit = letterunit_to_sim_data(letter.properties)
	var target = find_target_for_preview(unit, enemy_backup)
	var action_queue = []
	if target != null:
		action_queue.append({
			"type": "attack",
			"attacker": unit["ref"],
			"target": target["ref"],
			"damage": unit["attack"]
			})
	else:
		action_queue.append({
			"type": "face_attack",
			"attacker": unit["ref"],
			"target": "face",
			"damage": unit["attack"]
			})
	execute_actions(action_queue)

func execute_actions(action_queue: Array) -> void:
	for action in action_queue:
		
		if action["type"] == "attack":
			var attacker = action.attacker
			var target = action.target
			if !is_instance_valid(attacker) or attacker.is_dead: continue
			if !is_instance_valid(target) or target.is_dead: continue
			target.current_hp = max(0, target.current_hp - action.damage)
			target.is_dead = target.current_hp <= 0
			
		elif action["type"] == "face_attack":
			var attacker = action.attacker
			if !is_instance_valid(attacker) or attacker.is_dead: continue
			
	save_backups()
	Global.battle_animator.apply_animation_effects(action_queue)
		
		
### ENEMY LETTER ACTIONS ###
		

func simulate_enemy_attacks(simulation_data: Array) -> void:
	load_backups()
	simulation_data.sort_custom(func(a, b): 
		return a["y"] > b["y"] or (a["y"] == b["y"] and a["x"] < b["x"]))
		
	var action_queue = []
	for unit in simulation_data:
		if unit.is_dead or not unit.is_enemy: continue
		var target = _find_player_target(unit, simulation_data)
		
		if target != null:
			action_queue.append({
				"type": "attack",
				"attacker": unit["ref"],
				"target": target["ref"],
				"damage": unit["attack"]
				})
		else:
			action_queue.append({
				"type": "enemy_face_attack",
				"attacker": unit["ref"],
				"damage": unit["attack"]
				})
	execute_actions(action_queue)


func _find_player_target(attacker: Dictionary, all_units: Array):
	var potential_targets = []
	for unit in all_units:
		if (unit["x"] == attacker["x"] and 
		unit["y"] > attacker["y"] and 
		!unit["is_dead"] and 
		unit["is_enemy"] != attacker["is_enemy"]):
			potential_targets.append(unit)
			
	#print (potential_targets)
	if potential_targets.is_empty():
		return null

	var lowest_target = potential_targets[0]
	
	for target in potential_targets:
		if target["y"] < lowest_target["y"]:
			lowest_target = target

	return lowest_target
			

			
func letterunit_to_sim_data(properties: LetterUnit) -> Dictionary:
	return {
		"ref": properties,
		"letter": properties.letter,
		"x": properties.grid_x,
		"y": properties.grid_y,
		"current_hp": properties.current_hp,
		"max_hp": properties.max_hp,
		"attack": properties.attack,
		"is_enemy": properties.is_enemy,
		"is_dead": properties.is_dead
	}
