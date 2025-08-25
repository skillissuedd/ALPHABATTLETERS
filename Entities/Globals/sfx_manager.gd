extends Node2D
class_name SFXManager
const POOL_SIZE := 12

const SOUNDS := {
	"hit1": preload("res://sounds/hit1.wav"),
	"hit2": preload("res://sounds/hit2.wav"),
	"hit3": preload("res://sounds/hit3.wav"),
	"death": preload("res://sounds/death1.wav"),
	"upgrade": preload("res://Entities/Letters/LetterUpgrades/mysteryItem.wav"),
	"slot1": preload("res://Entities/Slots/bloop.wav"),
	"stone1":preload("res://Entities/Slots/stone1.mp3"),
	"stone2":preload("res://Entities/Slots/stone2.mp3"),
	"upgradeTile":preload("res://Entities/Slots/upgradeTile.wav"),
	"letterPlaced":preload("res://Entities/Letters/Sounds/letterPlaced.mp3"),
	"letterTaken":preload("res://Entities/Letters/Sounds/letterTaken.mp3")
}

var pool: Array[AudioStreamPlayer2D] = []

func _ready():
	for i in range(POOL_SIZE):
		var player := AudioStreamPlayer2D.new()
		player.bus = "SFX"  # Optional: assign to a specific audio bus
		player.volume_db = -6
		add_child(player)
		pool.append(player)

func play_sfx(sfx_name: String, sfx_position: Vector2):
	if not SOUNDS.has(sfx_name):
		push_warning("Unknown SFX name: %s" % sfx_name)
		return
		
	var stream = SOUNDS[sfx_name]
	
	for player in pool:
		if not player.playing:
			player.stream = stream
			player.global_position = sfx_position
			player.play()
			return
