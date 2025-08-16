extends deck_class

func return_letters_to_deck():
	for letter in deck:
		Global.deck_scene.append_to_deck(letter)
