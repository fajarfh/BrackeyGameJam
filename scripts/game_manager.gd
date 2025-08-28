extends Node3D

@export var main_panel: Control
@export var guide_panel: Control
@export var credits_panel: Control
@export var map_panel: Control
@export var win_panel: Control
@export var gameover_panel: Control
@export var hud_main: Control
@export var hud_oob: Control
@export var hud_biscuit: Control

@export var spawner:Node
@export var player:CharacterBody3D

var biscuit_score = 0:
	set(score):
		biscuit_score = score
		hud_biscuit.text = str(biscuit_score) + "/" + str(spawner.biscuit_spawn_number)


func _ready():
	get_tree().paused = true
	AudioControl.playBgm("main")
	#if get_tree().paused:
		#get_tree().paused = true
		
	player.connect("dying_char", game_over)
	spawner.connect("biscuit_picked", add_biscuit)
	hud_main.hide()
	biscuit_score = 0

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
	hud_main.show()
	spawner.reset_area()
	get_tree().paused = false


func _on_credits_pressed():
	win_panel.hide()
	gameover_panel.hide()
	credits_panel.show()


func _on_soft_bound_body_entered(body):
	#print("siapa? " + body.name)
	#hud_oob.show()
	pass


func _on_soft_bound_body_exited(body):
	print("siapa? " + body.name)
	if hud_oob.visible:
		hud_oob.hide()
	else:	
		hud_oob.show() #hud_oob.hide() # Replace with function body.
		
func game_over():
	#print("yup game over")
	hud_main.hide()
	await get_tree().create_timer(2.0).timeout
	get_tree().paused = true
	gameover_panel.show()

func add_biscuit():
	biscuit_score+=1
	if biscuit_score >= spawner.biscuit_spawn_number:
		winning()

func winning():
	
	await get_tree().create_timer(1.0).timeout
	hud_main.hide()
	win_panel.show()
	get_tree().paused = true
