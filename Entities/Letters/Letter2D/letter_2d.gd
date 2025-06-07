extends Sprite2D
class_name letter2Dclass

#Physics variables
#SCALE
var current_goal_scale: Vector2 = Vector2(0.2, 0.2)
var scale_tween: Tween
var scale_mod:float = 2
var max_size := Vector2(200, 200)

#DRAGGING
@export var mouse_in: bool = false
@export var is_dragging: bool = false
@export var is_active: bool = true

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
@export var current_letter = "A"
@export var max_hp: int
@export var current_hp: int 
@export var current_atk: int
@export var is_enemy: bool
@onready var current_upgrade = null
var element = "Neutral"

#References
@onready var letter_unit = $LetterUnit
@onready var frame_bar = $FrameBar/FrameBar
@onready var LetterDisplay = $Display/LetterDisplay

func finish_letter_preparation(letter: String):
	if !is_enemy:
		set_letter(letter)
		update_element_style()
	else:
		var random_letter = Global.letter_stats.return_random_letter()
		set_letter(random_letter)
		update_element_style()
		#frame_bar.set_hp_percent(100)
		frame_bar.border_color = Color.DARK_RED

func set_letter(character: String):
	current_letter = character
	var stats = letter_stats.get_stats(character)
	max_hp = stats["hp"]
	current_hp = max_hp
	current_atk = stats["atk"]
	if LetterDisplay:
		LetterDisplay.change_letter(character)
		LetterDisplay.update_stats(current_atk, current_hp)
		letter_unit.initialize(character, is_enemy, current_atk, max_hp, element)
		
func get_upgrade():
	return current_upgrade
	
func show_stats():
	letter_unit.show_stats()
	
func _ready():
	pass

func set_active(state: bool):
	is_active=state


func return_letter():
	if LetterDisplay:
		return LetterDisplay.return_letter()
		

func _on_area_2d_mouse_entered() -> void:
	mouse_in = true

func _on_area_2d_mouse_exited() -> void:
	mouse_in = false
	
func update_element_style():
	element = letter_stats.get_element_for_letter(current_letter)
	LetterDisplay.change_element(element)
	match element:
		"Water":
			self.texture=load("res://Entities/Letters/Letter2D/ElementalTiles/letterTileWater.png")
		"Fire":
			self.texture=load("res://Entities/Letters/Letter2D/ElementalTiles/letterTileFire.png")
		"Electric":
			self.texture=load("res://Entities/Letters/Letter2D/ElementalTiles/letterTileElectric.png")
		"Earth":
			self.texture=load("res://Entities/Letters/Letter2D/ElementalTiles/woodTile1.jpg")
		"Neutral":
			self_modulate = Color(0.9, 0.9, 0.9) 


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("slots") and not area.is_selected:
		overlapping_slots.append(area)
	elif (not is_enemy and area.get_parent().is_in_group("enemyBullets") or (is_enemy and area.get_parent().is_in_group("allyBullets"))):
		var letter = area.get_parent()
		#get_hit(letter.get_meta("damage"))
		area.set_deferred("monitorable", false)
		area.set_deferred("monitoring", false)
		letter.visible=false


	
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("slots") and not area.is_selected:
		area.is_not_hovered()
		overlapping_slots.erase(area)


#############################
#### ANIMATIONS #########
#############################

func update_frame_bar(ratio:float, permanent: bool):
	if permanent:
		frame_bar.set_hp_percent(ratio)
	else: 
		frame_bar.set_temp_percent(ratio)

func attack():
	play_attack_animation()
	
func play_attack_animation():
	#COPYING
	var original_label = LetterDisplay
	var attack_label = original_label.letter_label.duplicate()
	attack_label.name = "attack_label"
	add_child(attack_label)
	
	# SET DAMAGE PARAMETER
	var damage = int(original_label.ATK_label.text)
	attack_label.set_meta("damage", damage)
	
	#POSITION AND SIZE
	attack_label.global_position = global_position
	attack_label.scale = original_label.scale * 0.7
	attack_label.z_index=1
	if not is_enemy:
		attack_label.add_to_group("allyBullets")
	else:
		attack_label.add_to_group("enemyBullets")
	#MIRRORING
	attack_label.scale.y = -abs(attack_label.scale.y)
	
	#GLOWING
	attack_label.modulate = Color(1.0, 1.0, 0.5, 1.0) 
	
	#MOVING
	
	var start_pos = attack_label.global_position
	var end_pos = Vector2(start_pos.x, -600)	
	if is_enemy == true:
		end_pos = Vector2(start_pos.x, 1300)
		
	
	var tween = create_tween()
	tween.tween_property(attack_label, "global_position", end_pos, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(attack_label, "modulate:a", 0, 0.2).set_delay(0.2)
	tween.tween_callback(Callable(attack_label, "queue_free"))
	Global.sfx_manager.play_sfx(preload("res://sounds/attack_1.wav"), global_position)
	
	
func shake_letter(strength := 15.0, duration := 0.3, shakes := 15):
	var tween := get_tree().create_tween()
	var original_pos := position
	var time_per_shake := duration / float(shakes)

	for i in range(shakes):
		var offset := Vector2(
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
	#print("Changing scale from ", self.scale, " to ", desired_scale)
	
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
	$Shadow.position = Vector2(-5, 5).rotated(self.rotation)
	#Letter dragging logic
	if is_active:
		if (mouse_in or is_dragging) and (Mousebrain.node_being_dragged == null or Mousebrain.node_being_dragged == self):
			if Input.is_action_pressed("click"):
				if not is_enemy:
					global_position = lerp(global_position, get_global_mouse_position(), 22.0*delta)
					#SIZE WHEN LETTER IS DRAGGED
					_change_scale(Vector2(0.6+scale_mod, 0.6+scale_mod))
					_set_rotation(delta)
					self.z_index = 100
					is_dragging = true
					Mousebrain.node_being_dragged = self
					if get_parent() == current_selected_slot:
						Global.board_scene.ally_letters.erase(letter_unit)
						current_selected_slot.letter_is_taken()
					else:
						Global.hand_scene.letter_row.erase(self)
						Global.hand_scene.arrange_hand()
				else:
					_set_rotation(delta*0.5)
			else:
				#SIZE WHEN LETTER IS HOVERED/RELEASED
				_change_scale(Vector2(0.4+scale_mod, 0.4+scale_mod))
				is_dragging = false
				self.rotation_degrees = lerp(self.rotation_degrees, 0.0, 22.0*delta)
				if Mousebrain.node_being_dragged == self:
					Mousebrain.node_being_dragged = null
					snap_to_parent()
			return
		
	#WHEN LETTER IS AT REST
	self.z_index = 1
	_change_scale(Vector2(0.2+scale_mod, 0.2+scale_mod))
	self.rotation_degrees = lerp(self.rotation_degrees, 0.0, 22.0*delta)

func snap_to_parent():
	if not overlapping_slots.is_empty():
		snap_to_slot()
	else:
		Global.hand_scene.snap_to_hand(self)
		
func snap_to_slot():
	if closest_slot:
		global_position = closest_slot.global_position + Vector2(80, 80)
		current_selected_slot = closest_slot
		Global.hand_scene.letter_row.erase(self)
		current_selected_slot.letter_is_placed()
		self.rotation_degrees = 0
		reparent(current_selected_slot)
		letter_unit.grid_x = current_selected_slot.slotColumn
		letter_unit.grid_y = current_selected_slot.slotRow
		Global.board_scene.ally_letters.append(letter_unit)
