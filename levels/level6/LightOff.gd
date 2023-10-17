extends OmniLight3D

func lightOff():
	light_energy = 0


func _on_switch_switched_on():
	lightOff()
