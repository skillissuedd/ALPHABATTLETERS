extends Node

func letterunit_to_sim_data(letter_unit: LetterUnit) -> Dictionary:
	return {
		"ref": letter_unit,
		"letter": letter_unit.letter,
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
		var letterPrevHP = int(letterDisplay.HP_label.text)
		var letterMaxHP = int(letterNode.max_hp)
		letterDisplay.update_stats(letter["attack"], letter["hp"])
		#letterNode.shake_letter()
		#Global.sfx_manager.hit_sound()
		#letterNode.modulate = Color(0.7, 0.7, 0.7)
		letterNode.frame_bar.previous_hp_percent=float(letterPrevHP*100/letterMaxHP)
		letterNode.update_frame_bar((float(letter["hp"]*100)/float(letterMaxHP)), false)
		
		if letter["hp"] <= 0:
			letterDisplay.death_mark.visible = true
			letterNode.modulate = Color (1, 1, 1, 0.8)
			#Global.sfx_manager.death_sound()
