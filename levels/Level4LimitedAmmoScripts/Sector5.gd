extends Node3D

var enemy_1_death = false
var enemy_2_death = false

@onready var door = $NavigationRegion3D/Door

func _on_enemy_death():
	enemy_1_death = true
	check_for_open()

func _on_enemy_2_death():
	enemy_2_death = true
	check_for_open()

func check_for_open():
	if enemy_1_death and enemy_2_death:
		door.open()

func _on_target_hit_signal():
	get_tree().current_scene.level_passed()
