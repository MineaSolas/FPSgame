extends Node3D

signal hit_signal

var init_position

@export var offset: Vector3 = Vector3(0, 0, 5)
@export var duration = 5.0
@export var has_been_hit = false :
	set(value):
		has_been_hit = value
		print("Updating target mesh")
		target_mesh.mesh = mesh_target_hit
		print("Updated target mesh")
		hit_signal.emit()

@onready var target_mesh: MeshInstance3D = $MeshInstance3D
@onready var mesh_target_hit = load("res://assets/meshes/target_hit.obj")

func _ready():
	init_position = global_position
	start_tween()

func hit():
	if not has_been_hit:
		has_been_hit = true

func target_has_been_hit():
	return has_been_hit
	
func start_tween():
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	tween.tween_property($".", "position", init_position + offset, duration/2)
	tween.tween_property($".", "position", init_position, duration/2)
