extends Node2D

@export var option_list:Array[String] = ['Resume', 'Restart Song', 'Options', 'Exit To Menu']
var options = []
var cur_option:int = 0
func _ready():
	Conductor.paused = true
	Audio.play_music('skins/%s/breakfast' % Game.scene.cur_style)
	$BG.modulate.a = 0
	var twen = create_tween()
	twen.tween_property($BG, 'modulate:a', 0.6, 0.4).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	for i in option_list.size():
		var option = Alphabet.new(option_list[i])
		option.is_menu = true
		option.target_y = i
		options.append(option)
		add_child(option)
	#options = [$Option1, $Option2, $Option3]
	change_selection()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed('menu_up'):
		change_selection(-1)
	if Input.is_action_just_pressed('menu_down'):
		change_selection(1)
		
	if Input.is_action_just_pressed('accept'):
		match option_list[cur_option]:
			'Resume':
				close()
				Conductor.paused = false
				get_tree().paused = false
			'Restart Song':
				close()
				Conductor.reset()
				Game.reset_scene()
			'Exit To Menu':
				close()
				Conductor.reset()
				Game.switch_scene('menus/freeplay')
			_: 
				Audio.play_sound('cancelMenu')

func change_selection(amount:int = 0):
	Audio.play_sound('scrollMenu')
	cur_option = wrapi(cur_option + amount, 0, options.size())
	for i in options.size():
		options[i].target_y = i - cur_option
		options[i].modulate.a = (1.0 if i == cur_option else 0.6)

func close():
	Audio.stop_music()
	queue_free()
	get_tree().paused = false

