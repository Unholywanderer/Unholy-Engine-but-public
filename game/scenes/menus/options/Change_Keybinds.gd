extends Node2D

var sec_title:Alphabet
var notif
var is_changing:bool = false
var selected_bind:String
var alt:int = 0 # for getting the first or second bind of a key
var key_names:Array = ['left', 'down', 'up', 'right']

var cur_menu:String = ''
var cur_bind:int = 0
var key_binds:Array = []
var strums:Array[Strum]
const DEFAULT_KEYS = [['A', 'S', 'W', 'D'], ['Left', 'Down', 'Up', 'Right']]
func _ready():
	sec_title = Alphabet.new()
	sec_title.position = Vector2(450, 110)
	add_child(sec_title)
	
	notif = Alphabet.new('Press a key for: ')
	notif.scale = Vector2(0.7, 0.7)
	notif.position = Vector2(200, 200)
	swap_menu('note')
	$SelectBox.scale = Vector2(3, 1.2)
	update_selection()
	
	for i in 4:
		var temp_strum = Strum.new()
		temp_strum.load_skin('default')
		temp_strum.position = Vector2(470 + (200 * i), 550)
		temp_strum.dir = i
		add_child(temp_strum)
		strums.append(temp_strum)

func _process(delta):
	if !is_changing:
		if Input.is_action_just_pressed('menu_left'): update_selection(-1)
		if Input.is_action_just_pressed('menu_down'): update_selection(4)
		if Input.is_action_just_pressed('menu_up'): update_selection(-4)
		if Input.is_action_just_pressed('menu_right'): update_selection(1)
	
		if Input.is_action_just_pressed("accept"):
			if key_binds[cur_bind] != null:
				alt = 0 if cur_bind < floor(key_binds.size() / 2) else 1
				start_change(cur_menu +'_'+ key_names[cur_bind % 4])
		if Input.is_action_just_pressed("back"):
			if is_changing: 
				is_changing = false
				selected_bind = ''
			else:
				Prefs.set_keybinds()
				Game.switch_scene('menus/options_menu')

func _unhandled_key_input(event):
	if !is_changing or selected_bind.length() < 1 or event.pressed: return
	var old_key = key_binds[cur_bind].text
	var key_name = OS.get_keycode_string(event.keycode)
	var to_replace = InputMap.action_get_events(selected_bind)[alt]
	
	if to_replace != null:
		InputMap.action_erase_event(selected_bind, to_replace)
	
	var new_key = InputEventKey.new()
	new_key.set_keycode(event.keycode)
	InputMap.action_add_event(selected_bind, new_key)
	
	print('changed '+ selected_bind +'['+ str(alt) +'] to '+ key_name)
	
	Prefs.note_keys[alt][Prefs.note_keys[alt].find(old_key)] = key_name
	Prefs.save_prefs()
	
	swap_menu('note') #update the text
	await get_tree().create_timer(0.2).timeout
	selected_bind = ''
	is_changing = false
	remove_child(notif)
	
func update_selection(amount:int = 0):
	cur_bind = wrapi(cur_bind + amount, 0, key_binds.size())
	$SelectBox.position = key_binds[cur_bind].position - Vector2(10, 55)
	
func start_change(bind:String):
	notif.text = 'Press a key for: '+ bind.replace('_', ' ')
	add_child(notif)
	await get_tree().create_timer(0.15).timeout #wait a sec so it doesnt auto set it to enter or something
	selected_bind = bind
	is_changing = true
	
	
func swap_menu(to_keys:String = 'note'):
	var colum:int = 0
	var rows:int = 0
	var _binds
	cur_menu = to_keys
	sec_title.text = to_keys.capitalize() + ' Keys'
	sec_title.position.x = Game.screen[0] / 2 - (sec_title.width / 2)
	
	while key_binds.size() != 0:
		remove_child(key_binds[0])
		key_binds[0].queue_free()
		key_binds.remove_at(0)
		
	if to_keys.to_lower() == 'vol' : _binds = Prefs.ui_keys[0]
	if to_keys.to_lower() == 'menu': _binds = Prefs.ui_keys[1]
	if to_keys.to_lower() == 'note': _binds = Prefs.note_keys
			
	for strum in strums: 
		strum.visible = to_keys == 'note'
	for _set in _binds:
		for key in _set:
			if key.length() < 1: key = 'None'
			var new_key = Alphabet.new(key, false)
			new_key.modulate = Color.BLACK
			new_key.position = Vector2(400 + (200 * colum), 300 + (100 * rows))
			key_binds.append(new_key)
			add_child(new_key)
			colum += 1
		colum = 0; rows += 1;

	var set1 = Alphabet.new('Set 1')
	set1.position = key_binds[0].position - Vector2(300, 50)
	add_child(set1)
		
	var set2 = Alphabet.new('Set 2')
	set2.position = key_binds[4].position - Vector2(300, 50)
	add_child(set2)
