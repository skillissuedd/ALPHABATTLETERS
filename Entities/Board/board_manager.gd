extends Node2D

@export var slot_scene = preload ("res://Entities/Slots/slot1.tscn")
@export var slotRusty = preload("res://Entities/Slots/Rusty/slotRusty.tscn")
@export var slotGolden = preload("res://Entities/Slots/Golden/slotGolden.tscn")
@export var slotUpgrade = preload("res://Entities/Slots/Upgrade/slotUpgrade.tscn")
@export var cell_size: Vector2 = Vector2(300, 300)
@onready var rows: int = 5
@onready var cols: int = 5
var ally_letters: Array = []
var enemy_letters: Array = []
var slot_hovered_block: bool = false
@export var all_letters: Array = []  
@export var slot_grid: Array = [] # 2D array: slot_grid[row][col]

func _ready():
	pass

func on_slot_is_hovered(slot: Node2D, letter2D: Node2D):
	if !slot_hovered_block:
		slot_hovered_block = true
		var slotX = slot.slotColumn
		var slotY = slot.slotRow
		ally_letters.append(letter2D.letter_unit)
		letter2D.letter_unit.grid_x = slotX
		letter2D.letter_unit.grid_y = slotY
		if GlobalOptions.toggle_preview_animations:
			Global.battle_simulator.run_simulation()

func prepare_simulation_data() -> Dictionary:
	var ally_letters_sim = []
	var enemy_letters_sim = []
	for letter_unit in ally_letters:
		if letter_unit.is_dead:
			continue
		ally_letters_sim.append({
			"ref": letter_unit,
			"x": letter_unit.grid_x,
			"y": letter_unit.grid_y,
			"hp": letter_unit.hp,
			"attack": letter_unit.attack,
			"is_enemy": false,
			"is_dead": letter_unit.is_dead
		})
		
	for letter_unit in enemy_letters:
		if letter_unit.is_dead:
			continue
		enemy_letters_sim.append({
			"ref": letter_unit,
			"x": letter_unit.grid_x,
			"y": letter_unit.grid_y,
			"hp": letter_unit.hp,
			"attack": letter_unit.attack,
			"is_enemy": true,
			"is_dead": letter_unit.is_dead
		})

	return {
		"player_letters": ally_letters_sim,
		"enemy_letters": enemy_letters_sim
	}
	
func unlock(state:bool):
	var letterArray=return_letters()
	for letter in letterArray:
		if letter:
			letter.set_active(state)

func return_letters():
	all_letters.clear()
	var slots = get_children().filter(func(n): return n.is_in_group("slots"))
	for slot in slots:
		for child in slot.get_children():
			if child.is_in_group("allyLetters"):
				ally_letters.append(child)
				all_letters.append(child)
			elif child.is_in_group("enemyLetters"):
				enemy_letters.append(child)
				all_letters.append(child)
		return all_letters

func create_upgrade_board():
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
			add_child(slot)
			row.append(slot)
			slot_index += 1

		slot_grid.append(row)
	
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
			add_child(slot)
			row.append(slot)
			slot_index += 1

		slot_grid.append(row)

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
	for row in slot_grid:
		for slot in row:
			slot.queue_free()
	slot_grid.clear()
