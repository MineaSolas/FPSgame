@tool
extends StaticBody3D

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
