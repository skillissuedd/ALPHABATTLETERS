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
	
func apply_animation_effects(animation_events: Array) -> void:
	for event in animation_events:
		#output_log(event)
		match event["type"]:
			"attack":
				await _play_attack_anim(
					event["attacker"],
					event["target"], 
					event["damage"],
					event.get("killed", false)  # Safe getter
				)
				
func output_log(log: Dictionary) -> void:
	if log["type"] == "attack":
		var attacker = log["attacker"].letter
		var target = log["target"].letter
		print("%s ATTACKED %s FOR %d DAMAGE. CURRENT HP: %d/%d" % [
			attacker,
			target,
			log["damage"],
			log["target"].current_hp,
			log["target"].max_hp
			])


func _play_attack_anim(attacker: Node2D, target: Node2D, damage: int, killed: bool) -> void:
	# 1. Trigger your existing attack animation
	attacker.letterParent.play_attack_animation()
	
	# Visuals
	var hit_tween  = create_tween()
	hit_tween.tween_property(target, "modulate", Color.RED, 0.1)
	hit_tween.tween_property(target, "modulate", Color.WHITE, 0.3)
	
	# 3. Damage display (using your existing system)
	target.letterParent.LetterDisplay.update_stats(target.attack, target.current_hp)
	
	# 4. Sound (using your SFX system)
	Global.sfx_manager.play_sfx("hit1", target.global_position)
	
	if killed:
		await _play_death_anim(target)
	else:
		await get_tree().create_timer(0.9).timeout  # Basic attack duration

func _play_death_anim(target: Node2D):
	var death_tween = create_tween()
	death_tween.tween_property(target, "modulate:a", 0.0, 0.4)
	death_tween.parallel().tween_property(target, "scale", Vector2(1.5,1.5), 0.2)
	death_tween.tween_property(target, "scale", Vector2(0.1,0.1), 0.2)
	await death_tween.finished

func animate_affected_letters(enemy_letters: Array):
	for letter in enemy_letters:
		var letterNode = letter["ref"].letterParent
		var letterDisplay=letterNode.LetterDisplay
		var letterCurrentHP = letterNode.properties.current_hp
		var letterMaxHP = letterNode.properties.max_hp
		letterNode.LetterDisplay.update_stats(letter["attack"], letter["current_hp"])
		#letterNode.shake_letter()
		Global.sfx_manager.hit_sound()
		#letterNode.modulate = Color(0.7, 0.7, 0.7)
		letterNode.frame_bar.previous_hp_percent=float(letterCurrentHP*100/letterMaxHP)
		letterNode.update_frame_bar((float(letter["current_hp"]*100)/float(letterMaxHP)), false)
		
		if letter["current_hp"] <= 0:
			letterDisplay.death_mark.visible = true
			letterNode.modulate = Color (1, 1, 1, 0.8)
			#Global.sfx_manager.death_sound()
