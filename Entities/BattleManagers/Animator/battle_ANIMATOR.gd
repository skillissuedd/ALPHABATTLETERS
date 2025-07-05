extends Node
	
func apply_animation_effects(animation_events: Array) -> void:
	for event in animation_events:
		output_log(event)
		match event["type"]:
			"attack":
				await _play_attack_anim(
					event["attacker"],
					event["target"], 
					event["damage"],
				)
		

func output_log(logs: Dictionary) -> void:
	if logs["type"] == "attack":
		var attacker = logs["attacker"].letter
		var target = logs["target"].letter
		print("%s ATTACKED %s FOR %d DAMAGE. CURRENT HP: %d/%d" % [
			attacker,
			target,
			logs["damage"],
			logs["target"].current_hp,
			logs["target"].max_hp
			])


func _play_attack_anim(attacker: Node2D, target: Node2D, damage: int) -> void:
	var attacker2D = attacker.letterParent
	var target2D = target.letterParent
	# Trigger your existing attack animation
	await attacker2D.play_attack_animation(target2D)
	
	# Visuals
	var hit_tween  = create_tween()
	target2D.shake_letter()
	hit_tween.tween_property(target2D, "modulate", Color.RED, 0.2)
	hit_tween.tween_property(target2D, "modulate", Color.WHITE, 0.3)

	# Sound (using your SFX system)
	Global.battle_simulator.apply_calculated_changes_to_ui(target, true)
	await get_tree().create_timer(0.9).timeout
	
	if target.is_dead == true:
		await _play_death_anim(target2D)
		if target.is_enemy:
			Global.board_scene.enemy_letters.erase(target2D)
			Global.enemy_deck_disc_scene.append_to_deck(target2D)
		else:
			Global.board_scene.ally_letters.erase(target2D)
			Global.deck_disc_scene.append_to_deck(target2D)
	
func _play_death_anim(target: Node2D):
	var death_tween = create_tween()
	death_tween.tween_property(target, "modulate:a", 0.0, 1.4)
	death_tween.parallel().tween_property(target, "scale", Vector2(1.5,1.5), 0.4)
	death_tween.tween_property(target, "scale", Vector2(0.1,0.1), 0.4)
	await death_tween.finished
		#letterNode.frame_bar.previous_hp_percent=float(letterCurrentHP*100/letterMaxHP)
		#letterNode.update_frame_bar((float(letter["current_hp"]*100)/float(letterMaxHP)), true)
