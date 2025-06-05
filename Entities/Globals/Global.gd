extends Node

var currently_hovered_slot: Node = null
var overlapping_slots := []
var letter_stats = load("res://Entities/Letters/LetterStats/letter_stats.tres")

var deck_disc_scene: Node = null
var deck_scene: Node = null
var board_scene: Node = null
var hand_scene: Node = null
var battle_manager: Node = null
var sfx_manager: Node = null
var battle_simulator: Node = null
var battle_animator: Node = null
var mouse: Node = null
