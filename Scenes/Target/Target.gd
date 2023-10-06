extends StaticBody3D

signal hit_signal

@export var has_been_hit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hit():
	if not has_been_hit:
		has_been_hit = true
		hit_signal.emit()
