extends Area3D

signal part_broken(ends_game)

@onready var destruction = $Destruction
@export var ends_game = false

## A scene of the fragmented mesh containing multiple [MeshInstance3D]s.
@export var fragmented: PackedScene: set = set_fragmented
## The node where created shards are added to.
@onready var shard_container := get_node("../../")

@export_group("Animation")
## How many seconds until the shards fade away. Set to -1 to disable fading.
@export var fade_delay := 2.0
## How many seconds until the shards shrink. Set to -1 to disable shrinking.
@export var shrink_delay := 2.0
## How long the animation lasts before the shard is removed.
@export var animation_length := 2.0
## Power of exposion
@export var explosion_power := 2.0

@export_group("Collision")
## The [member RigidBody3D.collision_layer] set on the created shards.
@export_flags_3d_physics var shard_collision_layer = 1
## The [member RigidBody3D.collision_mask] set on the created shards.
@export_flags_3d_physics var shard_collision_mask = 1

func _ready():
	destruction.fragmented = fragmented
	destruction.shard_container = shard_container
	destruction.fade_delay = fade_delay
	destruction.shrink_delay = shrink_delay
	destruction.animation_length = animation_length
	destruction.collision_layer = shard_collision_layer
	destruction.collision_mask = shard_collision_mask
	

func set_fragmented(to: PackedScene) -> void:
	fragmented = to
	if is_inside_tree():
		get_tree().node_configuration_warning_changed.emit(self)

func hit():
	if get_parent().has_method("stop"):
		get_parent().stop()
		
	var rubble_player = AudioStreamPlayer3D.new()
	rubble_player.stream = preload("res://assets/sounds/524312__bertsz__rock-destroy.wav")
	get_parent().get_parent().add_child(rubble_player)
	
	var electricity_player = AudioStreamPlayer3D.new()
	electricity_player.stream = preload("res://assets/sounds/earcing.wav")
	get_parent().get_parent().add_child(electricity_player)
	
	rubble_player.play()
	if ends_game:
		electricity_player.play()
		await get_tree().create_timer(0.1).timeout
	
	destruction.destroy(explosion_power)
	part_broken.emit(ends_game)
