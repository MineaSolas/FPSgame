extends CharacterBody3D

@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
@onready var healthBar = $Head/Camera3d/Control/HealthBar
@onready var targetCounter = $Head/Camera3d/Control/Targets/Label

@export var max_health = 3
@export var has_health = false
var health = 2 : set = set_health

@export_group("Bullets")
@export var _bullet_scene : PackedScene
@export var _blast_curve : Curve
@export var _blast_radius = 5.0
@export var _blast_power = 8.0
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
var elevator_velocity = Vector3(0,0,0)

var elevator_speed = 0.0
var elevator_decceleration = 2.0

var can_shoot = true
var can_be_hit = true
var dead = false

@onready var timer = $Timer
@onready var timeLabel = $Head/Camera3d/Control/Time/Label
@onready var progress = get_node("/root/Progress")
var start_time = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	gunRay.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if has_health:
		health = max_health
		healthBar.visible = true

func _physics_process(delta):
	
	if dead:
		return
		
	if Input.is_action_just_pressed("RearView"):
		if $Head/Camera3d/Control/RearCam.visible:
			$Head/Camera3d/Control/RearCam.visible = false
		else:
			$Head/Camera3d/Control/RearCam.visible = true
	$Head/SubViewport/Camera3d2.global_transform = global_transform
	$Head/SubViewport/Camera3d2.rotation += Vector3(0, PI, 0)
	
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
	
	elevator_velocity.y = move_toward(elevator_velocity.y, 0, elevator_decceleration * delta)
	
	var xz_character_velocity = Vector2(character_velocity.x, character_velocity.z).limit_length(max_speed)
	character_velocity = Vector3(xz_character_velocity.x, character_velocity.y, xz_character_velocity.y)
	
		
	velocity = character_velocity + environment_velocity + elevator_velocity
	position += Vector3(0,elevator_speed,0) * delta
	
	move_and_slide()
	
	if is_on_ceiling():
		environment_velocity.y = 0
		character_velocity.y = 0
		elevator_velocity.y = 0
		
	if is_on_wall():
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if abs(collision.get_normal().x) > 0.75:
				environment_velocity.x = 0
				character_velocity.x = 0
			if abs(collision.get_normal().z) > 0.75:
				environment_velocity.z = 0
				character_velocity.z = 0
	
	# Add the gravity.
	if is_on_floor():
		environment_velocity.y = 0
		character_velocity.y = 0
		elevator_velocity.y = 0
	else:
		environment_velocity.y -= gravity/2 * delta
		character_velocity.y -= gravity/2 * delta
		
	if (is_on_floor() or elevator_speed > 0) and Input.is_action_just_pressed("Jump"):
		character_velocity.y = jump_power
		
	# TODO: when the end of the level has been reached, use 'all_targets_hit' 
	# to chekc if all targets have been hit. Level is not finished if not all
	# targets have been hit
	
func set_health(value):
	health = value
	
	var healths = healthBar.get_children()
	for i in healths.size():
		if (i+1) > health:
			healths[i].queue_free()
			
	for i in health:
		if (i+1) > healths.size():
			var newHealth = TextureRect.new()
			newHealth.scale = Vector2(0.4, 0.4)
			
			if (i+1) == max_health:
				newHealth.texture = load("res://art/health_bar_end.png")
				newHealth.position.x = 50 + 52*(i-1)
			elif (i+1) > 1:
				newHealth.texture = load("res://art/health_bar.png")
				newHealth.position.x = 50 + 52*(i-1)
			elif (i+1) == 1:
				newHealth.texture = load("res://art/health_bar_start.png")
				newHealth.position.x = 10
			
			healthBar.add_child(newHealth)
			
	healths = healthBar.get_children()
			
	if health == 0:
		death()
	
	if health == 1 and max_health > 1:
		healths[0].texture = load("res://art/health_bar_start_critical.png")
	else:
		healths[0].texture = load("res://art/health_bar_start.png")

func _input(event):
	if event is InputEventMouseMotion and !dead:
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
	var rocket_inst = _bullet_scene.instantiate()
	get_parent().add_child(rocket_inst)

	# Set rocket position to little above player's
	rocket_inst.position = position + Vector3(0,0.2,0)
	
	# Move the rocket a bit to the front so it doesn't come from inside player
	rocket_inst.rotation = $Head/Camera3d.global_rotation
	rocket_inst.rotation_degrees.x = -90
	rocket_inst.rotation_degrees.z = 0
	var offset = clamp(($Head/Camera3d.global_rotation_degrees.x+90)/70, 0, 3)
	rocket_inst.position += rocket_inst.transform.basis.y * offset
	
	# Direct the rocket towards the point where the player is aiming
	if gunRay.is_colliding(): 
		rocket_inst.look_at(gunRay.get_collision_point(), Vector3.UP)
	else:
		rocket_inst.rotation = $Head/Camera3d.global_rotation
	if rocket_inst.global_rotation == Vector3(0,0,0):
		rocket_inst.global_rotation = $Head/Camera3d.global_rotation
	rocket_inst.rotation_degrees.x -= 90
	
	# Callback when rocket hits object
	rocket_inst.connect("objectHit", self.blast, 0)
	
	await get_tree().create_timer(reload_time).timeout
	can_shoot = true

func hit():
	if can_be_hit:
		health -= 1
		can_be_hit = false
		# Invincibility frames here
		await get_tree().create_timer(1).timeout
		can_be_hit = true
	
func part_broken(ends_game):
	if ends_game:
		death()
	
func death():
	print("You are dead!")
	dead = true
	$AnimationPlayer.play("death")
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		get_tree().reload_current_scene()
	
func _set_elevator_speed(value):
	if value == 0:
		elevator_velocity = Vector3(0,elevator_speed,0)
	else:
		elevator_velocity = Vector3(0,0,0)
	elevator_speed = value

# Check if all targets in the node tree of the scene have been hit
func all_targets_hit():
	var scene = get_tree().current_scene
	return _all_targets_hit(scene.get_children())

# Recursively check if all targets in the node tree have been hit
func _all_targets_hit(nodes: Array[Node]):
	for node in nodes:
		if node.has_method("target_has_been_hit") && node.target_has_been_hit() != true:
				return false
		if !_all_targets_hit(node.get_children()):
			return false
	return true

func start_timer():
	start_time = Time.get_ticks_msec()
	timer.start()
	
func stop_timer():
	timer.stop()
	progress.time_records[progress.selected_lvl-1] = update_time()

func update_time():
	var ms = Time.get_ticks_msec() - start_time
	var minutes = int(ms / 60 / 1000)
	var seconds = int(ms / 1000) % 60
	timeLabel.text = ("%02d" % minutes) + (":%02d" % seconds)
	return ms
