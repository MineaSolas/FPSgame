extends CanvasLayer

@onready var animationPlayer = $AnimationPlayer
@onready var colorRect = $ColorRect

signal fade_out_finished
signal fade_in_finished

func fade_out():
	show()
	animationPlayer.play("FadeOut")
	
func fade_in():
	show()
	animationPlayer.play("FadeIn")

func show_self():
	colorRect.show()

func hide_self():
	colorRect.hide()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
		hide()
		emit_signal("fade_out_finished")
	elif anim_name == "FadeIn":
		hide()
		emit_signal("fade_in_finished")
