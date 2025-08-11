extends Control

@onready var toggle_preview: Button = $TogglePreview
@onready var end_round_button: Button = $endRoundButton
@onready var enemy_health_bar: EnemyHealthBar = $EnemyHealthBar
@onready var ally_health_bar: AllyHealthBar = $AllyHealthBar

#SORTING
@onready var sort_button: Button = $sortButton
@export var sorting_mode: int = 0

#ENERGY
@onready var total_energy_label: Label = $TextureRect/total_energy
@onready var current_energy_label: Label = $TextureRect/current_energy
@onready var energy_preview: Label = $TextureRect/energy_preview

@export var total_energy: int
@export var current_energy: int 

#COINS
@onready var coins_count: Label = $coins_section/coins_count
@export var coins:int = 0

func update_coins(coins_value:int):
	coins+=coins_value
	coins_count.text = str(coins)


func update_round_label():
	if has_node("Panel/roundLabel"):
		$Panel/roundLabel.text = str(Global.battle_manager.current_round)


func _ready():
	total_energy = 5
	current_energy = 5
	update_energy_ui()
	
func update_energy_ui() -> void:
	total_energy_label.text = str(total_energy)
	current_energy_label.text = str(current_energy)
	

func _refill_energy() -> void:
	current_energy = total_energy
	update_energy_ui()
	
	
func _reduce_energy(energy: int) -> void:
	current_energy -= energy
	update_energy_ui()
	if current_energy <=0:
		Global.hand_scene.set_hand_enabled(false)
		end_round_button.add_theme_color_override("font_color", Color.FOREST_GREEN)
	
func _on_toggle_preview_button_down() -> void:
	disable_preview()
	$TogglePreview.text = "Enable preview"
	$TogglePreview.text = "Disable preview"
	
func disable_preview():
	if GlobalOptions.toggle_preview_animations:
		GlobalOptions.toggle_preview_animations = false
		Global.battle_simulator.load_backups()
	else:
		GlobalOptions.toggle_preview_animations = true
		Global.battle_simulator.load_backups()
		

func set_ui_enabled(enabled: bool):
	toggle_preview.disabled = not enabled
	end_round_button.disabled = not enabled
	Global.hand_scene.set_hand_enabled(enabled)

func _on_draw_button_pressed() -> void:
	if (Global.hand_scene.letter_row.size() < Global.hand_scene.max_hand_size) and current_energy > 0:
		_reduce_energy(1)
		Global.hand_scene.snap_to_hand(Global.deck_scene.get_random_letter_instance())
	Global.hand_scene.sort_hand(sorting_mode)
	
func _on_end_round_button_pressed() -> void:
	Global.battle_manager.round_start()
	set_ui_enabled(false)

func _on_sort_button_pressed() -> void:
	Global.hand_scene.sort_hand(sorting_mode)
	if sorting_mode == 0:
		sorting_mode = 1
		sort_button.text = "ui_sort_element"
	elif sorting_mode == 1:
		sorting_mode = 0
		sort_button.text = "ui_sort_alphabet"
	
