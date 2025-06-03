extends Node2D

var current_round:int = 1
var enemy_waves_cleared: int = 0
var enemy_letter_count: Array = []
var skip_this_round: bool = false
@onready var ENEMY_LETTER_2D = preload("res://objects/Letters/EnemyLetter2D.tscn")



func before_round():
	enemy_letter_count.clear()
	if current_round == 1:
		init_enemies(3)
	for enemyLetter in Global.board_scene.return_letters():
		if enemyLetter.is_in_group("enemyLetters"):
			enemy_letter_count.append(enemyLetter)
	if enemy_letter_count.size() == 0 and skip_this_round == false:
		enemy_waves_cleared +=1
		skip_this_round = true
	else:
		init_enemies(current_round +2)
		skip_this_round = false
	if enemy_waves_cleared == 2:
		room_cleared()
		
func room_cleared():
	pass

func round_start():
	lock_in(true)
	var letterArray=Global.board_scene.return_letters()
	for letter in letterArray:
		if letter:
			letter.attack()
			await get_tree().create_timer(1.0).timeout
	await get_tree().create_timer(1.0).timeout
	round_end()
	
func round_end():
	Global.hand_scene.fill_hand()
	lock_in(false)
	current_round+=1
	$Panel/roundLabel.text=str(current_round)
	before_round()

func lock_in(value: bool):
	get_parent().button1.disabled=value
	Global.board_scene.unlock(not value)
	Global.hand_scene.unlock_hand(not value)
	
	
func init_enemies(enemies: int):
	while (Global.board_scene.enemy_letters.size()<enemies):
		var enemy_letter=ENEMY_LETTER_2D.instantiate()
		var enemy_slot = Global.board_scene.get_child(randi() % 15 + 10)
		while (enemy_slot.is_selected == true):
			enemy_slot = Global.board_scene.get_child(randi() % 15 + 10)
		if enemy_slot.is_in_group("slots"):
			enemy_slot.letter_is_placed()
			enemy_slot.add_child(enemy_letter)
			enemy_letter.global_position = enemy_slot.global_position + Vector2(80, 80)
			enemy_letter.set_random_letter()
			enemy_letter.update_element_style()
			enemy_letter.modulate = Color(1, 0.6, 0.6, 1)
			Global.board_scene.enemy_letters.append(enemy_letter)
			enemy_letter_count.append(enemy_letter)
