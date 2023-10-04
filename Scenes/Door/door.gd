extends Node3D

@onready var left_door = $left_door
@onready var right_door = $right_door
@export var opened = false
@export var animation_speed = 1.8

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
	opened = true
	
func close():
	opened = false
