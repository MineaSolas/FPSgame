extends "res://Scenes/Player/PlayerBlastControl2/playerBlastControl2.gd"

var bullets
var max_bullets = 20

func _ready():
	bullets = max_bullets
	$"../UI/Ammo".set_bullet_counts(max_bullets)
	$"../UI/Ammo".show()
	super._ready()
	

func shoot():
	if bullets <= 0:
		return
	can_shoot = false
	bullets -= 1
	$"../UI/Ammo".on_shoot()
	
	# Spawn Rocket
	var rocket_spawn = position
	var rocket_inst = _bullet_scene.instantiate()
	get_parent().add_child(rocket_inst)
	
	# Pos = player Pos. Shoots towards looking direction
	rocket_inst.position = rocket_spawn
	rocket_inst.rotation.y = rotation.y
	rocket_inst.rotation.x = $Head/Camera3d.rotation.x - PI/2
	
	# Callback when rocket hits object
	var callable = Callable(self, "blast")
	rocket_inst.connect("objectHit", callable, 0)
	
	await get_tree().create_timer(reload_time).timeout
	can_shoot = true

	# Check if we hit a target
	var collider = gunRay.get_collider() as Node3D
	if collider != null && collider.has_method("hit"):
		$"../UI/Targets".on_target_hit()
		print("Hit target!")
		collider.hit()

func _on_bullet_refill_body_entered(body):
	bullets = max_bullets
	$"../UI/Ammo".on_refill()
