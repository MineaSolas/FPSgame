extends CharacterBody3D

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var gunRay = $Head/Camera3D/RayCast3d as RayCast3D
@export var _bullet_scene : PackedScene
@export var _blast_curve : Curve
@export var _blast_radius = 2
@export var _blast_power = 10

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 7
const SENSITIVITY = 0.003 

#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.05
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(80))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * 1.5 * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Sprint
	if Input.is_action_pressed("Sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	# Handle Shooting
	if Input.is_action_just_pressed("Shoot"):
		shoot()
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	elif direction:
		if velocity.x < direction.x * speed:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed + velocity.x, delta * 1.0)
		if velocity.z < direction.z * speed:
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)
		else:
			velocity.z = lerp(velocity.z, direction.z * speed + velocity.z, delta * 1.0)
		#velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
		#velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	#var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	#var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	#camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func blast(blast_pos):
	var direction = position - blast_pos
	var knockback = _blast_power * _blast_curve.sample(direction.length()/_blast_radius)
	direction = direction.normalized() * knockback
	velocity += direction

func shoot():
	# Spawn Rocket
	var rocket_spawn = get_global_position()
	var rocket_inst = _bullet_scene.instantiate()
	get_parent().add_child(rocket_inst)
	
	# Pos = player Pos. Shoots towards looking direction
	rocket_inst.position = rocket_spawn
	rocket_inst.rotation.y = head.rotation.y
	rocket_inst.rotation.x = camera.rotation.x - PI/2
	
	# Callback when rocket hits object
	var callable = Callable(self, "blast")
	rocket_inst.connect("objectHit", callable, 0)
