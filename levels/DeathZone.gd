extends Area3D

func _on_body_entered(body):
	if body.name == "Player":
		get_tree().reload_current_scene()
