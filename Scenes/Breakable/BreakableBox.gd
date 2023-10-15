extends Node3D

@onready var destroyArea = $Box/DestroyArea
@onready var boxMesh = $Box/box
@onready var material : StandardMaterial3D = boxMesh.get_surface_override_material(0).duplicate()
@onready var orangeMaterial = load("res://Scenes/Breakable/breakable.tres")
@onready var yellowMaterial = load("res://Scenes/Breakable/breakable_deactivated.tres")

const INTERVAL = 1.5

func deactivate():
	destroyArea.queue_free()
	await get_tree().create_timer(INTERVAL/2).timeout
	
	boxMesh.set_surface_override_material(0, orangeMaterial)
	await get_tree().create_timer(INTERVAL).timeout
	
	boxMesh.set_surface_override_material(0, yellowMaterial)
	await get_tree().create_timer(INTERVAL).timeout
	
	material.next_pass = null
	boxMesh.set_surface_override_material(0, material)
