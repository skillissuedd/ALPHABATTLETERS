extends letter2Dclass

func _ready():
	add_to_group("allyLetters")
	add_to_group("letters")
	frame_bar.set_hp_percent(100)
	$Shadow.z_index=-1
	
func set_hand_position(current_pos: Vector2):
	position_in_hand = current_pos
	
func get_closest_slot() -> Area2D:
	if overlapping_slots.is_empty():
		return null
		
	closest_slot = overlapping_slots[0]
	closest_dist = global_position.distance_to(closest_slot.global_position)

	for slot in overlapping_slots:
		dist = global_position.distance_to(slot.global_position)
		if dist < closest_dist:
			closest_slot = slot
			closest_dist = dist
			slot.is_not_hovered()
			
	if Global.currently_hovered_slot != closest_slot:
		Global.board_scene.slot_hovered_block = false
	closest_slot.is_hovered(self)

	return closest_slot
	
func _physics_process(delta: float) -> void:
	if is_dragging:
		get_closest_slot()
		affect_energy_preview()
	drag_logic(delta)
	
func affect_energy_preview()-> void:
	if !overlapping_slots.is_empty():
		Global.ui_manager.energy_preview.visible = true
		if properties.element_type == "Electricity":
			Global.ui_manager.energy_preview.text = "-0"
			Global.ui_manager.energy_preview.add_theme_color_override("font_color", Color.LIME_GREEN)
		else:
			Global.ui_manager.energy_preview.text = "-1"
			Global.ui_manager.energy_preview.add_theme_color_override("font_color", Color.CORAL)
	else:
		Global.ui_manager.energy_preview.visible = false
	
		
func snap_to_hand():
	#print (self.get_parent().global_position)
	position = position_in_hand
