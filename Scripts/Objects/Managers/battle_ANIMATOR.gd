extends Node

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

func animate_affected_letters(enemy_letters: Array):
	for letter in enemy_letters:
		var letterNode = letter["ref"].letterParent
		var letterDisplay=letterNode.LetterDisplay
		letterDisplay.update_stats(letter["attack"], letter["hp"])
		#letterNode.shake_letter()
		#Global.sfx_manager.hit_sound()
		letterNode.modulate = Color(0.5, 0.5, 0.5)
		letterNode.update_frame_bar(float(letter["hp"]))
		if letter["hp"] <= 0:
			letterNode.modulate = Color(0.2, 0.2, 0.2)
			Global.sfx_manager.death_sound()
