extends Area3D

@onready var fade = $"../../Fade"

func _on_body_entered(body):
	if body.name == "Player":
		print("You beat the level!")
		get_tree().current_scene.level_passed()
