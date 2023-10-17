extends Node3D

var triggers = 4

func _ready():
	$SpotLight3D.light_energy = 0

func endOfLevel():
	$EndBox.queue_free()
	$Turrets.queue_free()
	$SpotLight3D.light_energy = 7

func disabledBall():
	triggers -= 1
	if triggers <= 0:
		endOfLevel()
