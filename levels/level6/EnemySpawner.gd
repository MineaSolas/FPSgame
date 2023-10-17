extends Node3D

@export var enemy : PackedScene

signal allEnemiesDead
var maxEnemies
var enemyCounter

func _ready():
	maxEnemies = get_child_count()

func  spawn_enemies():
	kill_enemies()
	for node in get_children():
		if node.is_in_group("SpawnPositions"):
			var newEnemy = enemy.instantiate()
			newEnemy.hp = 3
			node.add_child(newEnemy)
			newEnemy.connect("death", self.enemy_died, 0)
			enemyCounter = maxEnemies
			

func kill_enemies():
	for node in get_children():
		if node.get_child(0):
			node.get_child(0).queue_free()

func enemy_died():
	enemyCounter -= 1
	if enemyCounter <= 0:
		allEnemiesDead.emit()
