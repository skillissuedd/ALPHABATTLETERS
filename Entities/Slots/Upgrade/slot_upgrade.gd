class_name slot_upgrade extends slot_class
var slot_upgrade_type

func _ready():
	z_index = -1
	appear()
	
func letter_is_placed(letter2D: Node2D):
	letter2D.is_active = false


func _on_mouse_entered() -> void:
	Global.ui_manager.info_tab.match_upgrade(slot_upgrade_type)
	Global.ui_manager.info_tab.global_position = get_global_mouse_position() + Vector2(16, 16)
	if Mousebrain.node_being_dragged == null:
		Global.ui_manager.info_tab.show()

func _on_mouse_exited():
	Global.ui_manager.info_tab.hide()
