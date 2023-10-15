extends Label

var bullets = 10
var max_bullets = 10

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
	text = "bullets: %s/%s" % [bullets, max_bullets]
