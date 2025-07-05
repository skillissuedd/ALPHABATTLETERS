extends letter2Dclass

func _ready():
	add_to_group("enemyLetters")
	add_to_group("letters")
	$Shadow.z_index=-1
	
func _physics_process(delta: float) -> void:
	drag_logic(delta)
