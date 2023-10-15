extends Node3D

@onready var destroyArea = $DestroyArea
@onready var floorMesh = $Floor/MeshInstance3D
@onready var material : StandardMaterial3D = floorMesh.get_surface_override_material(0).duplicate()
@onready var orangeMaterial = load("res://Scenes/Breakable/breakable.tres")
@onready var yellowMaterial = load("res://Scenes/Breakable/breakable_deactivated.tres")

func deactivate(interval):
	destroyArea.queue_free()
	
	floorMesh.set_surface_override_material(0, orangeMaterial)
	await get_tree().create_timer(interval).timeout
	
	floorMesh.set_surface_override_material(0, yellowMaterial)
	await get_tree().create_timer(interval).timeout
	
	material.next_pass = null
	floorMesh.set_surface_override_material(0, material)
