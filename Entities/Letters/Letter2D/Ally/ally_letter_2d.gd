extends letter2Dclass

func _ready():
	add_to_group("allyLetters")
	add_to_group("letters")
	frame_bar.set_hp_percent(100)
	
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
	Global.currently_hovered_slot = closest_slot
	closest_slot.is_hovered(self)

	return closest_slot
	
func _physics_process(delta: float) -> void:
	if is_dragging:
		get_closest_slot()
	drag_logic(delta)
		
func snap_to_hand():
	#print (self.get_parent().global_position)
	position = position_in_hand
