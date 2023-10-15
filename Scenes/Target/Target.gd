extends StaticBody3D

signal hit_signal

@onready var target_mesh: MeshInstance3D = $"../MeshInstance3D"
@onready var mesh_target_hit = load("res://assets/meshes/target_hit.obj")

@export var has_been_hit = false :
	set(value):
		has_been_hit = value
		target_mesh.mesh = mesh_target_hit
		hit_signal.emit()

func hit():
	if not has_been_hit:
		has_been_hit = true

func target_has_been_hit():
	return has_been_hit
