extends Area2D
var mouse_in: bool = false
var is_selected = false
var slotColumn: int = 0
var slotRow: int = 0
@onready var slot_sprite = $Sprite2D
@onready var slotCollision = $Slot_Collision

func _ready() -> void:
	add_to_group("slots")
	
func select():
	slot_sprite.self_modulate = Color(1, 1, 1, 0.2)
	
func deselect():
	slot_sprite.self_modulate = Color(1, 1, 1, 1.0)
	
func letter_is_placed():
	slot_sprite.self_modulate = Color(1, 1, 1, 1)
	is_selected = true
	
	
func attack():
	for child in get_children():
		if child.is_in_group("letters"):
			child.attack()
			
		
