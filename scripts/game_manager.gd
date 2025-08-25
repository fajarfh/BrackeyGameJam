extends Node3D

@export var finish_line: Area3D

@export var main_panel: Control
@export var guide_panel: Control
@export var credits_panel: Control
@export var map_panel: Control
@export var win_panel: Control


func _ready():
	get_tree().paused = true
	AudioControl.playBgm("main")
	#if get_tree().paused:
		#get_tree().paused = true

func _physics_process(delta):
	if Input.is_action_just_pressed("open_map"):
		map_panel.show()
		get_tree().paused = true
		
	if Input.is_action_just_released("open_map"):
		map_panel.hide()
		get_tree().paused = false

func _on_restart_pressed():
	#await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
	
	

func _on_win_line_body_entered(body):
	if body is CharacterBody3D:
		win_panel.show()
		get_tree().paused = true


func _on_guide_pressed():
	main_panel.hide()
	guide_panel.show()


func _on_start_pressed():
	main_panel.hide()
	guide_panel.hide()
	get_tree().paused = false


func _on_credits_pressed():
	win_panel.hide()
	credits_panel.show()


func _on_soft_bound_body_entered(body):
	print("siapa? " + body.name)
	
