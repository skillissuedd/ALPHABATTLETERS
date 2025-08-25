class_name slot_class extends Area2D 
signal upgrade_slot_is_used

var mouse_in: bool = false
var is_selected = false
var slotColumn: int = 0
var slotRow: int = 0 
var current_letter: Node2D
@onready var slot_sprite = $Sprite2D
@onready var slotCollision = $Slot_Collision

func _ready() -> void:
	add_to_group("slots")
	z_index = -1

	
func disappear():
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	queue_free()
	
func appear():
	scale = Vector2(0, 0)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
func is_hovered(letter2D: Node2D):
	slot_sprite.modulate = Color(1, 1, 1, 0.2)
	if self is not slot_upgrade:
		Global.board_scene.on_slot_is_hovered(self, letter2D)
	
func is_not_hovered():
	slot_sprite.modulate = Color(1, 1, 1, 1.0)
	
func letter_is_placed(letter2D: Node2D):
	letter2D.current_selected_slot = self
	current_letter = letter2D
	letter2D.reparent(self)
	slot_sprite.self_modulate = Color(1, 1, 1, 1)
	is_selected = true

func letter_is_taken():
	is_not_hovered()
	current_letter = null
	is_selected = false


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is letter2Dclass:
		var letter2D = area.get_parent()
		if not is_selected:
			letter2D.overlapping_slots.append(self)
		elif char(letter2D.properties.letter.unicode_at(0)-1) == current_letter.properties.letter and \
		not current_letter.properties.is_enemy:
			letter2D.overlapping_slots.append(self)
			

func _on_area_exited(area: Area2D) -> void:
	if area.get_parent() is letter2Dclass:
		var letter2D = area.get_parent()
		is_not_hovered()
		letter2D.overlapping_slots.erase(self)
		if letter2D.overlapping_slots.is_empty() and Global.battle_simulator:
			Global.battle_simulator.load_backups()
