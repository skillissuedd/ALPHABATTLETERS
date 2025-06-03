extends Node2D
class_name slot_class

@export var letter2Dscene = preload("res://objects/Letters/AllyLetter2D.tscn")
@export var cell_size: Vector2 = Vector2(250, 250)
@export var max_hand_size: int = 6
var letter = null
var letter_row: Array = []
	
func fill_hand():
	if Global.deck_scene == null:
		push_warning("Deck is not set!")
		return
		
	if not letter_row.is_empty():
		clear_hand()
		
	for i in range(max_hand_size):
		letter = Global.deck_scene.get_random_letter_instance()
		if letter != null:
			letter_row.append(letter.letter_unit)
			letter.reparent(self)
			letter.position = Vector2(i, 0) * cell_size
			
			
func _ready():
	pass
	
func get_letter(col: int) -> Node2D:
	if col >= 0 and col < letter_row.size():
		return letter_row[col]
	return null

	
func snap_to_hand(letter_to_snap: Node2D):
	letter_row.append(letter_to_snap.return_letter())
	letter_to_snap.position = Vector2(get_child_count(), 0) * cell_size

func clear_hand():
	for child in get_children():
		Global.deck_disc_scene.append_to_deck(child)

func replace_letter(col: int, new_letter: Node2D):
	var old_letter = get_letter(col)
	if old_letter:
		old_letter.queue_free()
	letter_row[col] = new_letter
	new_letter.position = Vector2(col, 0) * cell_size
	new_letter.set_meta("grid_x", col)
	add_child(new_letter)
	
func unlock_hand(state:bool):
	for letterToUnlock in get_children():
		letterToUnlock.set_active(state)
