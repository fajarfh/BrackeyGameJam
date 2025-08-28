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

func _ready():
	for i in range(0,enemy_spawn_number):
		spawn_item(enemy_spawn_points[0],enemy, enemies, "enemy")

func spawn_item(parent:Node3D, item:Resource, container:Array, name_suffix:String):

	var item_new:Node3D = load(item.resource_path).instantiate()
	var area_body:Area3D = item_new.get_node("%static")
	parent.add_child(item_new)
	item_new.position = random_loc(parent)
	item_new.name = name_suffix + "_" + str(len(container))
	container.append(item_new)
	
	area_body.connect("body_entered",reposition.bind(item_new, parent))
	area_body.connect("area_entered",reposition.bind(item_new, parent))

func reposition(body, node, parent):
	node.position = random_loc(parent)
	
func random_loc(parent:Node3D) -> Vector3:
	var random_r = randf_range(0,enemy_spawn_points[0].radius)
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
		var area_body:Area3D = item.get_node("%static")
		area_body.disconnect("body_entered",reposition)
		area_body.disconnect("area_entered",reposition)
