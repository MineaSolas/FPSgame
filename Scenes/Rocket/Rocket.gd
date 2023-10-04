extends Area3D
@export var speed = 50

var running = true
signal objectHit(currPos)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if running:
		position += transform.basis.y * speed * delta
	

func _on_body_entered(_body):
	running = false
	objectHit.emit(position)
	queue_free()
