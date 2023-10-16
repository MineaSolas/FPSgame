extends "res://Scenes/Player/PlayerBlastControl2/playerBlastControl2.gd"

signal no_bullets
signal player_died

var bullets
var max_bullets = 30
var reset_time = 0

func _ready():
	bullets = max_bullets
	$"../UI/Ammo".set_bullet_counts(max_bullets)
	$"../UI/Ammo".show()
	super._ready()

func _process(delta):
	if Input.is_action_pressed("reset"):
		reset_time += delta
	else:
		reset_time = 0
	if reset_time >= 1.5:
		death()

func shoot():
	if bullets <= 0:
		return
	bullets -= 1
	$"../UI/Ammo".on_shoot()
	super.shoot()
	if bullets == 0:
		emit_signal("no_bullets")

func death():
	emit_signal("player_died")
	super.death()

func _on_bullet_refill_body_entered(body):
	if body.name == "Player":
		bullets = max_bullets
		$"../UI/Ammo".on_refill()
