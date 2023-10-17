extends Node3D

@onready var fade = $Fade

func _ready():
	fade.show_self()
	fade.fade_in()

func level_passed():
	fade.fade_out()

func _on_fade_fade_out_finished():
	get_tree().change_scene_to_file("res://levels/screen.tscn")
