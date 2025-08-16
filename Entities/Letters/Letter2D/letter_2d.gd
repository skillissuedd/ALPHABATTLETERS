extends Sprite2D
class_name letter2Dclass

#Physics variables
#SCALE
var current_goal_scale: Vector2 = Vector2(0.4, 0.4)
var scale_tween: Tween
var scale_mod:float = 2
var max_size := Vector2(200, 200)

#DRAGGING
@export var mouse_in: bool = false
@export var is_dragging: bool = false
@export var is_active: bool = true

#ROTATION
@export var float_amplitude := randf_range(1.0, 12.0)    # How much to rotate (in degrees)
@export var float_speed := 1.0        # How fast to rotate
var _float_time := 0.0

#SLOTS AND POSITION
var current_selected_slot = null
var overlapping_slots = []
var closest_slot = null
var closest_dist = null
var dist = null
var position_in_hand = Vector2()
var is_outside = false

#Letter info and stats
var letter_stats_path = "res://Entities/Letters/LetterStats/letter_stats.tres"
var letter_stats = load(letter_stats_path)

#References
@onready var letterDisplay = $Display/LetterDisplay
@onready var properties = $LetterUnit
@onready var frame_bar = $FrameBar/FrameBar

#SHADOW
@export var light_pos:Vector2 = Vector2(1920,1080)
@export var max_distance:float = 1.0  # Reduced from 15

	
func _process(delta: float) -> void:
	
	if not is_dragging and is_active:
		_float_time += delta * float_speed
		rotation_degrees = sin(_float_time) * float_amplitude
		
	$Shadow.global_position = global_position + Vector2(10, -20)
	
	#var base_scale:float = 0.8 + (0.2 * distance_ratio)

func init_letter(character: String, is_enemy: bool):
	var stats = letter_stats.get_stats(character)
	var max_hp = stats["hp"]
	var current_atk = stats["atk"]
	var element = letter_stats.get_element_for_letter(character)

	if is_enemy == true:
		max_hp+=3
		current_atk+=1
		element = "Neutral"
	update_element_style(element)
	properties.initialize(character, is_enemy, current_atk, max_hp, element)
	properties.letterDisplay = letterDisplay
	
	letterDisplay.properties = properties
	letterDisplay.change_letter(character)
	letterDisplay.update_stats()
		
	#DEFAULT FRAME COLORS
	
	if not is_enemy:
		frame_bar.border_color = Color.LIME_GREEN
	else:
		frame_bar.border_color = Color.DARK_RED
		
func _on_area_2d_mouse_entered() -> void:
	mouse_in = true
	_change_scale(Vector2(0.6 + scale_mod, 0.6 + scale_mod))
	

func _on_area_2d_mouse_exited() -> void:
	mouse_in = false
	_change_scale(Vector2(0.3 + scale_mod, 0.3 + scale_mod))
	
	
func update_element_style(current_element: String):
	if letterDisplay:
		letterDisplay.change_element(current_element)
	match current_element:
		"Water":
			self.texture=load("res://Entities/Letters/Letter2D/Elements/Water/letterTileWater.png")
		"Fire":
			self.texture=load("res://Entities/Letters/Letter2D/Elements/Fire/letterTileFire.png")
		"Electricity":
			self.texture=load("res://Entities/Letters/Letter2D/Elements/Electricity/letterTileElectricity.png")
		"Earth":
			self.texture=load("res://Entities/Letters/Letter2D/Elements/Earth/woodTile1.jpg")
		"Neutral":
			self.texture=load("res://Entities/Letters/Letter2D/Elements/EnemyElement/enemyElement.png")
			self_modulate = Color(0.9, 0.9, 0.9) 


func _on_area_2d_area_entered(area: Area2D) -> void:
	if Global.board_scene:
		if area.is_in_group("slots"):
			if not area.is_selected:
				overlapping_slots.append(area)
				
			elif char(properties.letter.unicode_at(0)-1) == area.current_letter.properties.letter:
				if not area.current_letter.properties.is_enemy:
					overlapping_slots.append(area)
					
	elif area is slot_class:
		closest_slot = area
		
func _on_area_2d_area_exited(area: Area2D) -> void:
	if Global.board_scene:
		if area.is_in_group("slots"):
			area.is_not_hovered()
			overlapping_slots.erase(area)
		if overlapping_slots.is_empty():
			Global.battle_simulator.load_backups()
			
	elif area is slot_class:
		closest_slot = null
		
#############################
#### ANIMATIONS #########
#############################

func update_frame_bar(ratio:float, permanent: bool):
	if permanent:
		frame_bar.set_hp_percent(ratio)
	else: 
		frame_bar.set_temp_percent(ratio)


	
func play_attack_animation(target):
	#COPYING
	var end_pos = target.global_position
	var original_label = letterDisplay.letter_label
	var attack_label = original_label.duplicate()
	attack_label.name = "attack_label"
	add_child(attack_label)
	
	#POSITION AND SIZE
	attack_label.global_position = original_label.global_position
	attack_label.scale = original_label.scale * 0.7
	attack_label.scale.y = -abs(attack_label.scale.y)
	attack_label.z_index=1

	#GLOWING
	attack_label.modulate = Color(1.0, 1.0, 0.5, 1.0) 
	
	end_pos = Vector2(attack_label.global_position.x, target.global_position.y)
	
	var tween = create_tween()
	tween.tween_property(attack_label, "global_position", end_pos, 0.7)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
		
	await tween.finished
	
	Global.sfx_manager.play_sfx("hit1", global_position)
	
	tween = create_tween()
	tween.tween_property(attack_label, "modulate:a", 0, 0.2)
	await tween.finished
	attack_label.queue_free()
	
	
