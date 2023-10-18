extends "res://Scenes/Player/PlayerBlastControl2/playerBlastControl2.gd"

var bullets
# either 28 or 30 should be right i think
var max_bullets = 30
var reset_time = 0

@onready var ammo_ui = $"Head/Camera3d/Control/LimitedAmmo/Ammo"
@onready var no_bullets_ui = $"Head/Camera3d/Control/LimitedAmmo/NoBullets"

func _ready():
	bullets = max_bullets
	ammo_ui.set_bullet_counts(max_bullets)
	ammo_ui.show()
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
	ammo_ui.on_shoot()
	super.shoot()
	if bullets == 0:
		no_bullets_ui._on_player_no_bullets()

func death():
	no_bullets_ui._on_player_player_died()
	super.death()
