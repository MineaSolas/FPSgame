extends CSGSphere3D
var matOn = preload("res://assets/materials/EnergyLevels/EnergyOn.tres")
var matOff = preload("res://assets/materials/EnergyLevels/EnergyOff.tres")

func _ready():
	material = matOn

func glowOff():
	material = matOff
