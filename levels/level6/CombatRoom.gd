extends Node3D

signal completeSignal

func room_complete():
	completeSignal.emit()
