extends Area3D
@export var speed = 50
var explosion_scene = preload("res://Scenes/Rocket/Explosion.tscn")

var running = true
signal objectHit(currPos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if running:
		position += transform.basis.y * speed * delta

func play_sound(parent):
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = preload("res://assets/sounds/blast2.wav")
	parent.add_child(audio_player)
	audio_player.play()
	var explosion = explosion_scene.instantiate()
	get_parent().add_child(explosion)
	explosion.position = position
	explosion.emit()

func _on_body_entered(_body):
	play_sound(_body)
	if running: 
		objectHit.emit(position)
	if _body.has_method("hit"):
		_body.hit()
	running = false
	queue_free()

func _on_area_entered(area):
	if area.has_method("hit"):
		play_sound(area)
		area.hit()
		if running: 
			objectHit.emit(position)
		running = false
		self.queue_free()
