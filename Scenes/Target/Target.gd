extends StaticBody3D

signal hit_signal

@onready var target_mesh: MeshInstance3D = $MeshInstance3D
@onready var mesh_target_hit = load("res://assets/target_hit.obj")

@export var has_been_hit = false :
	set(value):
		has_been_hit = value
		print("Updating target mesh")
		target_mesh.mesh = mesh_target_hit
		print("Updated target mesh")
		hit_signal.emit()

func hit():
	if not has_been_hit:
		has_been_hit = true

func target_has_been_hit():
	return has_been_hit
