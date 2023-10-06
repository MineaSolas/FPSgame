extends Node3D

signal target_hit

@export var muzzle_velocity = 25

var velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity += Vector3.ONE * delta
	look_at(transform.origin + velocity, Vector3.UP)
	transform.origin += velocity * delta


func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		emit_signal("target_hit", transform.origin)
		#TODO: catch signal in player script
	if body != get_parent().get_child(3):
		queue_free()
