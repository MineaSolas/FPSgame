extends Node3D

@export var resetPosition = Vector3(0,0,0)
@export var nextDeathZone : Node3D

@onready var label = $"../../Player/Head/Camera3d/Control/Skip"

var player
var nrFails = 0
var justLeft = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if label.visible == true and Input.is_action_just_pressed("SkipStage") and player.position.z <= resetPosition.z + 1 and player.position.z > nextDeathZone.resetPosition.z:
		nextDeathZone.reset_position(player)
		label.visible = false
		nrFails = 0
		
	if player != null and !justLeft:
		if player.position.z > resetPosition.z + 1 or player.position.z <= nextDeathZone.resetPosition.z:
			nrFails = 0
			label.visible = false
			justLeft = true


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		reset_position(player)
		nrFails += 1
		if nrFails >= 6:
			label.visible = true
	

func reset_position(player):
	player.position = resetPosition
