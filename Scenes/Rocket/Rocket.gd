extends Area3D

@export var _decal: PackedScene
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
	
	# Rocket hit => sound/particles/decal
	set_inactive()
	$AudioStreamPlayer3D.pitch_scale = randf_range(1,1.5)
	$AudioStreamPlayer3D.play()
	$ExplosionParticles.emitting = true
	plant_decal()
	await $AudioStreamPlayer3D.finished
	queue_free()

func plant_decal():
	if ($RayCast3D.get_collider() == null):
		return
	
	# Plant a new decal
	var new_decal = _decal.instantiate()
	get_tree().get_root().add_child(new_decal) 
	new_decal.global_position = $RayCast3D.get_collision_point()
	var normal = $RayCast3D.get_collision_normal()
	# Figuring this out took way too long
	# Align the decal to the normal vector
	if normal != Vector3.UP:
		new_decal.look_at(new_decal.global_position + normal, Vector3.UP)
		new_decal.transform = new_decal.transform.rotated_local(Vector3.RIGHT, PI/2)
	new_decal.rotate(normal, randf() * 2.0 * PI)

func set_inactive():
	running = false
	$MeshInstance3D.visible = false
	$FireParticles.emitting = false

func _on_area_entered(area):
	if area.has_method("hit"):
		area.hit()


func _on_life_span_timeout():
	queue_free()
