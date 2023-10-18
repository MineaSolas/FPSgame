extends Node2D

signal done_writing
signal player_answer
signal level_selected(level)

const LVL_NAMES = ["Introduction", "Hitting the targets", "Enemies and targets", "Limited use of ammo", "Advanced Platforming", "The final challenge"]
const LVL_PATHS = ["res://levels/level1complete.tscn", "res://levels/level2/Level2.tscn", "res://levels/level5/Level5.tscn", "res://levels/Level4LimitedAmmo.tscn", "res://levels/AdvancedPlatforming.tscn", "res://levels/level6/level6.tscn"]
const LVL_OBJECTIVES = ["Make it through the three sections as fast as possible.", 
"Find and hit all targets in the testing environment.", 
"Find and hit all targets without being killed by enemies.", 
"Reach the goal with limited ammunition.", 
"Make your way to the end of the parkour.", 
"Open up a way to the center target."]
const LVL_NOTES = ["Make sure to hit all the targets on the way.", 
"Think carefully where to shoot.", 
"Be careful, enemies can hide anywhere!", 
"Spare those rockets where possible!", 
"Beware of the hints and use the rear-view camera when jumping backwards!", 
"Use all your acquired skills to beat the four challenges."]

@onready var label = $CanvasLayer/ScreenText
@onready var fade = $Fade

var writing_delay = 0.001
var writing_speed = 3.0
var old_text = ""
var writing = false
@onready var progress = get_node("/root/Progress")

const NORMAL_TEXT = 30
const LARGE_TEXT = 60

const DEFAULT_LOADING_DELAY = 0.4
const DEFAULT_LINE_DELAY = 0.3
const DEFAULT_WRITING_DELAY = 0.001
const DEFAULT_WRITING_SPEED = 4.0

var exit = false
	
func _ready():
	fade.show_self()
	label.scroll_active = false
	fade.fade_in()

func format_time(ms):
	var minutes = int(ms / 60 / 1000)
	var seconds = int(ms / 1000) % 60
	var miliseconds = int(ms) % 1000
	return ("%02d" % minutes) + (":%02d" % seconds) + (":%03d" % miliseconds)
	
func _on_fade_out_finished():
	if exit:
		get_tree().quit()
	else:
		get_tree().change_scene_to_file(LVL_PATHS[progress.selected_lvl-1])

func _on_fade_in_finished():
	if not progress.selected_lvl:
		play_introduction()
	else:
		play_level_passed()
	
func _process(delta):
	if Input.is_action_just_pressed("confirm"):
		player_answer.emit()
	elif Input.is_action_just_pressed("exit"):
		exit = true
		player_answer.emit()
	if Input.is_action_just_pressed("selectLvl1"):
		level_selected.emit(1)
	elif Input.is_action_just_pressed("selectLvl2"):
		level_selected.emit(2)
	elif Input.is_action_just_pressed("selectLvl3"):
		level_selected.emit(3)
	elif Input.is_action_just_pressed("selectLvl4"):
		level_selected.emit(4)
	elif Input.is_action_just_pressed("selectLvl5"):
		level_selected.emit(5)
	elif Input.is_action_just_pressed("selectLvl6"):
		level_selected.emit(6)
	
func write(text, size, color=null, bold=false):
	var written_text = old_text
	for i in ceil(text.length() / writing_speed):
		await get_tree().create_timer(writing_delay).timeout
		written_text = old_text + "[font_size={" + str(size) + "}]" 
		if bold: written_text += "[b]"
		if color: written_text += "[color=" + color + "]"
		written_text += text.left((i+1)*writing_speed) 
		if color: written_text += "[/color]"
		if bold: written_text += "[/b]"
		written_text += "[/font_size]"
		label.text = written_text
	
	old_text = written_text
	done_writing.emit()
	
func write_line(text, size, color=null, bold=false):
	write(text+"\n", size, color, bold)
	
