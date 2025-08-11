extends Control


func _on_eng_button_up() -> void:
	change_language("en")
	

func _on_rus_button_up() -> void:
	change_language("ru")

func change_language(lang_code: String):
	TranslationServer.set_locale(lang_code)
	GlobalOptions.language = lang_code
	get_tree().change_scene_to_file("res://prototype/tutorial/tutorial.tscn")
