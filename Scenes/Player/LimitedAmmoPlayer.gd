extends "res://Scenes/Player/PlayerBlastControl2/playerBlastControl2.gd"

var bullets
var max_bullets = 20

func _ready():
	bullets = max_bullets
	$"../UI/Ammo".set_bullet_counts(max_bullets)
	$"../UI/Ammo".show()
	super._ready()
	

func shoot():
	if bullets <= 0:
		return
	bullets -= 1
	$"../UI/Ammo".on_shoot()
	super.shoot()


func _on_bullet_refill_body_entered(body):
	if body.name == "Player":
		bullets = max_bullets
		$"../UI/Ammo".on_refill()
