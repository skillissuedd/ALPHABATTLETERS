extends Node2D
class_name SFXManager
const MYSTERY_ITEM_SOUND = preload("res://Entities/Letters/LetterUpgrades/mysteryItem.wav")


const POOL_SIZE := 12
var pool: Array[AudioStreamPlayer2D] = []

func _ready():
	for i in range(POOL_SIZE):
		var player := AudioStreamPlayer2D.new()
		player.bus = "SFX"  # Optional: assign to a specific audio bus
		player.volume_db = -6
		add_child(player)
		pool.append(player)

func play_sfx(stream: AudioStream, sound_position: Vector2):
	for player in pool:
		if not player.playing:
			player.stream = stream
			player.global_position = sound_position
			player.play()
			return

func hit_sound():
	var choice = randi() % 3 + 1
	match choice:
		1:
			play_sfx(preload("res://sounds/hit1.wav"), global_position)
		2:
			play_sfx(preload("res://sounds/hit2.wav"), global_position)
		3:
			play_sfx(preload("res://sounds/hit3.wav"), global_position)

func death_sound():
	play_sfx(preload("res://sounds/death1.wav"), global_position)

func upgrade_vector():
	play_sfx(MYSTERY_ITEM_SOUND, global_position)
