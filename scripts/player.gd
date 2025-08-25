extends CharacterBody3D

@export_range(0.0, 50.0, 0.5) var min_speed:float = 0.0
@export_range(30.0, 100.0, 0.5) var max_speed:float = 50
@export_range(0.0, 1.0, 0.05) var turn_speed:float = 0.75
@export_range(0.0, 1.0, 0.05) var pitch_speed:float = 0.5
@export_range(0.0, 10.0, 0.1) var level_speed:float = 3.0
@export_range(10.0, 100.0, 1.0) var throttle_delta:float = 30.0
@export_range(0.0, 10.0, 0.1) var acceleration:float = 6.0
@export_range(1.0, 10.0, 1.0) var snap_speed:float = 5.0

@export var mesh_body : Node3D
@export var player_cam:Camera3D


var forward_speed:float = 0
var target_speed:float = 0

var turn_input:float= 0
var pitch_input:float= 0


@onready var animation_tree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

func get_input(delta):
	if Input.is_action_pressed("throttle_up"):
		target_speed = min(forward_speed + throttle_delta * delta, max_speed)
	else:
		target_speed = max(forward_speed - throttle_delta * delta, min_speed)
	if Input.is_action_pressed("throttle_down"):
		target_speed = max(forward_speed - throttle_delta * 2 * delta, min_speed)
	
	turn_input = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")
	pitch_input = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")
	
func _physics_process(delta):
	get_input(delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input*pitch_speed*delta)
	if pitch_input == 0:
		mesh_body.rotation.x = lerp(mesh_body.rotation.x,pitch_input,level_speed * snap_speed * delta)
		idle()
	else:
		moving()
		mesh_body.rotation.x = lerp(mesh_body.rotation.x,pitch_input,level_speed * delta)
		
	transform.basis = transform.basis.rotated(transform.basis.y, turn_input*turn_speed*delta)
	
	if turn_input == 0:
		mesh_body.rotation.y = lerp(mesh_body.rotation.y,turn_input,level_speed * snap_speed * delta)
		idle()
	else:
		moving()
		mesh_body.rotation.y = lerp(mesh_body.rotation.y,turn_input,level_speed * delta)
	
	forward_speed = lerp(forward_speed, target_speed, acceleration*delta)
	velocity = -transform.basis.z * forward_speed
	move_and_slide()

func moving():
	state_machine.travel("static")

func idle():
	state_machine.travel("idle")
