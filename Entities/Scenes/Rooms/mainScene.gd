extends Node2D

@onready var letter_scene = preload("res://Entities/Letters/Letter2D/Ally/AllyLetter2D.tscn")
@onready var current_round: int = 1


func init_managers():
	Global.sfx_manager = $sfxManager
	Global.ui_manager = $UI_parent/UiManager
	Global.ui_manager.enemy_health_bar._setup_health_bar(10*current_round)
	Global.ui_manager.ally_health_bar._setup_health_bar(20.0)

func init_decks():
	Global.deck_disc_scene = $DeckDiscarded
	Global.enemy_deck_disc_scene = $enemyDeckDiscarded
	Global.deck_scene = $Deck
	Global.deck_scene.initialize_deck()
	Global.deck_scene.fill_deck()

func init_hand():
	Global.hand_scene= $handManager
	Global.hand_scene.fill_hand()
	
func init_board():
	Global.board_scene = $BoardManager
	Global.board_scene.create_board()
	
func init_battle_logic():
	Global.battle_manager = $BattleManager
	Global.battle_simulator = $BattleSimulator
	Global.battle_animator = $BattleAnimator
	Global.battle_manager.before_round()
	
func init_interface():
	init_managers()
	init_decks()
	init_hand()
	init_board()
	init_battle_logic()
	
func _ready():
	Global.main_scene = self
	GlobalOptions.current_room = "Battle"
	init_managers()
	init_decks()
	init_hand()
	Global.ui_manager.create_upgrade_panel()
	await GlobalSignals.upgrade_panel_is_gone
	Global.ui_manager.set_ui_enabled(false)
	init_board()
	await Global.board_scene.board_is_complete
	init_battle_logic()
	Global.ui_manager.init_battle_ui()
	
	GlobalOptions.in_battle = true
	
	await GlobalSignals.round_is_won
	
	GlobalOptions.in_battle = false
	
	next_round()

func next_round():
	current_round+=1
	Global.ui_manager.round_label.text = str(current_round)
	Global.board_scene.reset_board()
	Global.hand_scene.clear_hand()
	Global.deck_scene.refill_main_deck(Global.deck_disc_scene, Global.deck_scene)
	Global.ui_manager.hide_battle_ui()
	
	Global.hand_scene.fill_hand()
	Global.hand_scene.set_hand_enabled(true)
	Global.ui_manager.create_upgrade_panel()
	await GlobalSignals.upgrade_panel_is_gone
	
	Global.ui_manager.set_ui_enabled(false)
	Global.board_scene.create_board()
	await Global.board_scene.board_is_complete
	
	Global.battle_manager.before_round()
	Global.ui_manager.init_battle_ui()
	Global.ui_manager.enemy_health_bar._setup_health_bar(10*current_round)
	
	GlobalOptions.in_battle = true
	
	await GlobalSignals.round_is_won
	
	GlobalOptions.in_battle = false
	next_round()
	
func free_all_nodes():
	var root = get_tree().current_scene
	for child in root.get_children():
		child.queue_free()
