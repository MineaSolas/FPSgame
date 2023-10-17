extends StaticBody3D

signal switched_on
signal switched_off

@onready var target = $target
@onready var colored_part = $target/colored_part
@onready var material : StandardMaterial3D = colored_part.get_surface_override_material(0).duplicate()

@export var turned_on = false :
	set(value):
		turned_on = value
		set_color()

@export var color_off = Color.RED
@export var color_on = Color.GREEN

@export var animation_speed = 0.4
@export var pos_change = 0.22

func _ready():
	set_color()
	
func _process(delta):
	if turned_on and target.position.y > - pos_change:
		target.position.y -= delta * animation_speed
	elif not (turned_on) and target.position.y < 0:
		target.position.y += delta * animation_speed
	
func set_color():
	if not material:
		return
		
	if turned_on:
		material.albedo_color = color_on
	else:
		material.albedo_color = color_off

	colored_part.set_surface_override_material(0, material)
		
func send_signal():
	if turned_on:
		switched_on.emit()
	else:
		switched_off.emit()

func parent_hit():
	if not turned_on:
		turned_on = true
		send_signal()

func _on_pair_switched_on():
	turned_on = false

func _on_pair_switched_off():
	turned_on = true

func switch_on():
	turned_on = true
	
func switch_off():
	turned_on = false
