extends Node

@export var sfx : AudioStreamPlayer
@export var bgm : AudioStreamPlayer
@export var amb : AudioStreamPlayer

#daftar SFX

var pop0 = preload("res://assets/audio/SFX/4. Bubble Pop.mp3")
var pop1 = preload("res://assets/audio/SFX/Bubble Drip/1.ogg")
var pop2 = preload("res://assets/audio/SFX/Bubble Drip/2.ogg")
var pop3 = preload("res://assets/audio/SFX/Bubble Drip/3.ogg")
var pop4 = preload("res://assets/audio/SFX/Bubble Drip/4.ogg")

#daftar BGM
var bgm_main = preload("res://assets/audio/BGM/1. Blessings (Main Theme).ogg")
var bgm_intro = preload("res://assets/audio/BGM/2. Remedy .ogg")
var bgm_lv1 = preload("res://assets/audio/BGM/3. Stage 1  .ogg")
var bgm_lv2 = preload("res://assets/audio/BGM/4. Stage 2.ogg")
var bgm_lv3 = preload("res://assets/audio/BGM/5. Stage 3.ogg")
var bgm_lv4 = preload("res://assets/audio/BGM/6. Stage 4.ogg")
var bgm_end = preload("res://assets/audio/BGM/7. Blessings ft. ANRI.ogg")

#daftar Ambience
var amb_playground = preload("res://assets/audio/Ambience/1. Children Playing at a Playground.mp3")
var amb_therapy = preload("res://assets/audio/Ambience/2. Therapy Room.mp3")
var amb_bonfire = preload("res://assets/audio/Ambience/3. Bonfire.mp3")
 
func playOnce(aset):
	sfx.stream = aset
	sfx.play()

func playBgm(level):
	var aset
	match level:
		"main":
			aset = bgm_main
		"intro":
			aset = bgm_intro
		"level1":
			aset = bgm_lv1
		"level2":
			aset = bgm_lv2
		"level3":
			aset = bgm_lv3
		"level4":
			aset = bgm_lv4
		"level5":
			aset = bgm_lv1
		"end":
			aset = bgm_end
	
	if level != "":
		if (!bgm.playing) || (bgm.stream != aset):		
			bgm.stream = aset
			bgm.set("parameters/looping",true)
			bgm.play()

func playAmbience(level):
	var aset
	match level:
		"intro":
			aset = amb_therapy
		"level1":
			aset = amb_playground
		"level5":
			aset = amb_bonfire
	
	if level != "":
		if (!amb.playing) || (amb.stream != aset):		
			amb.stream = aset
			amb.set("parameters/looping",true)
			amb.play()
