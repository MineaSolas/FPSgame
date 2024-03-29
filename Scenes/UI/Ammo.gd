extends Label

var bullets = 10
var max_bullets = 10

func _ready():
	label_settings.font_color = "ffffff"

func set_bullet_counts(new_bullet_count):
	bullets = new_bullet_count
	max_bullets = new_bullet_count
	update_bullet_counts()

func on_shoot():
	bullets -= 1
	update_bullet_counts()

func on_refill():
	bullets = max_bullets
	update_bullet_counts()

func update_bullet_counts():
	if bullets <= 5:
		$AnimationPlayer.play("low_bullets")
	if bullets == 0:
		$AnimationPlayer.stop()
		label_settings.font_color = "ff0000"
	text = "Ammo: %s/%s" % [bullets, max_bullets]
