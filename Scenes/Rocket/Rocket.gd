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
	# for hitting enemies, as they are not areas
	if _body.has_method("hit"):
		_body.hit()
	queue_free()


func _on_area_entered(area):
	if area.has_method("hit"):
		area.hit()
		self.queue_free()
