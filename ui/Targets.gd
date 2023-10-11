extends Label

var total_targets: int
var targets_hit: int

func _ready():
	var scene = get_tree().current_scene
	total_targets = _find_targets(scene.get_children())
	update_text()

func _find_targets(nodes: Array[Node]):
	var total = 0
	for node in nodes:
		if node.has_method("target_has_been_hit"):
			total += 1
		total += _find_targets(node.get_children())
	return total

func on_target_hit():
	targets_hit += 1
	update_text()

func reset():
	targets_hit = 0
	update_text()

func update_text():
	text = "Targets: %s/%s" % [targets_hit, total_targets]