func shake_letter(strength := 5.0, duration := 0.3, shakes := 15):
	var tween := get_tree().create_tween()
	var original_pos := position
	var time_per_shake := duration / float(shakes)

	for i in range(shakes):
		offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		var target_pos := original_pos + offset

		tween.tween_property(
			self,
			"position",
			target_pos,
			time_per_shake / 2.0
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		tween.tween_property(
			self,
			"position",
			original_pos,
			time_per_shake / 2.0
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _change_scale(desired_scale: Vector2):
	if desired_scale == current_goal_scale:
		return
	
	if scale_tween:
		scale_tween.kill()
		scale_tween = null
	self.set_scale(self.scale)
	scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	scale_tween.tween_property(self, "scale", desired_scale, 0.225)
	
	current_goal_scale = desired_scale

var last_pos: Vector2
var max_card_rotation: float = 152.5
func _set_rotation(delta: float) -> void:
	var desired_rotation: float = clamp((global_position - last_pos).x*0.85, -max_card_rotation, max_card_rotation)
	self.rotation_degrees = lerp(self.rotation_degrees, desired_rotation, 12.0*delta)
	
	last_pos = global_position

#############################
#### MOVEMENT LOGIC #########
#############################

func drag_logic(delta: float) -> void:
	
	#Letter dragging logic
	if not is_active:
		_set_resting_state(delta)
		return
		
	
	var can_drag := (mouse_in or is_dragging) and (Mousebrain.node_being_dragged == null or Mousebrain.node_being_dragged == self)
	if not can_drag:
		_change_scale(Vector2(0.1+scale_mod, 0.1+scale_mod))
		return
			
	if Input.is_action_pressed("click"):
		if properties.is_enemy:
			return
			
		global_position = lerp(global_position, get_global_mouse_position(), 22.0*delta)
		#SIZE WHEN LETTER IS DRAGGED
		_change_scale(Vector2(0.8+scale_mod, 0.8+scale_mod))
		_set_rotation(delta)
		z_index = 100
		
		if not is_dragging:  # Only play sound when dragging starts
			is_dragging = true
			Global.sfx_manager.play_sfx("letterTaken", global_position)
		Mousebrain.node_being_dragged = self
		
		if get_parent() == current_selected_slot:
			Global.board_scene.ally_letters.erase(self)
			current_selected_slot.letter_is_taken()
		else:
			Global.hand_scene.letter_row.erase(self)
			Global.hand_scene.arrange_hand()
			
	#RELEASING THE LETTER
	
	else:
		is_dragging = false
		if mouse_in:
			z_index = 100
		else: 
			z_index = 1
		rotation_degrees = lerp(rotation_degrees, 0.0, 22.0*delta)
		
		if Mousebrain.node_being_dragged == self:
			Mousebrain.node_being_dragged = null
			Global.sfx_manager.play_sfx("letterPlaced", global_position)
			Global.ui_manager.energy_preview.visible = false
			snap_to_parent()

#WHEN LETTER IS AT REST
func _set_resting_state(delta: float) -> void:
	_change_scale(Vector2(0.1+scale_mod, 0.1+scale_mod))
	self.z_index = 1
	self.rotation_degrees = lerp(self.rotation_degrees, 0.0, 22.0*delta)

func snap_to_parent():
	if not overlapping_slots.is_empty():
		snap_to_slot()
	elif GlobalOptions.selecting_upgrade and closest_slot:
		snap_to_upgrade_slot()
	else:
		Global.hand_scene.snap_to_hand(self)
		if Global.battle_simulator:
			Global.battle_simulator.load_backups()

func snap_to_upgrade_slot():
	if closest_slot:
		global_position = closest_slot.global_position
		current_selected_slot = closest_slot
		Global.hand_scene.letter_row.erase(self)
		current_selected_slot.letter_is_placed(self)
		self.rotation_degrees = 0
		is_active = false
		
func snap_to_slot():
	if closest_slot:
		global_position = closest_slot.global_position
		current_selected_slot = closest_slot
		Global.hand_scene.letter_row.erase(self)
		if current_selected_slot.current_letter:
			Global.deck_disc_scene.append_to_deck(current_selected_slot.current_letter)
			current_selected_slot.letter_is_taken()
			properties.max_hp+=1
			properties.current_hp=properties.max_hp
			letterDisplay.update_stats()
		current_selected_slot.letter_is_placed(self)
		self.rotation_degrees = 0
		properties.grid_x = current_selected_slot.slotColumn
		properties.grid_y = current_selected_slot.slotRow
		if Global.board_scene.ally_letters.has(self) == false:
			Global.board_scene.ally_letters.append(self)
		is_active = false
		
		if properties.is_an_object == true:
			return
		
		if properties.element_type == "Electricity":
			Global.ui_manager._reduce_energy(0)
		else:
			Global.ui_manager._reduce_energy(1)

		
		Global.battle_simulator.execute_letter_action(self)
		await Global.battle_animator.animations_completed
		
		if properties.current_hp <= 0:
			Global.battle_animator._letter_is_dead(self)
