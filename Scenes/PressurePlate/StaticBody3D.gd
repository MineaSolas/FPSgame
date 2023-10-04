extends StaticBody3D

signal switched_on
signal switched_off

@onready var plate = $plate
@onready var colored_part = $plate/MeshInstance3D
@onready var material : StandardMaterial3D = colored_part.get_surface_override_material(0).duplicate()

@export var turned_on = false :
	set(value):
		turned_on = value
		set_color()

@export var color_off = Color.RED
@export var color_on = Color.GREEN

@export var animation_speed = 0.1

func _ready():
	set_color()
	
func _process(delta):
	if turned_on and plate.position.y > 0.06:
		plate.position.y -= delta * animation_speed
	elif not (turned_on) and plate.position.y < 0.13:
		plate.position.y += delta * animation_speed
	
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

func _on_switch_area_body_entered(body):
	if body.is_in_group("Player"):
		turned_on = true
	

