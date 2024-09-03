extends State
class_name EnemyWander

@export var enemy = CharacterBody3D
@export var move_speed = 10.0

var move_direction : Vector3
var wander_time : float

func Enter():
	# Set initial wander time
	wander_time = randf_range(2.0, 5.0)
	
	# Set initial movement direction
	random_wander()

func Exit():
	# Reset any state-specific variables if needed
	pass

func Update(delta):
	# Reduce wander time
	wander_time -= delta
	
	# Check if it's time to change direction
	if wander_time <= 0.0:
		random_wander()
		wander_time = randf_range(2.0, 5.0)

	# Move the enemy in the current direction
	enemy.translation += move_direction * move_speed * delta

func random_wander():
	# Randomize the movement direction
	move_direction = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
