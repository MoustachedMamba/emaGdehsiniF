extends CharacterBody3D


@export var walk_speed := 4.0
@export var sprint_speed := 7.0
@export var mouse_sensitivity := 0.002
@export var camera_responsive := Vector2(7.0, 7.0)
@export var air_control := 0.0
@export var gain_accel := 4.0
@export var lose_accel := 6.5
@export var bob_amp := 0.02
@export var bob_fr := 3.0
@export var max_stamina := 100

@onready var head := $Head
@onready var collider := $BodyCollider
@onready var camera := $Head/Camera3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_rot: Vector2
var look_target: Vector2
var current_speed := walk_speed
var target_speed := walk_speed
var head_bob_timer := 0.0
var vert_offset = 0.0
var sprinting := false
var walking := false
var start_pos: Vector3


func _ready():
	start_pos = position
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	current_speed = lerp(current_speed, target_speed, gain_accel * delta)
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	direction += (transform.basis * Vector3(0, 0, clamp(input_dir.y,-1,0))).normalized() * 0.3
	if direction and is_on_floor():
		walking = true
		velocity.x = lerp(velocity.x,direction.x * current_speed,gain_accel*delta)
		velocity.z = lerp(velocity.z,direction.z * current_speed,gain_accel*delta)
	elif is_on_floor():
		walking = false
		velocity.x = lerp(velocity.x, 0.0, lose_accel*delta)
		velocity.z = lerp(velocity.z, 0.0, lose_accel*delta)
	else:
		walking = false

	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, -deg_to_rad(70), deg_to_rad(70))

	if event.is_action_pressed("Exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event.is_action_pressed("Return") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _determine_speed():
	if sprinting:
		target_speed = sprint_speed
	else:
		target_speed = walk_speed
