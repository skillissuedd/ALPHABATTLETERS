extends Control

class_name letterDisplayClass
signal animation_ended

#Default letter stats
var stats: Dictionary
@onready var death_mark = $Panel/DeathMark

#Letter face and stats
@onready var letter2D = get_parent().get_parent() as letter2Dclass
@onready var letter_label: Label = $Panel/LetterLabel
@onready var ATK_label: Label = $Panel/ATKLabel
@onready var HP_label: Label = $Panel/HPLabel
@onready var upgrade_label: Label = $Panel/UpgradeLabel

var current_element = "Neutral"
var is_enemy:bool

func vector_upgrade_animation():
	var tween := create_tween()
		# Step 1: normalize rotation
	letter_label.rotation_degrees = fmod(letter_label.rotation_degrees, 360)
		# Step 2: scale up
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(letter_label, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_callback(Callable(Global.sfx_manager, "upgrade_vector"))
	# Step 3: rotate after scale-up
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(letter_label, "rotation_degrees", letter_label.rotation_degrees + 180, 0.5)
	
	# Step 4: scale back down
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(letter_label, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.8)
	
	# Step 5: after everything, pop the labels in parallel
	tween.tween_callback(Callable(self, "_pop_stat_labels"))
	emit_signal("animation_ended")
	
func rebirth_upgrade_animation(newLetter: String):
	# Step 2: Fade out current letter
	var tween = create_tween()
	tween.tween_property(letter_label, "modulate:a", 0.0, 0.3)

	# Step 3: After fade out, change text
	tween.tween_callback(Callable(self, "change_letter").bind(newLetter))

	# Step 4: Add reforming particles (converge inward)
	tween.tween_callback(Callable(self, "_add_reform_particles").bind(letter_label))

	# Step 5: Fade in new letter
	tween.tween_property(letter_label, "modulate:a", 1.0, 0.3)
	emit_signal("animation_ended")
	
func _pop_stat_labels():
	var tween := create_tween()
	var pop_scale = Vector2(1.5, 1.5)
	var normal_scale = Vector2(1.0, 1.0)
	
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(ATK_label, "scale", pop_scale, 0.5)
	tween.tween_property(HP_label, "scale", pop_scale, 0.5)
	
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(ATK_label, "scale", normal_scale, 0.5).set_delay(0.1)
	tween.tween_property(HP_label, "scale", normal_scale, 0.5).set_delay(0.1)
	update_stats()

	#On ready
func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	await get_tree().process_frame
	
func change_letter(character: String):
	letter_label.text = str(character)
	
func update_stats(attack: int = letter2D.properties.attack, hp: int = letter2D.properties.max_hp):
	ATK_label.text = str(attack)
	HP_label.text = str(hp)

func change_element(element: String):
	var font: Font = null
	match element:
		"Water":
			font = load("res://fonts/VarelaRound-Regular.ttf")
		"Fire":
			font = load("res://fonts/PirataOne-Regular.ttf")
		"Electric":
			font = load("res://fonts/Orbitron-VariableFont_wght.ttf")
		"Earth":
			font = load("res://fonts/AlfaSlabOne-Regular.ttf")
			letter_label.add_theme_font_size_override("font_size", 60)
			
	if font:
		letter_label.add_theme_font_override("font", font)
