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
			"face_attack":
				await _play_face_attack_anim(
					event["attacker"],
					event["damage"],
					false
				)
			"enemy_face_attack":
				await _play_face_attack_anim(
					event["attacker"],
					event["damage"],
					true
				)

	
func _play_face_attack_anim(attacker: LetterUnit, damage: int, is_enemy: bool)-> void:
	var target = null
	var attacker2D = attacker.letterParent
	if is_enemy:
		target = Global.ui_manager.ally_health_bar
	else: 
		target = Global.ui_manager.enemy_health_bar
	await attacker2D.play_attack_animation(target)
	target.get_damaged(damage)
	
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


func _play_attack_anim(attacker: LetterUnit, target: LetterUnit, damage: int) -> void:
	var attacker2D = attacker.letterParent
	var target2D = target.letterParent
	
	# Trigger your existing attack animation
	await attacker2D.play_attack_animation(target2D)
	
	var damage_text = Label.new()
	
	damage_text.text = "-" + str(damage)
	damage_text.add_theme_font_size_override("font_size", 150)
	damage_text.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	damage_text.add_theme_constant_override("outline_size", 15)
	damage_text.add_theme_color_override("font_outline_color", Color.BLACK)
	damage_text.position = target2D.global_position + Vector2(randf_range(-20, 20), -60)
	damage_text.z_index = 100
	
	get_tree().current_scene.add_child(damage_text)
	
	
	var text_tween = create_tween()
	var fly_distance = 80  # Fixed travel distance in pixels
	var fly_angle = randf_range(-PI/4, -3*PI/4)  # Mostly upward (-45° to -135°)
	var fly_time = 0.7
	
	var fly_offset = Vector2(cos(fly_angle), sin(fly_angle)) * fly_distance
	
	text_tween.set_parallel(true)
	text_tween.tween_property(damage_text, "position", damage_text.position + fly_offset, fly_time)
	text_tween.tween_property(damage_text, "scale", Vector2(0.5, 0.5), fly_time)  # Shrink
	text_tween.tween_property(damage_text, "modulate:a", 0.0, fly_time)  # Fade
	text_tween.set_parallel(false)
	text_tween.tween_callback(damage_text.queue_free)
	
	# Visuals
	var hit_tween  = create_tween()
	target2D.shake_letter()
	hit_tween.tween_property(target2D, "modulate", Color.RED, 0.2)
	hit_tween.tween_property(target2D, "modulate", Color.WHITE, 0.3)

	# Sound (using your SFX system)
	Global.battle_simulator.apply_calculated_changes_to_ui(target, true)
	await get_tree().create_timer(0.9).timeout
	
	if target.is_dead:
		target2D.current_selected_slot.letter_is_taken()
		
		var death_copy = target2D.duplicate()
		death_copy.modulate.a = 1.0
		death_copy.scale = target2D.scale
		death_copy.position = target2D.global_position
		get_tree().current_scene.add_child(death_copy)
		
		if target.is_enemy:
			Global.board_scene.enemy_letters.erase(target2D)
			Global.enemy_deck_disc_scene.append_to_deck(target2D)
		else:
			Global.board_scene.ally_letters.erase(target2D)
			Global.deck_disc_scene.append_to_deck(target2D)
			
		await _play_death_anim(death_copy)
		death_copy.queue_free()

func _play_death_anim(target: Node2D):
	var death_tween = create_tween()
	death_tween.set_parallel(true)
	death_tween.tween_property(target, "modulate:a", 0.0, 1.4)
	death_tween.tween_property(target, "scale", Vector2(1.5, 1.5), 0.4)
	death_tween.set_parallel(false)
	death_tween.tween_property(target, "scale", Vector2(0.1,0.1), 0.4)
	await death_tween.finished
		#letterNode.frame_bar.previous_hp_percent=float(letterCurrentHP*100/letterMaxHP)
		#letterNode.update_frame_bar((float(letter["current_hp"]*100)/float(letterMaxHP)), true)
