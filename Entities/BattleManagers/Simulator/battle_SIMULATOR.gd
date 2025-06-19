extends Node
var player_backup = null
var enemy_backup = null



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

func load_backups():
	if player_backup:
		restore_backup(player_backup)
	if enemy_backup:
		restore_backup(enemy_backup)


func restore_backup(backup: Dictionary):
	for unit in backup.keys():
		unit.current_hp = backup[unit]["current_hp"]
		unit.is_dead = backup[unit]["is_dead"]
		if !unit.is_dead:
			unit["ref"].letterParent.LetterDisplay.death_mark.visible = false
			unit["ref"].letterParent.modulate = Color (1, 1, 1, 1)
		unit["ref"].letterParent.LetterDisplay.update_stats(backup[unit]["attack"], backup[unit]["current_hp"])
		unit["ref"].letterParent.update_frame_bar(100, false)
		

func simulate_battle(simulation_data: Array, apply: bool = false) -> Dictionary:
	#1. Load backups to restore letter states
	if !apply:
		load_backups()
	
	#2. Declaring arrays
	var sim_letters: Array = []
	var letters_to_animate: Array = []
	var action_logs: Array = []
	var same_column_targets: Array = []
	
	#3. Filling sim_letters with letter sim data in dict format
	for letter in simulation_data:
		var sim =letterunit_to_sim_data(letter["ref"])
		sim_letters.append(sim)
		
	#4. Sorting all the letters left->right, down->up	
	sim_letters.sort_custom(func(a, b):
		return a["y"] > b["y"] or (a["y"] == b["y"] and a["x"] < b["x"]))
		
	#6. Cycling through every letter to act
	for acting_letter in sim_letters:
		
		#6.1 Ally attack logic
		if acting_letter["is_enemy"] == false:
			same_column_targets = sim_letters.filter(
				func(e):
					return (
						e["x"] == acting_letter["x"] and
						e["y"] < acting_letter["y"] and 
						not e["is_dead"] and 
						not e["is_enemy"] == acting_letter["is_enemy"]
						)
					)
			same_column_targets.sort_custom(func(a, b): return a["y"] > b["y"])
		#6.2 Enemy attack logic
		else:
			same_column_targets = sim_letters.filter(
				func(e):
					return (
						e["x"] == acting_letter["x"] and
						e["y"] > acting_letter["y"] and 
						not e["is_dead"] and 
						not e["is_enemy"] == acting_letter["is_enemy"]
						)
					)
			same_column_targets.sort_custom(func(a, b): return a["y"] < b["y"])
			
		#6.3 Picking the current target: closest if more than 1, face if none.
		var current_target = same_column_targets[0] if same_column_targets.size() > 0 else null
			
		#6.4 Ally: Cycling through same column targets to get the nearest alive target
		if acting_letter["is_enemy"] == false:
			for enemy in same_column_targets:
				if (enemy["y"] > current_target["y"] and !enemy["is_dead"]):
					current_target = enemy
	
		#6.5 Enemy: Cycling through same column targets to get the nearest alive target
		else:
			for enemy in same_column_targets:
				if (enemy["y"] < current_target["y"] and !enemy["is_dead"]):
					current_target = enemy
			
		#6.6 Logging the attack action on selected target
		if current_target:
			action_logs.append({
				"type": "attack",
				"attacker": acting_letter["ref"],
				"target": current_target["ref"],
				"damage": acting_letter["attack"],
				"timestamp": Time.get_ticks_msec()
				})
					
			#6.7 Applying the damage
			current_target["current_hp"] -= acting_letter["attack"]
			
			#6.8 Checking if target is dead
			if current_target["current_hp"] <= 0:
				current_target["is_dead"] = true
				current_target["current_hp"] = 0
				#6.9 Logging the target death
				action_logs.append({
					"type": "death",
					"target": current_target["ref"],
					"timestamp": Time.get_ticks_msec()
					})
	
# Update real LetterUnits (refs)
	#if apply:
		#for player_letter in player_letters:
			#attack(player_letter)

	return {
	#"player_alive": sim_player.values().filter(func(p): return !p["is_dead"]).size(),
	#"enemy_alive": sim_enemy.values().filter(func(e): return !e["is_dead"]).size()
}
	
func run_simulation():
	var sim_data = Global.board_scene.prepare_simulation_data()
	if player_backup == null:
		var allies = sim_data.filter(func(l): return !l["is_enemy"])
		player_backup = create_backup(allies)
	if enemy_backup == null:
		var enemies = sim_data.filter(func(l): return l["is_enemy"])
		enemy_backup = create_backup(enemies)
	simulate_battle(sim_data, false)
