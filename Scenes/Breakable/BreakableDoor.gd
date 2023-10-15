extends Node

@onready var destroyArea = $DestroyArea
@onready var leftMesh = $DoorLeft_Teal
@onready var rightMesh = $Door_Right_Teal
@onready var material : StandardMaterial3D = leftMesh.get_surface_override_material(0).duplicate()
@onready var orangeMaterial = load("res://Scenes/Breakable/breakable.tres")
@onready var redMaterial = load("res://Scenes/Breakable/breakable_critical.tres")

@export var ends_game = false :
	set(value):
		ends_game = value
		update_type()
		

# Called when the node enters the scene tree for the first time.
func _ready():
	update_type()


func update_type():
	if destroyArea:
		destroyArea.ends_game = ends_game
		
		if ends_game:
			material.next_pass = redMaterial
		else:
			material.next_pass = orangeMaterial
		
		leftMesh.set_surface_override_material(0, material)
		rightMesh.set_surface_override_material(0, material)
