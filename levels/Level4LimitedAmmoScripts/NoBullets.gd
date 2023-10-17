extends Label

func _on_player_no_bullets():
	await get_tree().create_timer(1).timeout
	show()
	$AnimationPlayer.play("blinking")


func _on_player_player_died():
	hide()
