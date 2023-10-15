extends Node3D

signal status_changed(speed)

@export var speed = 10
@export var max_height = 23.7
@export var swich_off_delay = 0.2

@onready var box = $Box
@onready var initial_pos = box.position
@onready var elevator_speed = speed

var active = false
var was_moving = false
var moving = false

func _process(delta):
	moving = false
	if active and box.position.y + delta * elevator_speed <= initial_pos.y + max_height:
		box.position.y += delta * elevator_speed
		moving = true
	elif not (active) and box.position.y - delta * elevator_speed >= initial_pos.y:
		box.position.y -= delta * elevator_speed
	
	if not was_moving == moving:
		if moving: status_changed.emit(speed)
		else: status_changed.emit(0)
		
	was_moving = moving
		
func activate():
	active = true

func deactivate():
	elevator_speed = 0
	active = false
	await get_tree().create_timer(swich_off_delay).timeout
	elevator_speed = speed
