extends Node3D

signal hit_signal

func _on_target_hit_signal():
	hit_signal.emit()
