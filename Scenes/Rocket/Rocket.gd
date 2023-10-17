extends Area3D
@export var speed = 50

var running = true
signal objectHit(currPos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if running:
		position += transform.basis.y * speed * delta


func _on_body_entered(_body):
	if running: 
		objectHit.emit(position)
	if _body.has_method("hit"):
		_body.hit()
	running = false
	queue_free()


func _on_area_entered(area):
	if area.has_method("hit"):
		area.hit()
		if running: 
			objectHit.emit(position)
		running = false
		self.queue_free()
