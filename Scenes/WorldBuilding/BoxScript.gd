@tool
extends StaticBody3D

@export var rotation_speed = Vector3(0,0,0)
@export var movement_speed = 0.0
@export var max_X = 0.0
@export var initial_X = 0.0

@export var edge_visibility =  [true, true, true, true,
								true, true, true, true,
								true, true, true, true] :
		set(value):
			edge_visibility = value
			for i in range(min(edge_visibility.size(), $edges.get_children().size())):
				$edges.get_child(i).set_visible(edge_visibility[i])
			
func _enter_tree() -> void:
	set_notify_transform(true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		for child in $edges.get_children():
			if child.has_method("update_scale"):
				child.update_scale()
				
				
func _process(delta):
	if rotation_speed: 
		rotation_degrees += delta * rotation_speed
	if movement_speed:
		position.x += delta * movement_speed
		if position.x >= max_X and movement_speed > 0:
			movement_speed = - movement_speed
		elif position.x <= initial_X and movement_speed < 0:
			movement_speed = - movement_speed
			
func stop():
	movement_speed = 0
	rotation_speed = 0
	
