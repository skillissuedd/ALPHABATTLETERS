extends Node
#UPRADES
signal upgrade_slot_is_used
signal upgrade_completed
signal upgrade_panel_is_gone

signal round_is_won

func emit_round_is_won():
	round_is_won.emit()

func emit_upgrade_slot_is_used():
	upgrade_slot_is_used.emit()
	
func emit_upgrade_completed():
	upgrade_completed.emit()

func emit_upgrade_panel_is_gone():
	upgrade_panel_is_gone.emit()
