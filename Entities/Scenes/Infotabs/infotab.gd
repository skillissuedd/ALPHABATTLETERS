extends TextureRect 
class_name infotab

@onready var info_header: Label = $VBoxContainer/info_header

@onready var info_text: Label = $VBoxContainer/Info_text



func match_upgrade(upgrade_name: String):
	match upgrade_name:
		"Pierce":
			info_header.text = "upgrades_pierce_name"
			info_text.text = "upgrades_pierce_hint"
		"Rebirth":
			info_header.text = "upgrades_rebirth_name"
			info_text.text = "upgrades_rebirth_hint"
		"Scar":
			info_header.text = "upgrades_scar_name"
			info_text.text = "upgrades_scar_hint"
		"Vector":
			info_header.text = "upgrades_vector_name"
			info_text.text = "upgrades_vector_hint"
		"Assassin":
			info_header.text = "upgrades_assassin_name"
			info_text.text = "upgrades_assassin_hint"
		"Halo":
			info_header.text = "upgrades_halo_name"
			info_text.text = "upgrades_halo_hint"
		"Trajectory":
			info_header.text = "upgrades_trajectory_name"
			info_text.text = "upgrades_trajectory_hint"
		"Berserker":
			info_header.text = "upgrades_berserker_name"
			info_text.text = "upgrades_berserker_hint"
		"Dart":
			info_header.text = "upgrades_dart_name"
			info_text.text = "upgrades_dart_hint"
		"Line":
			info_header.text = "upgrades_line_name"
			info_text.text = "upgrades_line_hint"
			
	if upgrade_name in ["Pierce", "Rebirth", "Scar", "Vector"]:
		info_header.add_theme_color_override("font_color", Color.SEA_GREEN)
		info_text.add_theme_color_override("font_color", Color.MEDIUM_SEA_GREEN)
		
	elif upgrade_name in ["Assassin", "Halo", "Trajectory"]:
		info_header.add_theme_color_override("font_color", Color.ROYAL_BLUE)
		info_text.add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
	
	elif upgrade_name in ["Berserker", "Dart", "Line"]:
		info_header.add_theme_color_override("font_color", Color.REBECCA_PURPLE)
		info_text.add_theme_color_override("font_color", Color.MEDIUM_PURPLE)
