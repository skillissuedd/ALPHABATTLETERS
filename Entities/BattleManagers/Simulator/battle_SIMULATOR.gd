extends Node
var player_backup: Array = []
var enemy_backup: Array = []

	
func load_backups():
	var new_data = Global.board_scene.prepare_simulation_data().filter(func(a): 
		return a["is_enemy"])
	
	for new_unit in new_data:
		for old_unit in enemy_backup:
			if new_unit["ref"] == old_unit["ref"] and new_unit["ref"].current_hp != old_unit["current_hp"]:
				# Replace NEW with OLD values
				new_unit["ref"].current_hp = old_unit["current_hp"]
				new_unit["ref"].is_dead = old_unit["is_dead"]
				new_unit["ref"].attack = old_unit["attack"]
				new_unit["ref"].letterParent.modulate = Color.WHITE
				new_unit["ref"].letterDisplay.death_mark.visible = false
				new_unit["ref"].letterDisplay.update_stats(
				new_unit["ref"].attack,
				new_unit["ref"].current_hp
				)
			
		
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

func run_simulation(apply: bool):
	simulate_battle(Global.board_scene.prepare_simulation_data(), apply)

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
	

func letter_action(letter: Node2D):
	var unit = letterunit_to_sim_data(letter.properties)
	var target = _find_valid_targets(unit, enemy_backup)
	print (target)

func simulate_battle(simulation_data: Array, apply: bool) -> void:
	load_backups()
	simulation_data.sort_custom(func(a, b): 
		return a["y"] > b["y"] or (a["y"] == b["y"] and a["x"] < b["x"]))
		
	var action_queue = []

	for unit in simulation_data:
		if unit.is_dead: continue
		var target = _find_valid_targets(unit, simulation_data)
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
	if apply:
		execute_actions(action_queue)
	else:
		calculate_damage(action_queue)
			
func calculate_damage(action_queue: Array):
	for action in action_queue:
		if action["type"] == "attack":
			var attacker = action.attacker
			var target = action.target
			if !is_instance_valid(attacker) or attacker.is_dead: continue
			if !is_instance_valid(target) or target.is_dead: continue
			target.current_hp = max(0, target.current_hp - action.damage)
			target.letterDisplay.update_stats(target.attack, target.current_hp)
			if target.current_hp == 0:
				target.is_dead == true
				target.letterParent.modulate = Color(0.9, 0.9, 0.9, 0.8)
				target.letterDisplay.death_mark.visible = true
		
	
func execute_actions(action_queue: Array) -> void:
	for action in action_queue:
		var attacker = action.attacker
		var target = action.target
		if !is_instance_valid(attacker) or attacker.is_dead: continue
		if !is_instance_valid(target) or target.is_dead: continue
		
		action.target.current_hp = max(0, action.target.current_hp - action.damage)
		action.target.is_dead = action.target.current_hp <= 0
			
		Global.battle_animator.apply_animation_effects(action_queue)

func _find_valid_targets(attacker: Dictionary, all_units: Array):
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
