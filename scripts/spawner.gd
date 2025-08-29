extends Node

@export var enemy: Resource
@export var enemy_spawn_number: int = 10
@export var enemy_spawn_points: Array[CSGSphere3D]

@export var obstacle: Array[Resource]
@export var obstacle_spawn_number: int = 30
@export var obstacle_spawn_points: Array[CSGSphere3D]

@onready var soft_bound = $"../Boundary/soft bound"

@export var biscuit: Resource
@export var biscuit_spawn_number: int = 5
@export var biscuit_spawn_points: Array[CSGSphere3D]

var enemies = []
var obstacles = []
var biscuits = []

signal biscuit_picked

func _ready():
	
	for k in range(0,biscuit_spawn_number):
		spawn_item(biscuit_spawn_points.pick_random(),biscuit, biscuits, "biscuit")
	
	for i in range(0,enemy_spawn_number):
		spawn_item(enemy_spawn_points.pick_random(),enemy, enemies, "enemy")
	
	for j in range(0,obstacle_spawn_number):
		spawn_item(obstacle_spawn_points.pick_random(),obstacle.pick_random(), obstacles, "obstacle")
	


func spawn_item(parent:Node3D, item:Resource, container:Array, name_suffix:String):

	var item_new:Node3D = load(item.resource_path).instantiate()
	var area_body:Area3D = item_new.get_node("%area_overlap")
	parent.add_child(item_new)
	item_new.position = random_loc(parent)
	item_new.name = name_suffix + "_" + str(len(container))
	container.append(item_new)
	
	area_body.connect("body_entered",reposition.bind(item_new, parent))
	area_body.connect("area_entered",reposition.bind(item_new, parent))

func reposition(body, node, parent):
	node.position = random_loc(parent)
	
func enm_collision(body):
	if body is CharacterBody3D:
		body.dying_prep()
		
	elif "bullet" in body.name:
		await get_tree().create_timer(2.0).timeout
		spawn_item(enemy_spawn_points.pick_random(), enemy, enemies, "enemy")
		var area_body:Area3D = enemies[-1].get_node("%area_overlap")
		area_body.disconnect("body_entered",reposition)
		area_body.disconnect("area_entered",reposition)
		
		var enm_bod:Area3D = enemies[-1].get_node("%enm_bod")
		enm_bod.connect("body_entered", enm_collision)

func itm_picked(body, node):
	if body is CharacterBody3D:
		biscuit_picked.emit()
		node.queue_free()
	
func random_loc(parent:Node3D) -> Vector3:
	var random_r = randf_range(0,parent.radius)
	var random_alpha = randf_range(0,2*PI)
	var random_beta = randf_range(0,2*PI)
	
	
	return car2pol(random_r, random_alpha, random_beta)

func car2pol(r, alpha, beta) -> Vector3:
	var new_x = r*sin(alpha)*cos(beta)
	var new_y = r*sin(alpha)*sin(beta)
	var new_z = r*cos(alpha)
	
	return(Vector3(new_x,new_y,new_z))

func reset_area():
	for item in enemies:
		var area_body:Area3D = item.get_node("%area_overlap")
		area_body.disconnect("body_entered",reposition)
		area_body.disconnect("area_entered",reposition)
		
		var enm_bod:Area3D = item.get_node("%enm_bod")
		enm_bod.connect("body_entered", enm_collision)

	for item in biscuits:
		var area_body:Area3D = item.get_node("%area_overlap")
		area_body.disconnect("body_entered",reposition)
		area_body.disconnect("area_entered",reposition)
		area_body.connect("body_entered",itm_picked.bind(item))
		
	for item in obstacles:
		var area_body:Area3D = item.get_node("%area_overlap")
		area_body.disconnect("body_entered",reposition)
		area_body.disconnect("area_entered",reposition)
