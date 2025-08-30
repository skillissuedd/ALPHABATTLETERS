extends Control
signal ok_button_is_clicked
@onready var slots = [$GridContainer/slot1, $GridContainer/slot2, $GridContainer/slot3]

@onready var reroll_button: Button = $HBoxContainer/reroll_button
@onready var coins_count_label: Label = $HBoxContainer/reroll_button/coins_count_label
@onready var coins_required := 5


func _ready():
	spawn_slots()
	init_colorrect()
	coins_count_label.text = str(coins_required)
	await GlobalSignals.upgrade_slot_is_used
	Global.hand_scene.set_hand_enabled(false)
	await GlobalSignals.upgrade_completed
	for slot in slots:
		var slot_instance = slot.get_child(0) as slot_class
		slot_instance.is_used = true
		await slot_instance.disappear()
	
	$HBoxContainer/ok_button.disabled=false
	reroll_button.disabled=false
	await ok_button_is_clicked
	remove_panel()
	
func remove_panel():
	GlobalOptions.selecting_upgrade = false
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.3)
	await tween.finished
	queue_free()
	GlobalSignals.emit_upgrade_panel_is_gone()
	
func spawn_slots():
	GlobalOptions.selecting_upgrade = true
	var slots_rolled = []
	for slot in slots:
		var slot_scene = null
		while true:
			var roll = 25#randi() % 100 + 1
			if roll <= 40:
				var rollTier3 = randi() % 4 + 1
				match rollTier3:
					1:
						slot_scene = preload("res://Entities/Slots/Upgrade/Tier3/Pierce/upgrade_pierce.tscn")
					2:
						slot_scene = preload("res://Entities/Slots/Upgrade/Tier3/Rebirth/upgrade_rebirth.tscn")
					3: 
						slot_scene = preload("res://Entities/Slots/Upgrade/Tier3/Scar/upgrade_scar.tscn")
					4:
						slot_scene = preload("res://Entities/Slots/Upgrade/Tier3/Vector/upgrade_vector.tscn")
			elif roll <= 80:
				var rollTier2 = randi() % 3 + 1
				match rollTier2:
					1:
						slot_scene = preload("res://Entities/Slots/Upgrade/Tier2/Assassin/upgrade_assassin.tscn")
					2:
						slot_scene = preload("res://Entities/Slots/Upgrade/Tier2/Halo/upgrade_halo.tscn")
					3:
						slot_scene = preload("res://Entities/Slots/Upgrade/Tier2/Trajectory/upgrade_trajectory.tscn")
			else:
				var rollTier1 = randi() % 3 + 1
				match rollTier1:
					1:
						slot_scene = preload("res://Entities/Slots/Upgrade/Tier1/Berserker/upgrade_berserker.tscn")
					2:
						slot_scene = preload("res://Entities/Slots/Upgrade/Tier1/Dart/upgrade_dart.tscn")
					3:
						slot_scene = preload("res://Entities/Slots/Upgrade/Tier1/Line/upgrade_line.tscn")
			if not slot_scene in slots_rolled:
				slots_rolled.append(slot_scene)
				break
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
	panel.size = size + Vector2(0,400)
	panel.z_index = -1
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_ok_button_button_up() -> void:
	ok_button_is_clicked.emit()


func _on_reroll_button_button_up() -> void:
	if Global.ui_manager.coins < coins_required:
		return
		
	coins_required+=5
	coins_count_label.text = str(coins_required)
	
	$HBoxContainer/ok_button.disabled=true
	reroll_button.disabled=true
	
	spawn_slots()
	Global.hand_scene.set_hand_enabled(true)
	
	await GlobalSignals.upgrade_slot_is_used
	
	Global.hand_scene.set_hand_enabled(false)
	await GlobalSignals.upgrade_completed
	for slot in slots:
		var slot_instance = slot.get_child(0) as slot_class
		slot_instance.is_used = true
		await slot_instance.disappear()

	$HBoxContainer/ok_button.disabled=false
	reroll_button.disabled=false
	
