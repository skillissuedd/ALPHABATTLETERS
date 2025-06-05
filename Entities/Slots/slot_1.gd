extends Area2D
var mouse_in: bool = false
var is_selected = false
var slotColumn: int = 0
var slotRow: int = 0
@onready var slot_sprite = $Sprite2D
@onready var slotCollision = $Slot_Collision

func _ready() -> void:
	add_to_group("slots")
	
func is_hovered(letter2D: Node2D):
	slot_sprite.self_modulate = Color(1, 1, 1, 0.2)
	letter2D.reparent(self)
	Global.board_scene.on_slot_is_hovered(self, letter2D)
	
func is_not_hovered():
	slot_sprite.self_modulate = Color(1, 1, 1, 1.0)
	
func letter_is_placed():
	slot_sprite.self_modulate = Color(1, 1, 1, 1)
	is_selected = true

func letter_is_taken():
	is_not_hovered()
	is_selected = false
	
func attack():
	for child in get_children():
		if child.is_in_group("letters"):
			child.attack()
			
		
