extends CharacterBody3D

#Player Nodes
@onready var head = $Head
@onready var eyes = $Head/Eyes
@onready var standing_collision = $Standing_Collision
@onready var crouch_collision = $Crouch_Collision
@onready var is_object_above = $IsObjectAbove
@onready var camera_3d = $Head/Eyes/Camera3D

#Character Movement Speed
var currentSpeed = 10.0
const movementSpeed = 10.0
const runningSpeed = 20.0
const crouchSpeed = 5.0
const jumpVelocity = 6.0
var lerpSpeed = 10.0

const headBobbing_Sprint_Speed = 22.0
const headBobbing_Walk_Speed = 14.0
const headBobbing_Crouch_Speed = 7.0

const headBobbing_Sprint_Intensity = 0.5
const headBobbing_Walk_Intensity = 0.3
const headBobbing_Crouch_Intensity = 0.2

var headBobbing_Current_Intensity = 0.0
var headBobbing_Vector = Vector2.ZERO
var headBobbing_index = 0.0

#Character Movement Input
var direction = Vector3.ZERO
var crouchingDepth = 2

#Mouse Control
@export var mouseSens = 0.1
#var bullet = load("res://Scenes/bullet.tscn")
#var instance

#@onready var gun_barrel = $Head/Camera3D/Gun/RayCast3D

#Physics
var pushForce = 1.0



# test again
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Locks the Mouse to the center
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	#It doesn't let the mouse overrotate up or down
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouseSens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouseSens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	#Let the Player Crouch
	if Input.is_action_pressed("Crouch"):
		currentSpeed = crouchSpeed
		
		#It Lerps the Crouch
		head.position.y = lerp(head.position.y, 4.2 / crouchingDepth, delta*lerpSpeed) 
		standing_collision.disabled = true 
		crouch_collision.disabled = false
		headBobbing_Current_Intensity = headBobbing_Crouch_Intensity
		headBobbing_index += headBobbing_Crouch_Speed*delta
		
	#Detects if there is an object above the player
	elif !is_object_above.is_colliding(): 
		standing_collision.disabled = false
		crouch_collision.disabled = true
		
		#It Lerps the Standing Up
		head.position.y = lerp(head.position.y, 4.2 , delta*lerpSpeed)
		
		#Switches the movement speeds
		if Input.is_action_pressed("Sprint"):
			headBobbing_Current_Intensity = headBobbing_Sprint_Intensity
			headBobbing_index += headBobbing_Sprint_Speed*delta
			currentSpeed = runningSpeed
		else:
			headBobbing_Current_Intensity = headBobbing_Walk_Intensity
			headBobbing_index += headBobbing_Walk_Speed*delta
			currentSpeed = movementSpeed
	
	
#	if Input.is_action_just_pressed("Attack"):
#		instance = bullet.instantiate()
#		instance.position = gun_barrel.global_position
#		instance.transform.basis = gun_barrel.global_transform.basis
#		get_parent().add_child(instance)
	
	if is_on_floor() && input_dir != Vector2.ZERO:
		headBobbing_Vector.y = sin(headBobbing_index)
		headBobbing_Vector.x = sin(headBobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, headBobbing_Vector.y*(headBobbing_Current_Intensity/2.0), delta*lerpSpeed)
		eyes.position.x = lerp(eyes.position.x, headBobbing_Vector.x*(headBobbing_Current_Intensity/2.0), delta*lerpSpeed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta*lerpSpeed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta*lerpSpeed)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Quits the Game
	if Input.is_action_pressed("Quit"):
		get_tree().quit()
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jumpVelocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerpSpeed)
	
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	move_and_slide()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * pushForce)