func play_level_passed():
	await get_tree().create_timer(0.5).timeout
	progress.passed[progress.selected_lvl-1] = true
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = 0.02
	write_line("TEST #" + str(progress.selected_lvl) + " - " + LVL_NAMES[progress.selected_lvl-1], LARGE_TEXT)
	await done_writing
	await get_tree().create_timer(0.5).timeout
	
	writing_delay = DEFAULT_WRITING_DELAY
	write("\nProject ID: ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line("4032IVGM6Y-GRP10-A1\n", NORMAL_TEXT, "yellow")
	await done_writing
	await get_tree().create_timer(0.5).timeout
	
	write("Test objective: ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line(LVL_OBJECTIVES[progress.selected_lvl-1], NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("Notes: ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line(LVL_NOTES[progress.selected_lvl-1] + "\n", NORMAL_TEXT, "#0048F5")
	await done_writing
	await get_tree().create_timer(0.5).timeout
	
	write_line("TEST PASSED !", NORMAL_TEXT + 10, "green")
	await done_writing
	await get_tree().create_timer(0.5).timeout
	
	write("\nTest duration: ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line(format_time(progress.time_records[progress.selected_lvl-1]), NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(0.5).timeout
	
	write("\nUpdating testing progress . ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = 2.0
	writing_delay = DEFAULT_LOADING_DELAY
	write(". .", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = DEFAULT_WRITING_DELAY
	write_line("  Tests passed: " + str(progress.passed.count(true)) + "/6\n", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	if (progress.passed.has(false)):
		write("Please, ", NORMAL_TEXT)
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
		
		write(" CONFIRM  <SPACE>  ", NORMAL_TEXT, "red")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
		
		write("to procceed with the next test or ", NORMAL_TEXT)
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
		
		write(" EXIT  <ESC>  ", NORMAL_TEXT, "red")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
		
		write("the system", NORMAL_TEXT)
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
		
		await player_answer
		
		if exit:
			write_line("  Interrupt !\n", NORMAL_TEXT, "purple")
			await done_writing
			await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
			play_exit()
		else:
			write_line("  Confirmed !\n", NORMAL_TEXT, "green")
			await done_writing
			await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
			play_test_selection()
	else:
		play_testing_completed()
	
func play_level_introduction():
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = 0.02
	write_line("TEST #" + str(progress.selected_lvl) + " - " + LVL_NAMES[progress.selected_lvl-1], LARGE_TEXT)
	await done_writing
	await get_tree().create_timer(0.5).timeout
	
	writing_delay = DEFAULT_WRITING_DELAY
	write("\nProject ID: ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line("4032IVGM6Y-GRP10-A1\n", NORMAL_TEXT, "yellow")
	await done_writing
	await get_tree().create_timer(0.5).timeout
	
	write("Test objective: ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line(LVL_OBJECTIVES[progress.selected_lvl-1], NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("Notes: ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line(LVL_NOTES[progress.selected_lvl-1] + "\n", NORMAL_TEXT, "#0048F5")
	await done_writing
	await get_tree().create_timer(0.5).timeout

	write("Please, ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write(" CONFIRM  <SPACE>  ", NORMAL_TEXT, "red")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("to procceed with the test or ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write(" EXIT  <ESC>  ", NORMAL_TEXT, "red")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("the system", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	await player_answer
	
	if exit:
		write_line("  Interrupt !\n", NORMAL_TEXT, "purple")
		await done_writing
		await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
		play_exit()
	else:
		write_line("  Confirmed !\n", NORMAL_TEXT, "green")
		await done_writing
		await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
		
		write("Initializing the test . ", NORMAL_TEXT)
		await done_writing
		await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
		
		writing_speed = 2.0
		writing_delay = DEFAULT_LOADING_DELAY
		write(". .", NORMAL_TEXT)
		await done_writing
		await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
		
		writing_speed = DEFAULT_WRITING_SPEED
		writing_delay = DEFAULT_WRITING_DELAY
		write_line("  Good luck !\n", NORMAL_TEXT, "white")
		await done_writing
		await get_tree().create_timer(1.5).timeout
		
		fade.fade_out()
	

	
func play_testing_completed():
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = 0.02
	write_line("TESTING COMPLETED !", NORMAL_TEXT + 10, "green")
	await done_writing
	await get_tree().create_timer(0.5).timeout
	
	write_line("\nAll test were passed successfully\n", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write_line("Displaying results:", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("#1 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[0], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("  |  passed in ", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line(format_time(progress.time_records[0]), NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("#2 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[1], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("  |  passed in ", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line(format_time(progress.time_records[1]), NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("#3 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[2], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("  |  passed in ", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line(format_time(progress.time_records[2]), NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("#4 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[3], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("  |  passed in ", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line(format_time(progress.time_records[3]), NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("#5 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[4], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("  |  passed in ", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line(format_time(progress.time_records[4]), NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("#6 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[5], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("  |  passed in ", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line(format_time(progress.time_records[5]), NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("\nPlease, ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write(" CONFIRM  <SPACE>  ", NORMAL_TEXT, "red")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("if you would like to continue testing or ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write(" EXIT  <ESC>  ", NORMAL_TEXT, "red")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("the system", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	await player_answer
	
	if exit:
		write_line("  Interrupt !\n", NORMAL_TEXT, "purple")
		await done_writing
		await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
		play_exit()
	else:
		write_line("  Confirmed !\n", NORMAL_TEXT, "green")
		await done_writing
		await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
		play_test_selection()

func play_exit():
	write("Shutting down . ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = 2.0
	writing_delay = DEFAULT_LOADING_DELAY
	write(". .", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = DEFAULT_WRITING_DELAY
	write_line("  Goodbye !\n", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(1.5).timeout
	
	exit = true
	fade.fade_out()

func play_introduction():
	await get_tree().create_timer(0.5).timeout
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = 0.02
	write_line("WELCOME TO THE SYSTEM !", LARGE_TEXT)
	await done_writing
	await get_tree().create_timer(1).timeout
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = DEFAULT_WRITING_DELAY
	write("\nChecking user identity . ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = 2.0
	writing_delay = DEFAULT_LOADING_DELAY
	write(". .", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = DEFAULT_WRITING_DELAY
	write_line("  Identity confirmed ! \n", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("Requesting related project material . ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = 2.0
	writing_delay = DEFAULT_LOADING_DELAY
	write(". .", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = DEFAULT_WRITING_DELAY
	write_line("  Request succeeded !\n", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write_line("Displaying results:", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write_line("Found projects: 42", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write_line("Active projects: 1\n", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("Opening project ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("4032IVGM6Y-GRP10-A1 ", NORMAL_TEXT, "yellow")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("(Active) . ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = 2.0
	writing_delay = DEFAULT_LOADING_DELAY
	write(". .", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = DEFAULT_WRITING_DELAY
	write_line("  Project loaded !\n", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("Checking project status . ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = 2.0
	writing_delay = DEFAULT_LOADING_DELAY
	write_line(". .\n", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = DEFAULT_WRITING_DELAY
	write_line("The exosceleton construction was completed", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write_line("Control software was installed", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write_line("All initial system checks were completed\n", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("Performing final system check . ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = 2.0
	writing_delay = DEFAULT_LOADING_DELAY
	write(". .", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = DEFAULT_WRITING_DELAY
	write_line("  No issues were found !\n", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("Project ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("4032IVGM6Y-GRP10-A1 ", NORMAL_TEXT, "yellow")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line("(Active) is ready\n", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("Please, ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write(" CONFIRM  <SPACE>  ", NORMAL_TEXT, "red")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("to procceed with the testing or ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write(" EXIT  <ESC>  ", NORMAL_TEXT, "red")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("the system", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	await player_answer
	
	if exit:
		write_line("  Interrupt !\n", NORMAL_TEXT, "purple")
		await done_writing
		await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
		play_exit()
	else:
		write_line("  Confirmed !\n", NORMAL_TEXT, "green")
		await done_writing
		await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
		play_test_selection()
	
func play_test_selection():
	write("Redirecting to test selection . ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = 2.0
	writing_delay = DEFAULT_LOADING_DELAY
	write(". .", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = DEFAULT_WRITING_DELAY
	write_line("  Redirected !\n", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("There are ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("six tests ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line("in total", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("They are ordered according to ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line("increasing difficulty", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("We recommend to ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line("procceed in order", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write_line("( However, it is possible to skip to a specific test if needed )\n", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("Please, ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write(" enter the number  ", NORMAL_TEXT, "red")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line("of the test you would like to execute:", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LINE_DELAY).timeout
	
	write("1 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[0], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	if (progress.passed[0]):
		write("  |  passed in ", NORMAL_TEXT, "green")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
		
		write(format_time(progress.time_records[0]), NORMAL_TEXT, "white")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("\n2 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[1], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	if (progress.passed[1]):
		write("  |  passed in ", NORMAL_TEXT, "green")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
		
		write(format_time(progress.time_records[1]), NORMAL_TEXT, "white")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("\n3 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[2], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	if (progress.passed[2]):
		write("  |  passed in ", NORMAL_TEXT, "green")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
		
		write(format_time(progress.time_records[2]), NORMAL_TEXT, "white")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("\n4 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[3], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	if (progress.passed[3]):
		write("  |  passed in ", NORMAL_TEXT, "green")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
		
		write(format_time(progress.time_records[3]), NORMAL_TEXT, "white")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("\n5 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[4], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	if (progress.passed[4]):
		write("  |  passed in ", NORMAL_TEXT, "green")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
		
		write(format_time(progress.time_records[4]), NORMAL_TEXT, "white")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("\n6 ", NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write("- " + LVL_NAMES[5], NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	if (progress.passed[5]):
		write("  |  passed in ", NORMAL_TEXT, "green")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
		
		write(format_time(progress.time_records[5]), NORMAL_TEXT, "white")
		await done_writing
		await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	progress.selected_lvl = await level_selected
	
	write("\n\nYou have selected test ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_WRITING_DELAY).timeout
	
	write_line("#" + str(progress.selected_lvl), NORMAL_TEXT, "white")
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	write("Loading test files . ", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = 2.0
	writing_delay = DEFAULT_LOADING_DELAY
	write(". .", NORMAL_TEXT)
	await done_writing
	await get_tree().create_timer(DEFAULT_LOADING_DELAY).timeout
	
	writing_speed = DEFAULT_WRITING_SPEED
	writing_delay = DEFAULT_WRITING_DELAY
	write_line("  Loaded !", NORMAL_TEXT, "green")
	await done_writing
	await get_tree().create_timer(1).timeout
	
	old_text = ""
	
	play_level_introduction()

