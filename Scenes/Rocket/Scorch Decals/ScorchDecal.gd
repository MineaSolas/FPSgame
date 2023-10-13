extends Decal

@export var texture1 : Texture2D
@export var texture2 : Texture2D
@export var texture3 : Texture2D

func _ready():
	var rand = randi() % 3
	if rand == 0:
		texture_albedo = texture1
	elif rand == 1:
		texture_albedo = texture2
	else:
		texture_albedo = texture3

func _on_timer_timeout():
	queue_free()
