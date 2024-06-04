extends Node2D


var col_tween
var colors:Array[Color] = [Color(51, 255, 255), Color(54, 54, 204)]
var alphas:Array = [1, 0.64]
var to:bool = false

var finished_intro:bool = false
var added_text:Array = []
var intro_text = FileAccess.open('res://assets/data/introText.txt', FileAccess.READ).get_as_text().split('\n')

var flash = ColorRect.new()
func _ready():
	flash.color = Color.BLACK
	flash.position = Vector2(-25, -15)
	flash.size = Vector2(1300, 755)
	add_child(flash)
	#col_tween.create_tween()
	#col_tween.tween_property(self, "modulate", colors[0], 0.2)
	#col_tween.tween_property(self, "modulate:a", 1, 0.2)
	
	Conductor.bpm = 102
	Conductor.song_started = true
	Conductor.inst = Audio.Player
	#Audio.volume = 0
	Audio.play_music('freakyMenu')
	#create_tween().tween_property(Audio, 'volume', 0.7, 4)
	
var danced:bool = false
func beat_hit(beat):
	if !finished_intro:
		match beat:
			1: pass
			2: make_funny(['hi', 'im you'], 60)
			3:
				remove_funny()
				make_funny(['you', 'you'], 60)
			4: add_funny('friday')
			5: add_funny('night')
			6: add_funny('funkin')
	$Funkin.scale = Vector2(1.1, 1.1)

	danced = !danced
	$TitleGF.play('dance'+ ('Left' if danced else 'Right'))

var accepted:bool = false
var funk_sin:float = 0
func _process(delta):
	funk_sin += delta
	$Funkin.rotation = sin(funk_sin * 2) / 8
	$Funkin.scale.x = lerpf($Funkin.scale.x, 1, delta * 7)
	$Funkin.scale.y = $Funkin.scale.x
	
	Conductor.song_pos = Audio.pos #im lazy dont judge me
	if Input.is_action_just_pressed("accept") and !accepted:
		accepted = true
		add_child(flash)
		
		var out = create_tween()
		out.tween_property(flash, 'modulate:a', 0, 1)
		Audio.play_sound('confirmMenu')
		
		await get_tree().create_timer(1).timeout
		Game.switch_scene('menus/main_menu')
		Conductor.reset()

func make_funny(text:Array, offset:int = 0):
	for i in text.size():
		var new_text = Alphabet.new(text[i])
		new_text.position.x = (Game.screen[0] / 2) - (new_text.width / 2)
		new_text.position.y += (i * 60) + 200 + offset
		add_child(new_text)
		added_text.append(new_text)
	
func add_funny(text:String, offset:int = 0):
	#if added_text.size() != 0:
	var new_text = Alphabet.new(text)
	new_text.position.x = (Game.screen[0] / 2) - (new_text.width / 2)
	new_text.position.y += (added_text.size() * 60) + 200 + offset
	add_child(new_text)
	added_text.append(new_text)
	
func remove_funny():
	while added_text.size() != 0:
		remove_child(added_text[0])
		added_text[0].queue_free()
		added_text.remove_at(0)

func on_music_finish():
	Conductor.soft_reset()
