extends Control
@onready var slotDefault = preload("res://objects/Slots/slot1.tscn")
var board_grid: Node = null
var hand_grid: Node = null
var hand_size = 7

func _ready():
	pass
	


func _on_board_size_item_selected(index: int) -> void:
	var new_size = int($BoardSize.get_item_text(index))
	for child in board_grid.get_children():
		child.queue_free()
	board_grid.columns = new_size
	board_grid.add_theme_constant_override("h_separation", (90+new_size*10))
	board_grid.add_theme_constant_override("v_separation", (90+new_size*10))
	for i in range(new_size):
		for j in range (new_size):
				board_grid.add_child(slotDefault.instantiate())


func _on_draw_hand_pressed() -> void:
	for child in hand_grid.get_children():
		child.queue_free()
	hand_grid.columns = hand_size
	#for i in range(hand_size):
	#	hand_grid.add_child(letter.instantiate())
