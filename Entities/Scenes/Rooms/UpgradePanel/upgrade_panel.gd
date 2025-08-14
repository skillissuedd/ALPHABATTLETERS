extends ColorRect
@onready var slots = [$GridContainer/slot1, $GridContainer/slot2, $GridContainer/slot3]

func _ready():
	spawn_slots()
	
func spawn_slots():
	GlobalOptions.selecting_upgrade = true
	for slot in slots:
		var roll = randi() % 4 + 1
		match roll:
			1:
				slot.add_child(preload("res://Entities/Slots/Upgrade/Tier3/Assassin/upgradeAssassin.tscn").instantiate())
			2:
				slot.add_child(preload("res://Entities/Slots/Upgrade/Tier3/Pierce/upgradePierce.tscn").instantiate())
			3: 
				slot.add_child(preload("res://Entities/Slots/Upgrade/Tier3/Rebirth/upgradeRebirth.tscn").instantiate())
			4:
				slot.add_child(preload("res://Entities/Slots/Upgrade/Tier3/Vector/upgradeVector.tscn").instantiate())
			
			
