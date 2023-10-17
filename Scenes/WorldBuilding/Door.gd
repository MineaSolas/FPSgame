extends Node3D

@onready var left_door = $left_door
@onready var right_door = $right_door
@onready var door_sliding_player = $DoorSlidingPlayer
@onready var door_opening_jingle_player = $DoorOpeningJinglePlayer
@export var opened = false
@export var animation_speed = 1.8

var sound_door_sliding = preload("res://assets/sounds/538225__zoeyholt__sliding-door.wav")
var sound_door_opening_jingle = preload("res://assets/sounds/573381__ammaro__ding.wav")

func _process(delta):
	
	if opened and left_door.position.x > -1.2:
		left_door.position.x -= delta * animation_speed
	elif not (opened) and left_door.position.x < 0:
		left_door.position.x += delta * animation_speed
		
	if opened and right_door.position.x < 1.2:
		right_door.position.x += delta * animation_speed
	elif not (opened) and right_door.position.x > 0:
		right_door.position.x -= delta * animation_speed
		
func open():
	door_opening_jingle_player.stream = sound_door_opening_jingle
	door_opening_jingle_player.play()
	door_sliding_player.stream = sound_door_sliding
	door_sliding_player.play()
	opened = true
	
func close():
	opened = false



func _on_switch_switched_on():
	open()
