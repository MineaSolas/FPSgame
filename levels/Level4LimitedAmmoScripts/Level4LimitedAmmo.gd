extends Node3D

@onready var fade = $Fade
@onready var player = $Player

func _ready():
	player.progress.selected_lvl = 4
	
	fade.show_self()
	fade.fade_in()
	
	player.start_timer()

func level_passed():
	player.stop_timer()
	await get_tree().create_timer(1).timeout
	fade.fade_out()

func _on_fade_fade_out_finished():
	get_tree().change_scene_to_file("res://levels/screen.tscn")
