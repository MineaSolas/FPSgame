extends Node3D

@onready var fade = $Fade
@onready var player = $Player

var total_targets = 7
var hit_targets = 0
@onready var target_counter = player.targetCounter

func _ready():
	player.progress.selected_lvl = 5

	var targets = get_tree().get_nodes_in_group("Targets")
	total_targets = targets.size()
	for target in targets:
		target.connect("hit_signal", hit_target)

	set_target_counter_text()
	target_counter.show()

	fade.show_self()
	fade.fade_in()
	
	player.start_timer()

func hit_target():
	hit_targets += 1
	set_target_counter_text()
	if hit_targets == total_targets:
		level_passed()

func set_target_counter_text():
	target_counter.text = "Targets: " + ("%d" % hit_targets) + "/" + str(total_targets)	

func level_passed():
	player.stop_timer()
	await get_tree().create_timer(1).timeout
	fade.fade_out()

func _on_fade_fade_out_finished():
	get_tree().change_scene_to_file("res://levels/screen.tscn")
