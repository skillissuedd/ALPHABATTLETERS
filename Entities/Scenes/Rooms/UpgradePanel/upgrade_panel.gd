extends Control
@onready var slots = [$GridContainer/slot1, $GridContainer/slot2, $GridContainer/slot3]


func _ready():
	spawn_slots()
	init_colorrect()
	await GlobalSignals.upgrade_slot_is_used
	for slot in slots:
		var slot_instance = slot.get_child(0) as slot_class
		slot_instance.is_used = true
	await GlobalSignals.upgrade_completed
	remove_panel()
	
func remove_panel():
	GlobalOptions.selecting_upgrade = false
	for slot in slots:
		var slot_instance = slot.get_child(0) as slot_class
		await slot_instance.disappear()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.8)
	await tween.finished
	GlobalSignals.emit_upgrade_panel_is_gone()
	
func spawn_slots():
	GlobalOptions.selecting_upgrade = true
	for slot in slots:
		var roll = randi() % 4 + 1
		var slot_scene = null
		match roll:
			1:
				slot_scene = preload("res://Entities/Slots/Upgrade/Tier3/Assassin/upgradeAssassin.tscn")
			2:
				slot_scene = preload("res://Entities/Slots/Upgrade/Tier3/Pierce/upgradePierce.tscn")
			3: 
				slot_scene = preload("res://Entities/Slots/Upgrade/Tier3/Rebirth/upgradeRebirth.tscn")
			4:
				slot_scene = preload("res://Entities/Slots/Upgrade/Tier3/Vector/upgradeVector.tscn")
		slot.add_child(slot_scene.instantiate())
		slot.z_index=1
			

func init_colorrect():
	var panel = Panel.new()
	var style = StyleBoxFlat.new()

	# Fill color
	style.bg_color = Color(0.2, 0.7, 0.9)

	# Border settings (now requires individual sides)
	style.border_width_left = 12.0
	style.border_width_right = 12.0
	style.border_width_top = 12.0
	style.border_width_bottom = 12.0
	style.border_color = Color.SEA_GREEN
	style.bg_color = Color.BURLYWOOD

	# Softened edges
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5

	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	panel.size = size
	panel.z_index = -1
