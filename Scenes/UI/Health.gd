extends Label

var health = 3
var max_health = 3

func set_health(new_health):
	health = new_health
	max_health = new_health
	update_health()

func on_hit():
	health -= 1
	update_health()

func reset():
	health = max_health
	update_health()

func update_health():
	text = "health: %s" % health
