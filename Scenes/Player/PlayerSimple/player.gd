extends CharacterBody3D

@onready var animations = $AnimationPlayer
@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var cam = $Head/Camera3d as Camera3D
@onready var head = $Head

@export var _bullet_scene : PackedScene

var speed
var mouseSensibility = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
var push_force = 80
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.0
const JUMP_VELOCITY = 5.5
const GROUND_INERTIA = 7.0
const AIR_INERTIA = 3.5
const gravity = 11

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	gunRay.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Handle Shooting
	if Input.is_action_just_pressed("Shoot"):
		shoot()
	# Handle Sprinting
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * GROUND_INERTIA)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * GROUND_INERTIA)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * AIR_INERTIA)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * AIR_INERTIA)
	
	# Check if we hit a kill block
	check_kill_block_hits()
	
	# At the end of the level, use 'all_targets_hit' to check if all targets have been hit

	move_and_slide()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouseSensibility
		$Head/Camera3d.rotation.x -= event.relative.y / mouseSensibility
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

func shoot():
	if not gunRay.is_colliding():
		return
	var bulletInst = _bullet_scene.instantiate() as Node3D
	bulletInst.set_as_top_level(true)
	get_parent().add_child(bulletInst)
	bulletInst.global_transform.origin = gunRay.get_collision_point() as Vector3
	bulletInst.look_at((gunRay.get_collision_point()+gunRay.get_collision_normal()),Vector3.BACK)
	print(gunRay.get_collision_point())
	print(gunRay.get_collision_point()+gunRay.get_collision_normal())
	# Check if we hit a target
	check_target_hits()

# Check if the player hit a kill block and kill the player / reset the level
func check_kill_block_hits():
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		var is_kill_block = collision.get_collider().has_meta("kill_block")
		if is_kill_block:
			print("Player should be killed")

# Check if the gun hit a target and mark the target as hit
# Possible update of color/texture of node can be done to indicate the target has been hit
func check_target_hits():
	var collider = gunRay.get_collider() as Node3D
	var is_target = collider.has_meta("target")
	if is_target:
		collider.set_meta("target_hit", true)

# Check if all targets in the node tree of the scene have been hit
func all_targets_hit():
	var scene = get_tree().current_scene
	return _all_targets_hit(scene.get_children())

# Recursively check if all targets in the node tree have been hit
func _all_targets_hit(nodes: Array[Node]):
	for node in nodes:
		var is_target = node.has_meta("target")
		var is_hit = (node.get_meta("hit", false) == true) as bool
		if is_target && !is_hit:
				return false
		if !_all_targets_hit(node.get_children()):
			return false
	return true
