extends Node3D

@onready var fade = $Fade
@onready var player = $Player
# Called when the node enters the scene tree for the first time.
func _ready():
	fade.show_self()
	fade.fade_in()
	player.start_timer()
	
func level_passed():
	player.stop_timer()
	fade.fade_out()
	
func _on_fade_out_finished():
	get_tree().change_scene_to_file("res://levels/screen.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
