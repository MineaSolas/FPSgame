extends Area3D

func hit():
	print("target hit!")
	get_parent().hit()
