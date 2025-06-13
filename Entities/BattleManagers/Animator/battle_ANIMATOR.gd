extends Node

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

func animate_affected_letters(enemy_letters: Array):
	for letter in enemy_letters:
		var letterNode = letter["ref"].letterParent
		var letterDisplay=letterNode.LetterDisplay
		var letterCurrentHP = letterNode.properties.current_hp
		var letterMaxHP = letterNode.properties.max_hp
		letterNode.LetterDisplay.update_stats(letter["attack"], letter["current_hp"])
		#letterNode.shake_letter()
		#Global.sfx_manager.hit_sound()
		#letterNode.modulate = Color(0.7, 0.7, 0.7)
		letterNode.frame_bar.previous_hp_percent=float(letterCurrentHP*100/letterMaxHP)
		letterNode.update_frame_bar((float(letter["current_hp"]*100)/float(letterMaxHP)), false)
		
		if letter["current_hp"] <= 0:
			letterDisplay.death_mark.visible = true
			letterNode.modulate = Color (1, 1, 1, 0.8)
			#Global.sfx_manager.death_sound()
