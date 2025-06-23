extends Node2D

@onready var letter_scene = preload("res://Entities/Letters/Letter2D/Ally/AllyLetter2D.tscn")
@onready var current_round: int = 1

func init_interface():
	Global.mouse = $Mouse
	Global.deck_disc_scene = $DeckDiscarded
	Global.deck_scene = $Deck
	Global.board_scene = $BoardManager
	Global.hand_scene= $handManager
	Global.battle_manager = $BattleManager
	Global.battle_simulator = $BattleSimulator
	Global.battle_animator = $BattleAnimator
	Global.sfx_manager = $sfxManager
	Global.ui_manager = $UiManager
	Global.deck_scene.initialize_deck()
	Global.deck_scene.fill_deck()
	Global.board_scene.create_board()
	Global.hand_scene.fill_hand()
	
	
	
func _ready():
	GlobalOptions.current_room = "Battle"
	init_interface()
	await get_tree().create_timer(3).timeout
	Global.battle_manager.before_round()


func _on_area_around_area_entered(area: Area2D) -> void:
	area.get_parent().current_selected_slot = null
	area.get_parent().is_outside = true


func _on_area_around_area_exited(area: Area2D) -> void:
	area.get_parent().is_outside = false
