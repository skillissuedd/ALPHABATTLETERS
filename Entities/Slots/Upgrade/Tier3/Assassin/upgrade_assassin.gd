extends slot_class
var is_used: bool = false

func letter_is_placed():
	if !is_used:
		var upgrade_list = Global.letter_stats.UPGRADE_LIST
		if current_letter.get_upgrade() == null:
			var current_tier = upgrade_list["Tier 3"]
			var current_upgrade = current_tier[randi() % current_tier.size()]
			match current_upgrade:
				"The Vector":
					current_letter.current_hp = current_letter.current_atk
					current_letter.current_atk = current_letter.max_hp
					current_letter.max_hp = current_letter.current_hp
					current_letter.properties.update_stats(current_letter.current_atk, current_letter.current_hp)
					current_letter.LetterDisplay.animate_letter_flip()
					#current_letter.properties.update_stats(current_letter.LetterDisplay.return_stats())
				"The Assassin":
					current_letter.LetterDisplay.animate_letter_flip()
				"The Rebirth":
					current_letter.LetterDisplay.animate_letter_flip()
				"The Pierce":
					current_letter.LetterDisplay.animate_letter_flip()
