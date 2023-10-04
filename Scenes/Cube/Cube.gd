extends Node3D

@onready var destruction = $Destruction

func hit():
	destruction.destroy(2)
