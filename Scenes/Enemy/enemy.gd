extends CharacterBody3D

var player = null
# state is initially IDLE
var state = IDLE
var home_position

enum {ENGAGING, ALERT, IDLE}

const SPEED = 4.0
const ATTACK_RANGE = 10.0
const LENIENCE = 2.0

@export var player_path : NodePath
@export var engaged_detector_radius : float
@export var alert_detector_radius : float
@export var sight_distance : float

@onready var nav_agent =  $NavigationAgent3D
@onready var engaged_detector = $EngagedDetector
@onready var alert_detector = $AlertDetector
@onready var sight = $Sight

func _ready():
	player = get_node(player_path)
	home_position = global_position
	
	var to_scale_with = engaged_detector_radius * 2.0
	engaged_detector.scale = to_scale_with * Vector3(1.0, 1.0, 1.0)
	
	to_scale_with = alert_detector_radius * 2.0
	alert_detector.scale = to_scale_with * Vector3(1.0, 1.0, 1.0)
	
	sight.target_position.z = sight_distance

func _physics_process(delta):
	velocity = Vector3.ZERO
	
	if can_see_player():
			state = ENGAGING
			print("state = ENGAGING")
	
	if state == ENGAGING:
		if can_see_player():
			# if too close to target move back, else move towards target
			if target_is_in_range(ATTACK_RANGE - LENIENCE):
				move_towards_target(2.0 * global_position - player.global_position)
			elif !target_is_in_range(ATTACK_RANGE):
				move_towards_target(player.global_position)
		else:
			move_towards_target(player.global_position)

		# does enemy need to be able to look up and down as well? Currently they do not.
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	if state == ALERT:
		# does enemy need to be able to look up and down as well? Currently they do not.
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# when idle and not at indicated target position, enemy will move towards target position (i.e. go home)
	if state == IDLE and global_position != home_position:
		move_towards_target(home_position)
	
	move_and_slide()

func target_is_in_range(range):
	return global_position.distance_to(player.global_position) <= range
	
func can_see_player():
	return sight.is_colliding() and sight.get_collider().name == "Player"

func move_towards_target(target):
	nav_agent.set_target_position(target)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * SPEED

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
