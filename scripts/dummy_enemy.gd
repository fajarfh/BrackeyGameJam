extends CharacterBody3D

var speed = 10.0
var turning_speed = 3.0

@export var mesh_body : Node3D


var health = 30
var shootDelay = 0.1
var canShoot:bool = true


var projectile = load("res://assets/prefabs/projectile.tscn")
var instance

@onready var animation_tree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var gun = $MeshInstance3D/dummyGun
@onready var gun_barrel = $MeshInstance3D/dummyGun/RayCast3D
@onready var nav_agent = $NavigationAgent3D as NavigationAgent3D
@onready var player = $"../Player"
func _ready():
	call_deferred("setup_navigation")




func _physics_process(delta):

	if not player:
		return
	
	var target_direction = (player.global_position - global_position).normalized()
	
	var current_forward = -transform.basis.z
	
	var new_forward = current_forward.slerp(target_direction, turning_speed * delta)
	look_at(global_position + new_forward, Vector3.UP)
	velocity = -transform.basis.z * speed
	move_and_slide()

	
	#shooting
	if  canShoot:
		instance = projectile.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)
		
		canShoot = false
		#introducing shoot delay
		var timer:SceneTreeTimer = get_tree().create_timer(shootDelay)
		timer.timeout.connect(set.bind("canShoot", true))

		


func idle():
	state_machine.travel("idle")
	

func getHealth():
	return health
	
func setHealth(x):
	health = x

func getPosition():
	return mesh_body.position
