extends Node
var player_backup = null
var enemy_backup = null


#func run_simulation(apply: bool):
	#var sim_data = Global.board_scene.prepare_simulation_data()
	#var allies = sim_data.filter(func(l): return !l["is_enemy"])
	#player_backup = create_backup(allies)
	#var enemies = sim_data.filter(func(l): return l["is_enemy"])
	#enemy_backup = create_backup(enemies)
	#simulate_battle(sim_data, apply)

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
	
func load_backups():
	if player_backup:
		restore_backup(player_backup)
	if enemy_backup:
		restore_backup(enemy_backup)
	
func create_backup(letter_data_array: Array):
	if letter_data_array == null:
		return "This array is empty"
	
	var backup := {}
	for letter_data in letter_data_array:
		backup[letter_data] = {
			"current_hp": letter_data.current_hp,
			"max_hp": letter_data.max_hp,
			"is_dead": letter_data.is_dead,
			"attack": letter_data.attack
		}
	return backup

func restore_backup(backup: Dictionary):
	for unit in backup.keys():
		if !is_instance_valid(unit):
			continue
		unit.current_hp = backup[unit]["current_hp"]
		unit.is_dead = backup[unit]["is_dead"]
		if !unit.is_dead:
			unit["ref"].letterParent.LetterDisplay.death_mark.visible = false
			unit["ref"].letterParent.modulate = Color (1, 1, 1, 1)
		unit["ref"].letterParent.LetterDisplay.update_stats(backup[unit]["attack"], backup[unit]["current_hp"])
		unit["ref"].letterParent.update_frame_bar(100, false)
		

func simulate_battle(simulation_data: Array, apply: bool = false) -> void:
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
	if apply:
		execute_actions(action_queue)
		
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
	 
func execute_actions(action_queue: Array) -> void:
	for action in action_queue:
		var attacker = action.attacker
		var target = action.target
		if !is_instance_valid(attacker) or attacker.is_dead: continue
		if !is_instance_valid(target) or target.is_dead: continue
		
		action.target.current_hp = max(0, action.target.current_hp - action.damage)
		action.target.is_dead = action.target.current_hp <= 0
			
		Global.battle_animator.apply_animation_effects(action_queue)
