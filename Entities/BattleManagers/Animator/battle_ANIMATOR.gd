extends Node
signal animations_completed
signal action_is_completed

	
func apply_animation_effects(animation_events: Array) -> void:
	for event in animation_events:
		match event["type"]:
			"attack":
				await _play_attack_anim(
					event["attacker"],
					event["target"], 
					event["damage"],
				)
			"aoe_attack":
				await _play_aoe_attack_anim(
					event["attacker"],
					event["targets"], 
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
			"skip_turn":
				await get_tree().process_frame
				
		if Global.ui_manager.enemy_health_bar.current_health <=0:
			await Global.ui_manager.enemy_health_bar.healthbar_is_dead
			GlobalSignals.emit_round_is_won()
			action_is_completed.emit()
			animations_completed.emit()
			return
		elif Global.ui_manager.ally_health_bar.current_health <=0:
			await Global.ui_manager.ally_health_bar.healthbar_is_dead
			action_is_completed.emit()
			animations_completed.emit()
			get_tree().change_scene_to_file("res://prototype/gameover/gameover.tscn")
			return
			
		action_is_completed.emit()
		
	animations_completed.emit()

func _play_aoe_attack_anim(attacker: LetterUnit, targets: Array, damage: Array) -> void:

	var attacker2D = attacker.letterParent
	var maintarget = targets[0].letterParent
	
	# Trigger your existing attack animation
	await attacker2D.play_attack_animation(maintarget)
	
	for i in targets.size():
		
		var damage_text = Label.new()
		
		get_tree().current_scene.add_child(damage_text)
		
		damage_text.text = "-" + str(damage[i])
		damage_text.add_theme_font_size_override("font_size", 150)
		damage_text.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		damage_text.add_theme_constant_override("outline_size", 15)
		damage_text.add_theme_color_override("font_outline_color", Color.BLACK)
		damage_text.global_position = targets[i].letterParent.global_position + Vector2(randf_range(-20, 20), -100)
		damage_text.z_index = 100
		damage_text.scale = Vector2(0,0)
		
		var text_tween = create_tween()
		var fly_time = 0.4
		
		text_tween.tween_property(damage_text, "scale", Vector2(1, 1), 0.1) 
		text_tween.tween_property(damage_text, "position", damage_text.position, fly_time)
		text_tween.tween_property(damage_text, "scale", Vector2(0.5, 0.5), fly_time)  # Shrink
		text_tween.tween_property(damage_text, "modulate:a", 0.0, fly_time)  # Fade
		text_tween.tween_callback(damage_text.queue_free)
		
		# Visuals
		var hit_tween  = create_tween()
		targets[i].letterParent.shake_letter()
		hit_tween.tween_property(targets[i].letterParent, "modulate", Color.RED, 0.2)
		hit_tween.tween_property(targets[i].letterParent, "modulate", Color.WHITE, 0.3)

		Global.battle_simulator.apply_calculated_changes_to_ui(targets[i], true)
		Global.battle_manager.letter_got_hit_by(targets[i].letterParent, attacker2D)
	
		if targets[i].is_dead:
			Global.battle_manager._letter_has_killed(attacker2D, targets[i])
			Global.battle_manager._letter_is_dead(targets[i].letterParent)


func _play_face_attack_anim(attacker: LetterUnit, damage: int, is_enemy: bool)-> void:
	var target = null
	var attacker2D = attacker.letterParent
	if is_enemy:
		target = Global.ui_manager.ally_health_bar
	else: 
		target = Global.ui_manager.enemy_health_bar
		
	if damage >= int(target.current_health):
		Global.hand_scene.set_hand_enabled(false)
	await attacker2D.play_attack_animation(target)
	await target.get_damaged(damage)
	
		
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
	
	if int(target2D.letterDisplay.HP_label.text) <=0:
		await _play_face_attack_anim(attacker, damage, attacker.is_enemy)
		return
	# Trigger your existing attack animation
	await attacker2D.play_attack_animation(target2D)
	
	var damage_text = Label.new()
	
	get_tree().current_scene.add_child(damage_text)
	
	damage_text.text = "-" + str(damage)
	damage_text.add_theme_font_size_override("font_size", 150)
	damage_text.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	damage_text.add_theme_constant_override("outline_size", 15)
	damage_text.add_theme_color_override("font_outline_color", Color.BLACK)
	damage_text.global_position = target2D.global_position + Vector2(randf_range(-20, 20), -100)
	damage_text.z_index = 100
	
	
	var text_tween = create_tween()
	var fly_time = 0.7
	
	text_tween.set_parallel(true)
	text_tween.tween_property(damage_text, "position", damage_text.position, fly_time)
	text_tween.tween_property(damage_text, "scale", Vector2(0.5, 0.5), fly_time)  # Shrink
	text_tween.tween_property(damage_text, "modulate:a", 0.0, fly_time)  # Fade
	text_tween.set_parallel(false)
	text_tween.tween_callback(damage_text.queue_free)
	
	# Visuals
	var hit_tween  = create_tween()
	hit_tween.tween_property(target2D, "modulate", Color.RED, 0.2)
	hit_tween.tween_property(target2D, "modulate", Color.WHITE, 0.3)
	hit_tween.finished
	target2D.shake_letter()
	
	Global.battle_simulator.apply_calculated_changes_to_ui(target, true)
	
	Global.battle_manager.letter_got_hit_by(target2D, attacker2D)
	await target.letterParent.frame_bar.animation_finished
	
	if target.is_dead:
		Global.battle_manager._letter_has_killed(attacker2D, target2D)
		Global.battle_manager._letter_is_dead(target2D)

func _play_death_anim(target: Node2D):
	var scale_temp = target.scale
	var death_tween = create_tween()
	target.frame_bar.visible = false
	death_tween.set_parallel(true)
	death_tween.tween_property(target, "modulate:a", 0.0, 0.4)
	death_tween.tween_property(target, "scale", Vector2(1.5, 1.5), 0.4)
	death_tween.set_parallel(false)
	death_tween.tween_property(target, "scale", Vector2(0.1,0.1), 0.4)
	await death_tween.finished
	target.scale = scale_temp
	target.modulate.a = 1
