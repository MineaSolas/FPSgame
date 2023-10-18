extends Node3D

@onready var fade = $Fade

# Called when the node enters the scene tree for the first time.
func _ready():
	fade.show_self()
	fade.fade_in()
	$Player/Head/Camera3d/Control/RearCam.visible = true
	$Player.start_timer()

func level_passed():
	await get_tree().create_timer(1).timeout
	fade.fade_out()

func _on_fade_fade_out_finished():
	get_tree().change_scene_to_file("res://levels/screen.tscn")


func _on_ending_body_entered(body):
	level_passed()
