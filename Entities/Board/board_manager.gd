extends Node2D

signal board_is_complete

#SlotTypes
@export var slot_scene = preload("res://Entities/Slots/slot1.tscn")
@export var slotRusty = preload("res://Entities/Slots/Rusty/slotRusty.tscn")
@export var slotGolden = preload("res://Entities/Slots/Golden/slotGolden.tscn")
@export var slotUpgrade = preload("res://Entities/Slots/Upgrade/slotUpgrade.tscn")

@export var cell_size: Vector2 = Vector2(280, 280)
@onready var rows: int = 5
@onready var cols: int = 5
@export var ally_letters: Array = []
@export var enemy_letters: Array = []
var all_letters: Array = [ally_letters, enemy_letters]  
@export var slot_grid: Array = [] # 2D array: slot_grid[row][col]

func _ready():
	while true:
		await GlobalSignals.round_is_won
		for letter in ally_letters:
			Global.deck_scene.append_to_deck(letter)
		enemy_letters.clear()
		
func on_slot_is_hovered(slot: Node2D, letter2D: Node2D):
		var slotX = slot.slotColumn
		var slotY = slot.slotRow
		if ally_letters.has(letter2D) == false:
			ally_letters.append(letter2D)
		letter2D.properties.grid_x = slotX
		letter2D.properties.grid_y = slotY
		if GlobalOptions.toggle_preview_animations:
			Global.battle_simulator.simuilate_preview(letter2D)
		

func return_letters_from_the_board() -> Array:
	var combined_letters = []
	
	for letter in ally_letters:
		combined_letters.append(letter.properties)
		
	for letter in enemy_letters:
		combined_letters.append(letter.properties)

	return combined_letters
	
func set_board_enabled(enabled: bool):
	for letter in ally_letters:
		if letter:
			letter.is_active = enabled
	
func create_board():
	reset_board()
	
	var slot_index := 1
	for y in range(rows):
		var row: Array = []
		# Invert the row index so that row 0 is at the bottom
		var actual_y := rows - 1 - y

		for x in range(cols):
			var slot = randomize_slot()
			slot.name = "Slot_%d" % slot_index
			slot.position = Vector2(x, actual_y) * cell_size
			slot.slotColumn = x
			slot.slotRow = actual_y
			slot.scale = Vector2(0, 0)  # Start invisible/small
			add_child(slot)
			row.append(slot)
			slot_index += 1

		slot_grid.append(row)
	await animate_slots_appearing()
	board_is_complete.emit()

func animate_slots_appearing() -> void:
	for y in range(rows):
		for x in range(cols):
			var slot = slot_grid[y][x]
			slot.appear()
			Global.sfx_manager.play_sfx("stone2", slot.position)
			await get_tree().create_timer(0.1).timeout  # Delay between each slot
			
func randomize_slot():
	var slotRolled = null
	var roll = randi() % 101
	if GlobalOptions.hard_mode:
		if roll < 1:
			slotRolled = slotRusty
	if roll <= 99:
		slotRolled = slot_scene
	else:
		var roll2 = randi() % 11
		if roll2 <= 6:
			slotRolled = slotGolden
		elif roll2 <= 8:
			slotRolled = slotGolden
		else:
			slotRolled = slotUpgrade
	return slotRolled.instantiate()


func reset_board():
	for letter in ally_letters:
		letter.current_selected_slot = null
		Global.deck_scene.append_to_deck(letter)
		ally_letters.erase(letter)
		if letter.properties.is_an_object == true:
			letter.queue_free()

	for row in slot_grid:
		for slot in row:
			slot.queue_free()
	slot_grid.clear()
