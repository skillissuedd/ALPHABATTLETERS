extends Node2D

@onready var letter_scene = preload("res://Entities/Letters/Letter2D/Ally/AllyLetter2D.tscn")
@onready var current_round: int = 1

func init_interface():
	# INIT MANAGERS
	Global.sfx_manager = $sfxManager
	Global.ui_manager = $UI_parent/UiManager

	Global.ui_manager.enemy_health_bar._setup_health_bar(20.0)
	Global.ui_manager.ally_health_bar._setup_health_bar(50.0)
	
	Global.letter_stats._nerf_all_letters()
	# INIT DECKS
	Global.deck_disc_scene = $DeckDiscarded
	Global.enemy_deck_disc_scene = $enemyDeckDiscarded
	Global.deck_scene = $Deck
	Global.deck_scene.initialize_deck()
	Global.deck_scene.fill_deck()
	
	# INIT MOUSE
	Global.mouse = $Mouse
	
	# INIT HAND
	Global.hand_scene= $handManager
	Global.hand_scene.fill_hand()
	
	# INIT BOARD
	Global.board_scene = $BoardManager
	Global.board_scene.create_board()
		
	# INIT BATTLE LOGIC
	Global.battle_manager = $BattleManager
	Global.battle_manager.enable_ui(false)
	Global.battle_simulator = $BattleSimulator
	Global.battle_animator = $BattleAnimator
	
	
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
