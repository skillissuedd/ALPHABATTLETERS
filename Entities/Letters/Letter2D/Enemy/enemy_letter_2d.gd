extends letter2Dclass

var coins_count: int = 0 

@onready var coins: Sprite2D = $Coins
@onready var coins_count_label: Label = $Coins/CoinsCountLabel

func _ready():
	add_to_group("enemyLetters")
	add_to_group("letters")
	$Shadow.z_index=-1
	
func _physics_process(delta: float) -> void:
	drag_logic(delta)

func _change_coins_count(count: int):
	coins_count = count
	coins_count_label.text = str(count)
