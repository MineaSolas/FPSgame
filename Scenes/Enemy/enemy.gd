extends CharacterBody3D

signal death


enum {ENGAGING, ALERT, RETURNING, IDLE, KILLED}

@export_category("Nodes")
@export var bullet : PackedScene = load("res://Scenes/Turret/bullet.tscn")

@export_category("Ranges")
@export var engaged_detector_radius : float
@export var alert_detector_radius : float
@export var sight_distance : float
@export var attack_range = 10.0

@export_category("Difficulty")
@export var hp : float
@export var lenience = 2.0
@export var speed = 4.0
@export var killable = true

@onready var nav_agent =  $NavigationAgent3D
@onready var engaged_detector = $EngagedDetector
@onready var alert_detector = $AlertDetector
@onready var sight = $Sight
@onready var killed_texture = load("res://art/denkeykong_killed.png")

var player : Node
@onready var map = get_tree().current_scene
@onready var home_position = global_position
@onready var does_follow_path = get_parent() is PathFollow3D

# state is initially IDLE
var state = IDLE
var pathfollow : PathFollow3D = null
var reloaded = true

func _ready():
	$Timer.stop()
	player = _find_player(get_tree().current_scene.get_children())
	if does_follow_path:
		pathfollow = get_parent()
	
	var to_scale_with = engaged_detector_radius * 2.0
	engaged_detector.scale = to_scale_with * Vector3(1.0, 1.0, 1.0)
	
	to_scale_with = alert_detector_radius * 2.0
	alert_detector.scale = to_scale_with * Vector3(1.0, 1.0, 1.0)
	
	sight.target_position.z = sight_distance
	
func _find_player(nodes: Array[Node]):
	for node in nodes:
		if node.name == "Player":
			return node
		var child_player = _find_player(node.get_children())
		if child_player != null:
			return child_player
	return null

func _process(delta):
	if state == KILLED:
		return
	
	velocity = Vector3.ZERO
	
	if can_see_player():
		state = ENGAGING
	if !is_at_home() and state != ENGAGING and state != ALERT:
		state = RETURNING
	if is_at_home() and state == RETURNING:
		global_position = home_position
		state = IDLE
	
	if state == ENGAGING:
		if can_see_player():
			# if too close to target move back, else move towards target
			if target_is_in_range(attack_range - lenience):
				move_towards_target(2.0 * global_position - player.global_position)
			elif !target_is_in_range(attack_range):
				move_towards_target(player.global_position)
		else:
			move_towards_target(player.global_position)
		
		# does enemy need to be able to look up and down as well? Currently they do not.
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		if reloaded:
			shoot()
			$Timer.start()
			reloaded = false
	
	if state == ALERT:
		# does enemy need to be able to look up and down as well? Currently they do not.
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	if state == RETURNING:
		move_towards_target(home_position)
	
	# when idle and not at indicated target position, enemy will move towards target position (i.e. go home)
	if state == IDLE and does_follow_path:
		pathfollow.progress += speed * delta
		move_and_slide()
		home_position = global_position
	else:
		move_and_slide()
	
func hit():
	if !killable or state == KILLED:
		return
	hp -= 1
	if hp <= 0:
		emit_signal("death")
		state = KILLED
		var material = StandardMaterial3D.new()
		material.albedo_texture = killed_texture
		$MeshInstance3D.set_surface_override_material(0, material)
		
		await get_tree().create_timer(1).timeout
		queue_free()

func target_is_in_range(range):
	return global_position.distance_to(player.global_position) <= range
	
func can_see_player():
	if not sight.is_colliding():
		return false
	if sight.get_collider():
		return sight.get_collider().is_in_group("Player")
	return false

func is_at_home():
	return global_position.distance_to(home_position) < 1

func move_towards_target(target):
	nav_agent.set_target_position(target)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * speed
	# look were they are going when they are returning
	if state == RETURNING:
		look_at(Vector3(velocity.x + global_position.x, global_position.y, velocity.z + global_position.z), Vector3.UP)

func shoot():
	var new_bullet = bullet.instantiate()
	new_bullet.muzzle_velocity = 12
	map.add_child(new_bullet)
	new_bullet.global_transform = global_transform

# If-check might be somewhat redundant at the moment because collision mask is also set to only player's layer.
func _on_alert_detector_body_entered(body):
	if body.name == "Player":
		state = ALERT
		print("state = ALERT")

func _on_alert_detector_body_exited(body):
	if body.name == "Player":
		state = IDLE
		print("state = IDLE")

func _on_engaged_detector_body_exited(body):
	if body.name == "Player":
		state = ALERT
		print("state = ALERT")

func _on_timer_timeout():
	reloaded = true
