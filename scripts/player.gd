extends CharacterBody3D

@export_range(0.0, 50.0, 0.5) var min_speed:float = 0.0
@export_range(30.0, 100.0, 0.5) var max_speed:float = 50
@export_range(0.0, 1.0, 0.05) var turn_speed:float = 0.75
@export_range(0.0, 1.0, 0.05) var pitch_speed:float = 0.5
@export_range(0.0, 10.0, 0.1) var level_speed:float = 3.0
@export_range(10.0, 100.0, 1.0) var throttle_delta:float = 30.0
@export_range(0.0, 10.0, 0.1) var acceleration:float = 10.0
@export_range(1.0, 10.0, 1.0) var snap_speed:float = 5.0

@export var mesh_body : Node3D
@export var player_cam:Camera3D
var tracked_objects = {}
var raycast_nodes = []

var forward_speed:float = 0
var target_speed:float = 0

var turn_input:float= 0
var pitch_input:float= 0

var health = 30
var shootDelay = 0.1
var canShoot:bool = true



var projectile = load("res://assets/prefabs/projectile.tscn")
var instance

@onready var animation_tree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var gun = $MeshInstance3D/dummyGun
@onready var gun_barrel = $MeshInstance3D/dummyGun/RayCast3D
@onready var detection_area = $Area3D

signal object_behind_camera(object_position: Vector3, object_node: Node3D)
signal object_left_detection(object_node: Node3D)

func _ready():
	# Connect Area3D signals
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	detection_area.area_entered.connect(_on_detection_area_area_entered)
	detection_area.area_exited.connect(_on_detection_area_area_exited)
	
	# Setup raycast nodes for 360-degree detection
	setup_raycast_detection()


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
	
	#shooting
	if Input.is_action_pressed("shoot") and canShoot:
		instance = projectile.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)
		
		canShoot = false
		#introducing shoot delay
		var timer:SceneTreeTimer = get_tree().create_timer(shootDelay)
		timer.timeout.connect(set.bind("canShoot", true))

	
	check_objects_behind_camera()
	print(get_objects_behind_camera())

func moving():
	state_machine.travel("static")

func idle():
	state_machine.travel("idle")
	

func getHealth():
	return health
	
func setHealth(x):
	health = x

func getPosition():
	return mesh_body.position


func _on_area_3d_body_entered(body: Node3D) -> void:
	pass # Replace with function body.


func _on_detection_area_body_entered(body):
	if body != self and body.has_method("get_global_position"):
		tracked_objects[body] = true

func _on_detection_area_body_exited(body):
	if body in tracked_objects:
		tracked_objects.erase(body)
		object_left_detection.emit(body)

func _on_detection_area_area_entered(area):
	if area != detection_area and area.has_method("get_global_position"):
		tracked_objects[area] = true

func _on_detection_area_area_exited(area):
	if area in tracked_objects:
		tracked_objects.erase(area)
		object_left_detection.emit(area)

func check_objects_behind_camera():
	var camera_transform = player_cam.global_transform
	var camera_forward = -camera_transform.basis.z  # Camera looks down -Z
	
	for obj in tracked_objects.keys():
		if not is_instance_valid(obj):
			tracked_objects.erase(obj)
			continue
			
		var to_object = obj.global_position - player_cam.global_position
		var dot_product = camera_forward.dot(to_object.normalized())
		
		# If dot product < 0, object is behind camera
		if dot_product < -0.1:  # Small threshold to avoid edge cases
			object_behind_camera.emit(obj.global_position, obj)

func get_objects_behind_camera() -> Array:
	var behind_objects = []
	var camera_transform = player_cam.global_transform
	var camera_forward = -camera_transform.basis.z
	
	for obj in tracked_objects.keys():
		if not is_instance_valid(obj):
			continue
			
		var to_object = obj.global_position - player_cam.global_position
		var dot_product = camera_forward.dot(to_object.normalized())
		
		if dot_product < -0.1:
			behind_objects.append({
				"node": obj,
				"position": obj.global_position,
				"distance": player_cam.global_position.distance_to(obj.global_position)
			})
	
	return behind_objects

func setup_raycast_detection():
	# Create raycast nodes for 360-degree detection
	var raycast_count = 8  # 8 directions around the player
	var detection_range = 100.0
	
	for i in range(raycast_count):
		var raycast = RayCast3D.new()
		add_child(raycast)
		raycast_nodes.append(raycast)
		
		# Calculate direction (horizontal plane around player)
		var angle = (i * PI * 2) / raycast_count
		var direction = Vector3(cos(angle), 0, sin(angle))
		raycast.target_position = direction * detection_range
		raycast.enabled = true

func raycast_detection() -> Array:
	var detected_objects = []
	var camera_transform = player_cam.global_transform
	var camera_forward = -player_cam.basis.z
	
	for raycast in raycast_nodes:
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			var hit_point = raycast.get_collision_point()
			
			# Check if this object is behind the camera
			var to_object = hit_point - player_cam.global_position
			var dot_product = camera_forward.dot(to_object.normalized())
			
			if dot_product < -0.1:
				detected_objects.append({
					"node": collider,
					"position": hit_point,
					"distance": player_cam.global_position.distance_to(hit_point)
				})
	
	return detected_objects
