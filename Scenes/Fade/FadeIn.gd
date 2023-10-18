extends CanvasLayer

@onready var animationPlayer = $AnimationPlayer
@onready var colorRect = $ColorRect
@onready var audioPlayer = $AudioStreamPlayer

signal fade_out_finished
signal fade_in_finished

func fade_out():
	show()
	var scene = get_tree().get_current_scene().get_name()
	if scene != "Screen":
		audioPlayer.play()
		await get_tree().create_timer(1).timeout
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
