extends Node3D

@export var numberOfTargets: int

signal allTargetsHit

func hitTarget():
	numberOfTargets -= 1
	print (numberOfTargets)
	if numberOfTargets <= 0:
		allTargetsHit.emit()
