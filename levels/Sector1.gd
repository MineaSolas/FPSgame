extends Node3D

var target_1 = false
var target_2 = false
var target_3 = false
var target_4 = false

@onready var door = $Door

func _on_moving_target_2_hit_signal():
	target_1 = true
	check_for_open()

func _on_moving_target_3_hit_signal():
	target_2 = true
	check_for_open()

func _on_target_3_hit_signal():
	target_3 = true
	check_for_open()

func _on_target_2_hit_signal():
	target_4 = true
	check_for_open()

func check_for_open():
	if target_1 and target_2 and target_3 and target_4:
		door.open()
