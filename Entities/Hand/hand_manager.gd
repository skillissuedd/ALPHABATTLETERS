extends Node2D

@export var letter2Dscene = preload("res://Entities/Letters/Letter2D/Ally/AllyLetter2D.tscn")
@export var cell_size: Vector2 = Vector2(250, 250)
@export var circle_radius: float = 600.0
@export var max_hand_size: int = 6
var letter = null
var letter_row: Array = []

@export var apply_wheel_rotation := true 

	
func fill_hand():
	if Global.deck_scene == null:
		push_warning("Deck is not set!")
		return
		
	if not letter_row.is_empty():
		clear_hand()
		
	for i in range(max_hand_size):
		letter = Global.deck_scene.get_random_letter_instance()
		if letter != null:
			letter_row.append(letter)
			letter.reparent(self)
			letter.position = Vector2(i, 0) * cell_size
	arrange_hand()
			
func _ready():
	pass
	
func get_letter(col: int) -> Node2D:
	if col >= 0 and col < letter_row.size():
		return letter_row[col]
	return null

	
func snap_to_hand(letter_to_snap: Node2D):
	letter_row.append(letter_to_snap)
	letter_to_snap.reparent(self)
	arrange_hand()
	
func clear_hand():
	for child in get_children():
		Global.deck_disc_scene.append_to_deck(child)
		letter_row.erase(child)
	
func set_hand_enabled(enabled: bool):
	for letterToEnable in get_children():
		if letterToEnable as letter2Dclass:
			letterToEnable.is_active=enabled

func arrange_hand():
	var letter_count = letter_row.size()
	if letter_count == 0:
		return

	var angle_step = TAU / letter_count
	var base_rotation = get_parent().rotation if apply_wheel_rotation else 0.0
	
	for i in range(letter_count):
		var angle = angle_step * i + base_rotation - PI/2
		var offset = Vector2(cos(angle), sin(angle)) * circle_radius
		letter_row[i].z_index = i
		letter_row[i].position = offset
		letter_row[i].rotation = -base_rotation
		
		
func sort_hand(sort_type: int):
	if letter_row.is_empty():
		return
		
	match sort_type:
		0:  # Alphabetical (A-Z)
			letter_row.sort_custom(_compare_letters_alphabetically)
		1:  # By Element (assuming element is a String property)
			letter_row.sort_custom(_compare_letters_by_element)
		_:  # Default (no sorting)
			return
			
	arrange_hand()

func _compare_letters_alphabetically(a: Node2D, b: Node2D) -> bool:
	if not (a is letter2Dclass and b is letter2Dclass):
		return false
	
	# Get the first character of each letter (assuming letter is a String property)
	var a_char = a.properties.letter.unicode_at(0) if a.properties.letter.length() > 0 else 0
	var b_char = b.properties.letter.unicode_at(0) if b.properties.letter.length() > 0 else 0
	
	# Case-insensitive comparison by converting to uppercase
	return a_char < b_char

# Comparison function for element sorting
func _compare_letters_by_element(a: Node2D, b: Node2D) -> bool:
	if not (a is letter2Dclass and b is letter2Dclass):
		return false
	
	# Assuming element is a String property
	var a_element = a.properties.element_type.to_lower()
	var b_element = b.properties.element_type.to_lower()
	if a_element == b_element:
		# If elements are equal, sort alphabetically as secondary criteria
		return _compare_letters_alphabetically(a, b)
	
	return a_element < b_element
