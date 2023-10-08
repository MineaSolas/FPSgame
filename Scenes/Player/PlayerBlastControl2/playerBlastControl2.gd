extends CharacterBody3D

@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D

@export var HP = 3

@export_group("Bullets")
@export var _bullet_scene : PackedScene
@export var _blast_curve : Curve
@export var _blast_radius = 5
@export var _blast_power = 8
@export var reload_time = 0.5

@export_group("Movement")
@export var acceleration_ground = 35.0
@export var friction_ground = 20.0
@export var acceleration_air = 5.0
@export var friction_air = 2.0
@export var max_speed_ground = 5.0
@export var max_speed_air = 3.5
@export var jump_power = 5.0

var mouse_sensitivity = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0

var character_velocity = Vector3(0,0,0)
var environment_velocity = Vector3(0,0,0)

var can_shoot = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	gunRay.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Handle Shooting
	if Input.is_action_just_pressed("Shoot") and can_shoot:
		shoot()
		
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var normalized_velocity = velocity.normalized()
	
	var acc = acceleration_ground
	var friction = friction_ground
	var max_speed = max_speed_ground
	if not is_on_floor():
		acc = acceleration_air
		friction = friction_air
		max_speed = max_speed_air
		
	if direction.x == 0: 
		character_velocity.x = move_toward(character_velocity.x, 0, acc * delta)
	else: 
		character_velocity.x += direction.x * acc * delta
	if direction.z == 0: 
		character_velocity.z = move_toward(character_velocity.z, 0, acc * delta)
	else: 
		character_velocity.z += direction.z * acc * delta
		
	environment_velocity.x = move_toward(environment_velocity.x, 0, friction * delta)
	environment_velocity.z = move_toward(environment_velocity.z, 0, friction * delta)
	
	var xz_character_velocity = Vector2(character_velocity.x, character_velocity.z).limit_length(max_speed)
	character_velocity = Vector3(xz_character_velocity.x, character_velocity.y, xz_character_velocity.y)
	
	#print(character_velocity, environment_velocity)
		
	velocity = character_velocity + environment_velocity
	
	move_and_slide()
	
	if is_on_ceiling():
		environment_velocity.y = 0
		character_velocity.y = 0
	
	# Add the gravity.
	if is_on_floor():
		environment_velocity.y = 0
		character_velocity.y = 0
		if Input.is_action_just_pressed("Jump"):
			character_velocity.y = jump_power
	else:
		environment_velocity.y -= gravity/2 * delta
		character_velocity.y -= gravity/2 * delta

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouse_sensitivity
		$Head/Camera3d.rotation.x -= event.relative.y / mouse_sensitivity
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

func blast(blast_pos):
	var direction = position - blast_pos
	var knockback = _blast_power * _blast_curve.sample(direction.length()/_blast_radius)
	environment_velocity += direction.normalized() * knockback

func shoot():
	can_shoot = false
	
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
	
	await get_tree().create_timer(reload_time).timeout
	can_shoot = true

	# Check if we hit a target
	var collider = gunRay.get_collider() as Node3D
	if collider != null && collider.has_method("hit"):
		print("Hit target!")
		collider.hit()

func hit():
	HP -= 1
	if HP == 0:
		death()
	print("HIT")
	
func death():
	print("You are dead!")
	#TODO: Teleport to start of level (Marker3D at start?)
	HP = 3
	
