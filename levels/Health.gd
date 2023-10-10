extends Label

var health = 3
const STARTING_HEALTH = 3

func on_hit():
	health -= 1
	text = "lives: %s" % health

func reset():
	health = STARTING_HEALTH
	text = "lives: %s" % health
