extends Node3D

signal status_changed(speed)

@export var speed = 8.0
@export var max_height = 23.2
@export var swich_off_delay = 0.2
@export var down_speed_up = 1.5

@onready var box = $Box
@onready var initial_pos = box.position
@onready var elevator_speed = speed

var active = false
var was_moving = false
var moving = false

func _process(delta):
	move(delta)
	
func move(delta):
	moving = false
	
	if active and box.position.y <= initial_pos.y + max_height:
		box.position.y += delta * elevator_speed
		moving = true
	elif not (active) and box.position.y >= initial_pos.y:
		box.position.y -= delta * elevator_speed * down_speed_up
		
	box.position.y = clamp(box.position.y, initial_pos.y, initial_pos.y + max_height)
	
	if not was_moving == moving:
		if moving: status_changed.emit(speed)
		else: status_changed.emit(0)
		
	was_moving = moving
		
func activate():
	active = true

func deactivate():
	move(0.1)
	elevator_speed = 0
	active = false
	await get_tree().create_timer(swich_off_delay).timeout
	elevator_speed = speed
