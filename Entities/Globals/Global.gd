extends Node

@export var currently_hovered_slot: Node = null
var overlapping_slots := []
var letter_stats = load("res://Entities/Letters/LetterStats/letter_stats.tres")

var main_scene: Node = null
var deck_disc_scene: deck_class = null
var enemy_deck_disc_scene: deck_class = null
var deck_scene: deck_class = null
var board_scene: Node = null
var hand_scene: Node = null
var battle_manager: Node = null
var sfx_manager: Node = null
var battle_simulator: Node = null
var battle_animator: Node = null
var mouse: Node = null
var ui_manager: Node = null
