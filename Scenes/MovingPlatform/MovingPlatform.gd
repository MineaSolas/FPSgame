extends Node3D

@export var offset = Vector3(0, 0, -50)
@export var duration = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	start_tween()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func start_tween():
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	tween.tween_property($AnimatableBody3D, "position", offset, duration / 2)
	tween.tween_property($AnimatableBody3D, "position", Vector3.ZERO, duration / 2)
