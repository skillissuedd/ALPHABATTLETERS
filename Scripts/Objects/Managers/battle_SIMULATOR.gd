extends Node
var player_backup = null
var enemy_backup = null



func letterunit_to_sim_data(letter_unit: LetterUnit) -> Dictionary:
	return {
		"ref": letter_unit,
		"x": letter_unit.grid_x,
		"y": letter_unit.grid_y,
		"hp": letter_unit.hp,
		"attack": letter_unit.attack,
		"is_enemy": letter_unit.is_enemy,
		"is_dead": letter_unit.is_dead
	}
	
func create_backup(letter_array: Array) -> Dictionary:
	var backup := {}
	for letter in letter_array:
		var unit = letter["ref"]
		backup[unit] = {
			"hp": unit.hp,
			"is_dead": unit.is_dead,
			"attack": unit.attack
		}
	return backup
	
func restore_backup(backup: Dictionary):
	for unit in backup.keys():
		unit.hp = backup[unit]["hp"]
		print(unit.hp)
		unit.is_dead = backup[unit]["is_dead"]
		unit.letterParent.LetterDisplay.update_stats(backup[unit]["attack"], backup[unit]["hp"])
		unit.letterParent.modulate = Color(1,1,1)
		unit.letterParent.update_frame_bar(float(backup[unit]["hp"]))
func simulate_battle(player_letters: Array, enemy_letters: Array, apply: bool = false) -> Dictionary:
	# Organize enemies by position for quick lookup
	if !apply:
		restore_backup(player_backup)
		restore_backup(enemy_backup)
	var sim_player = {}
	var sim_enemy = {}
	var letters_to_animate =[]
	for letter in player_letters:
		var sim =letterunit_to_sim_data(letter["ref"])
		var key = Vector2i(sim["x"], sim["y"])
		sim_player[key] = sim
		
	for letter in enemy_letters:
		var sim = letterunit_to_sim_data(letter["ref"])
		var key = Vector2i(sim["x"], sim["y"])
		sim_enemy[key] = sim
	
	var enemy_grid := {}
	for enemy in enemy_letters:
		var pos = Vector2i(enemy["x"], enemy["y"])
		enemy_grid[pos] = enemy

	# Apply attacks from each player letter
	for ally in sim_player.values():
		var same_column_enemies = sim_enemy.values().filter(func(e): return e["x"] == ally["x"])
		var current_target = same_column_enemies[0] if same_column_enemies.size() > 0 else null
		for enemy in same_column_enemies:
			if (enemy["y"] > current_target["y"] and enemy["y"] <ally ["y"]) or current_target == null:
				current_target = enemy
		if current_target:
			current_target["hp"] -= ally["attack"]
			letters_to_animate.append(current_target)
			if current_target["hp"] <= 0:
				current_target["is_dead"] = true
			break
	Global.battle_animator.animate_affected_letters(letters_to_animate)
	
	
	
# Update real LetterUnits (refs)
	if apply:
		for player_letter in player_letters:
			attack(player_letter)

	return {
	"player_alive": sim_player.values().filter(func(p): return !p["is_dead"]).size(),
	"enemy_alive": sim_enemy.values().filter(func(e): return !e["is_dead"]).size()
}

func attack(letter_unit: LetterUnit):
	pass
	
func run_simulation():
	var sim_data = Global.board_scene.prepare_simulation_data()
	if player_backup == null:
		player_backup = create_backup(sim_data["player_letters"])
	if enemy_backup == null:
		enemy_backup = create_backup(sim_data["enemy_letters"])
	var sim_result = simulate_battle(sim_data["player_letters"], sim_data["enemy_letters"], false)
