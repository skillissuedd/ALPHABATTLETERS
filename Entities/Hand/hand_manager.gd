extends Node2D

@export var letter2Dscene = preload("res://Entities/Letters/Letter2D/Ally/AllyLetter2D.tscn")
@export var cell_size: Vector2 = Vector2(250, 250)
@export var circle_radius: float = 500.0
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

	for i in range(letter_count):
		var angle = angle_step * i
		var offset = Vector2(cos(angle), sin(angle)) * circle_radius
		letter_row[i].position = offset
