extends CharacterBody3D

@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
@export var _bullet_scene : PackedScene
@export var _blast_curve : Curve
@export var _blast_radius = 2
@export var _blast_power = 10
var mouseSensibility = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	gunRay.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Handle Shooting
	if Input.is_action_just_pressed("Shoot"):
		shoot()
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	#if is_on_floor():
		#velocity.x = clamp(velocity.x, -10, 10)
		#velocity.z = clamp(velocity.x, -10, 10)
	
	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouseSensibility
		$Head/Camera3d.rotation.x -= event.relative.y / mouseSensibility
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

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
	rocket_inst.rotation.y = rotation.y
	rocket_inst.rotation.x = $Head/Camera3d.rotation.x - PI/2
	
	# Callback when rocket hits object
	var callable = Callable(self, "blast")
	rocket_inst.connect("objectHit", callable, 0)
