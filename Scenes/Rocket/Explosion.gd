extends Node3D

@onready var emitter = $GPUParticles3D

func emit():
	emitter.emitting = true
