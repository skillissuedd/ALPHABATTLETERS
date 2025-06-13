extends Node2D
#SlotTypes
@export var slot_scene = preload("res://Entities/Slots/slot1.tscn")
@export var slotRusty = preload("res://Entities/Slots/Rusty/slotRusty.tscn")
@export var slotGolden = preload("res://Entities/Slots/Golden/slotGolden.tscn")
@export var slotUpgrade = preload("res://Entities/Slots/Upgrade/slotUpgrade.tscn")
@export var upgradeVector = preload("res://Entities/Slots/Upgrade/Tier3/Vector/upgradeVector.tscn")
@export var upgradeRebirth = preload("res://Entities/Slots/Upgrade/Tier3/Rebirth/upgradeRebirth.tscn")
@export var upgradeAssassin = preload("res://Entities/Slots/Upgrade/Tier3/Assassin/upgradeAssassin.tscn")
@export var upgradePierce = preload("res://Entities/Slots/Upgrade/Tier3/Pierce/upgradePierce.tscn")


@export var cell_size: Vector2 = Vector2(280, 280)
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
		ally_letters.append(letter2D.properties)
		letter2D.properties.grid_x = slotX
		letter2D.properties.grid_y = slotY
		if GlobalOptions.toggle_preview_animations:
			Global.battle_simulator.run_simulation()

func prepare_simulation_data() -> Dictionary:
	var ally_letters_sim = []
	var enemy_letters_sim = []
	for properties in ally_letters:
		if properties.is_dead:
			continue
		ally_letters_sim.append({
			"ref": properties,
			"letter": properties.letter,
			"x": properties.grid_x,
			"y": properties.grid_y,
			"current_hp": properties.current_hp,
			"max_hp": properties.max_hp,
			"attack": properties.attack,
			"is_enemy": properties.is_enemy,
			"is_dead": properties.is_dead
		})
		
	for properties in enemy_letters:
		if properties.is_dead:
			continue
		enemy_letters_sim.append({
			"ref": properties,
			"letter": properties.letter,
			"x": properties.grid_x,
			"y": properties.grid_y,
			"current_hp": properties.current_hp,
			"max_hp": properties.max_hp,
			"attack": properties.attack,
			"is_enemy": properties.is_enemy,
			"is_dead": properties.is_dead
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
	create_board()
	await get_tree().create_timer(3).timeout
	var upgrade_count = (randi() % 2) +2
	var target_row := int(rows / 2) - 1  # Slightly above center row
	var center_col := int(cols / 2)
	var offset_list 
	if upgrade_count == 2:
		offset_list = [-1, 1]  # For cols 1 and 3 if center is 2
	else:
		offset_list = [-1, 0, 1]
	
	
	for offset in offset_list:
		var target_col = center_col + offset

		if target_col >= 0 and target_col < cols:
			var base_slot = slot_grid[target_row][target_col]
			var upgrade_tile
			if offset > 0:
				upgrade_tile = upgradeVector.instantiate()
			else:
				upgrade_tile = upgradeRebirth.instantiate()

			upgrade_tile.position = base_slot.position
			upgrade_tile.slotRow = base_slot.slotRow
			upgrade_tile.slotColumn = base_slot.slotColumn

			remove_child(base_slot)
			slot_grid[target_row][target_col] = upgrade_tile
			add_child(upgrade_tile)
			Global.sfx_manager.play_sfx("upgradeTile", upgrade_tile.position)
			await get_tree().create_timer(0.5).timeout
	
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
	for row in slot_grid:
		for slot in row:
			slot.queue_free()
	slot_grid.clear()
