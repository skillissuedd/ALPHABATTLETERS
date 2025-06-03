extends Node2D

@onready var DebugMenuScene = preload("res://Scenes/debug_menu.tscn")
@onready var letter_scene = preload("res://objects/Letters/AllyLetter2D.tscn")
@onready var current_round: int = 1
@onready var button1 = $Button

func init_interface():
	Global.deck_disc_scene = $DeckDiscarded
	Global.deck_scene = $Deck
	Global.board_scene = $BoardManager
	Global.hand_scene= $handManager
	Global.battle_manager = $BattleManager
	Global.sfx_manager = $sfxManager
	Global.deck_scene.initialize_deck()
	Global.deck_scene.fill_deck()
	Global.board_scene.create_board()

	position_the_deck()
	Global.hand_scene.fill_hand()
	
	Global.battle_simulator = $BattleSimulator
	Global.battle_animator = $BattleAnimator
func _ready():
	init_interface()
	Global.battle_manager.before_round()

func position_the_deck():
	var deck_position = Global.deck_scene.global_position
	for letterinDeck in Global.deck_scene.get_children():
		letterinDeck.position += deck_position

func _on_button_pressed() -> void:
	Global.battle_manager.round_start()
	
