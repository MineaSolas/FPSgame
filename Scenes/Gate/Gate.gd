extends Node3D

@onready var top = $Top
@onready var bottom = $Bottom
@export var opened = false
@export var animation_speed = 7

func _process(delta):
	
	if opened and top.position.y < 2.6:
		top.position.y += delta * animation_speed
	elif not (opened) and top.position.y > 1:
		top.position.y -= delta * animation_speed
		
	if opened and bottom.position.y > -2.6:
		bottom.position.y -= delta * animation_speed
	elif not (opened) and bottom.position.y < -1:
		bottom.position.y += delta * animation_speed
		
	top.position.y = clamp(top.position.y, 1, 2.6)
	bottom.position.y = clamp(bottom.position.y, -2.6, -1)
		
func open():
	opened = true
	
func close():
	opened = false
