extends Node3D

signal target_hit

@export var muzzle_velocity = 25

var velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#velocity += Vector3.ONE * delta
	#look_at(transform.origin + velocity, Vector3.UP)
	#transform.origin += velocity * delta
	translate(Vector3(0,0,delta * -1 * muzzle_velocity))


func _on_area_3d_body_entered(body):
	if body.has_method("hit"):
		body.hit()
	if body != get_parent().get_child(3) and body != get_parent():
		queue_free()
