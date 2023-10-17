extends StaticBody3D

signal hit_signal

@onready var target_mesh: MeshInstance3D = $"../MeshInstance3D"
@onready var mesh_target_hit = load("res://assets/meshes/target_hit.obj")
@onready var audio_stream_player = $"../AudioStreamPlayer3D"

var target_hit_sound = preload("res://assets/sounds/394795__lanooskiproductions__ding.wav")

@export var has_been_hit = false :
	set(value):
		has_been_hit = value
		target_mesh.mesh = mesh_target_hit
		hit_signal.emit()

func parent_hit():
	if not has_been_hit:
		has_been_hit = true
		audio_stream_player.stream = target_hit_sound
		audio_stream_player.play()

func target_has_been_hit():
	return has_been_hit
