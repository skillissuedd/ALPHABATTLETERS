extends TextureRect 
class_name infotab

@onready var info_header: Label = $VBoxContainer/info_header

@onready var info_text: Label = $VBoxContainer/Info_text


func set_text(text_to_set: String):
	info_text.text = text_to_set

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
