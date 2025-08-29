extends Node3D

const speed = 100.0

@onready var mesh = $MeshInstance3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D


func _ready():
	pass
	
func _process(delta):
	position += transform.basis * Vector3(0,0, -speed) * delta
