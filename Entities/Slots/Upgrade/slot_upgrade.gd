class_name slot_upgrade extends slot_class


func _ready():
	z_index = -1
	appear()
	
func letter_is_placed(letter2D: Node2D):
	letter2D.is_active = false
