extends Node3D

@onready var fade = $Fade
@onready var player = $Player

func _ready():
	player.progress.selected_lvl = 2
	player.finish_level_on_all_targets_hit(level_passed)
	
	fade.show_self()
	fade.fade_in()
	player.start_timer()

func level_passed():
	player.stop_timer()
	await get_tree().create_timer(1).timeout
	fade.fade_out()
	
func _on_fade_out_finished():
	get_tree().change_scene_to_file("res://levels/screen.tscn")

@onready var shootingRangeInnerDoor = $ShootingRange/Hallway5/Corridor/Door2
@onready var shootingRangeOuterDoor = $ShootingRange/Hallway5/Corridor/Door
@onready var elevatorBottomDoor = $Elevator/Bottom/Corridor2/Door
@onready var mainRoomFloor = $MainRoom/BreakableFloor
@onready var shootingRangeOuterPlate = $ShootingRange/Hallway5/PressurePlate2

const SR_OUTER_DOOR_DELAY = 0.4
const PLATE_DELAY = 0.2
const FLOOR_DELAY = 1
const FLOOR_INTERVALS = 1
const ELEVATOR_DOOR_DELAY = 1

func _on_shooting_range_left():
	shootingRangeInnerDoor.open()
	await get_tree().create_timer(SR_OUTER_DOOR_DELAY).timeout
	shootingRangeOuterDoor.open()
	await get_tree().create_timer(PLATE_DELAY).timeout
	shootingRangeOuterPlate.switch_on()
	await get_tree().create_timer(FLOOR_DELAY).timeout
	mainRoomFloor.deactivate(FLOOR_INTERVALS)
	await get_tree().create_timer(ELEVATOR_DOOR_DELAY).timeout
	elevatorBottomDoor.open()


@onready var gateLeft = $TimedShootingRange/Gate2
@onready var gateMiddle = $TimedShootingRange/Gate
@onready var gateRight = $TimedShootingRange/Gate3
@onready var shootingSwitch = $TimedShootingRange/Switch

const MiDDLE_GATE_OPEN_TIME = 2.25
const GATE_OPEN_TIME = 2
const GATE_OPENING_DELAY = 0.3

func start_shooting_practice():
	gateMiddle.open()
	await get_tree().create_timer(MiDDLE_GATE_OPEN_TIME).timeout
	gateMiddle.close()
	await get_tree().create_timer(GATE_OPENING_DELAY).timeout
	gateLeft.open()
	await get_tree().create_timer(GATE_OPEN_TIME).timeout
	gateLeft.close()
	await get_tree().create_timer(GATE_OPENING_DELAY).timeout
	gateRight.open()
	await get_tree().create_timer(GATE_OPEN_TIME).timeout
	gateRight.close()
	await get_tree().create_timer(GATE_OPENING_DELAY).timeout
	shootingSwitch.switch_off()
	
