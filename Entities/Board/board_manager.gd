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
@export var all_letters: Array = [ally_letters, enemy_letters]  
@export var slot_grid: Array = [] # 2D array: slot_grid[row][col]

func _ready():
	pass

func on_slot_is_hovered(slot: Node2D, letter2D: Node2D):
	if !slot_hovered_block:
		slot_hovered_block = true
		var slotX = slot.slotColumn
		var slotY = slot.slotRow
		if ally_letters.has(letter2D) == false:
			ally_letters.append(letter2D)
		letter2D.properties.grid_x = slotX
		letter2D.properties.grid_y = slotY
		if GlobalOptions.toggle_preview_animations:
			Global.battle_simulator.run_simulation()

func prepare_simulation_data() -> Array:
	var combined_letters = []
	
	# Process ally letters
	for letter in ally_letters:
		if letter.properties.is_dead:
			continue
		var props = letter.properties
		combined_letters.append({
			"ref": props,
			"letter": props.letter,
			"x": props.grid_x,
			"y": props.grid_y,
			"current_hp": props.current_hp,
			"max_hp": props.max_hp,
			"attack": props.attack,
			"is_enemy": props.is_enemy,
			"is_dead": props.is_dead
		})
		
	# Process enemy letters	
	for letter in enemy_letters:
		if letter.properties.is_dead:
			continue
		var props = letter.properties
		combined_letters.append({
			"ref": props,
			"letter": props.letter,
			"x": props.grid_x,
			"y": props.grid_y,
			"current_hp": props.current_hp,
			"max_hp": props.max_hp,
			"attack": props.attack,
			"is_enemy": props.is_enemy,
			"is_dead": props.is_dead
		})
	return combined_letters
	
func set_board_enabled(enabled: bool):
	for letter in ally_letters:
		if letter:
			letter.is_active = enabled


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
				upgrade_tile = upgradeAssassin.instantiate()
			else:
				upgrade_tile = upgradePierce.instantiate()

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
