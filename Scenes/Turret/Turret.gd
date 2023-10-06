extends Node3D

@export var range = 20
@export var bullet: PackedScene
var in_range = false
var target = null
var reloaded = false
var target_position = Vector3()
var new_bullet
var timelerped = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.stop()
	$Range/CollisionShape3D.shape.radius = range


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Rotate to target
	if in_range:
		var target_position = target.global_position - Vector3(0,1,0)
		$CSGCombiner3D/LookAt.look_at(target_position, Vector3.UP)
		var old_position = Quaternion($CSGCombiner3D/OuterRotateNode.transform.basis)
		var new_position = Quaternion($CSGCombiner3D/LookAt.transform.basis)
		var inbetween_position = old_position.slerp(new_position, 0.05)
		$CSGCombiner3D/OuterRotateNode.transform.basis = Basis(inbetween_position)
	
	#Shoot target if reloaded
	if in_range and reloaded:
		timelerped = 0
		new_bullet = bullet.instantiate()
		add_child(new_bullet)
		new_bullet.global_transform = $CSGCombiner3D/OuterRotateNode/InnerRotateNode/Gun/Muzzle.global_transform
		new_bullet.velocity = -new_bullet.transform.basis.z * new_bullet.muzzle_velocity
		target_position = target.global_position
		reloaded = false
		$CSGCombiner3D/OuterRotateNode/InnerRotateNode/Gun/Muzzle/ShootingSound.play()
		$Timer.start()


func _on_range_body_entered(body):
	if body is CharacterBody3D:
		$Timer.start()
		target = body
		in_range = true
		$CSGCombiner3D/OuterRotateNode/InnerRotateNode/Gun/Muzzle/TargetAcquiredSound.play()


func _on_range_body_exited(body):
	if body is CharacterBody3D:
		$Timer.stop()
		target = body
		in_range = false


func _on_timer_timeout():
	reloaded = true
