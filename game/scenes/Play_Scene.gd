extends Node2D

@onready var ui:UI = $UI
@onready var cam = $Camera

@onready var Judge:Rating = Rating.new()

var default_zoom:float = 0.8
var SONG
var cur_style:String = 'default': # yes
	set(new_style): 
		ui.cur_style = new_style
		cur_style = ui.cur_style
var cur_speed:float = 1:
	set(new_speed):
		cur_speed = new_speed
		for note in notes: note.speed = cur_speed
var cur_stage:String = 'stage'
var stage:StageBase

var chart_notes
var notes:Array[Note] = []
var events:Array[EventNote] = []
var start_time:float = 0 # when the first note is actually loaded
var spawn_time:int = 2000

var boyfriend:Character
var dad:Character
var gf:Character
var characters:Array = []

var cached_chars:Dictionary = {'bf' = [], 'gf' = [], 'dad' = []}

var player_strums:Array[Strum] = []
var opponent_strums:Array[Strum] = []

var key_names = ['note_left', 'note_down', 'note_up', 'note_right']

@onready var auto_play:bool:
	set(auto):
		auto_play = auto
		ui.player_group.is_cpu = auto_play

var score:int = 0
var combo:int = 0
var misses:int = 0

func _ready():
	auto_play = Prefs.auto_play # there is a reason
	SONG = JsonHandler._SONG
	if Prefs.daniel: SONG.player1 = 'bf-girl'
	
	Conductor.load_song(SONG.song)
	cur_speed = SONG.speed
	if SONG.has('stage'):
		cur_stage = SONG.stage.to_lower().replace(' ', '-')
	else:
		var song = SONG.song.to_lower().replace(' ', '-')
		match song: # daily reminder to kiss daniel
			'spookeez', 'south', 'monster': cur_stage = 'spooky'
			'pico', 'philly-nice', 'blammed': cur_stage = 'philly'
			'satin-panties', 'high', 'milf': cur_stage = 'limo'
			'cocoa', 'eggnog': cur_stage = 'mall'
			'winter-horrorland': cur_stage = 'mall-evil'
			'senpai', 'roses': cur_stage = 'school'
			'thorns': cur_stage = 'school-evil'
			'ugh', 'guns', 'stress': cur_stage = 'tank'
			
	Conductor.bpm = SONG.bpm
	
	var to_load = 'stage'
	if FileAccess.file_exists('res://game/scenes/stages/'+ cur_stage +'.tscn'):
		to_load = cur_stage
		
	stage = load('res://game/scenes/stages/%s.tscn' % [to_load]).instantiate() # im sick of grey bg FUCK
	add_child(stage)
	default_zoom = stage.default_zoom
	#ui.cur_style = 'pixel'
	
	var gf_ver = 'gf'
	if SONG.has('gfVersion'): 
		gf_ver = SONG.gfVersion
	elif SONG.has('player3'): 
		gf_ver = SONG.player3 if SONG.player3 != null else 'gf'
	else: # base game type shit baybeee
		match SONG.song.to_lower().replace(' ', '-'):
			'satin-panties', 'high', 'milf': gf_ver = 'gf-car'
			'cocoa', 'eggnog', 'winter-horrorland': gf_ver = 'gf-christmas'
			'senpai', 'roses', 'thorns': gf_ver = 'gf-pixel'
			'ugh', 'guns': gf_ver = 'gf-tankmen'
			'stress': gf_ver = 'pico-speaker'
	
	if SONG.has('players'): 
		SONG.player1 = SONG.players[0]
		SONG.player2 = SONG.players[1]
		SONG.gfVersion = SONG.players[2]
		
	gf = Character.new(stage.gf_pos, gf_ver if gf_ver != null else 'gf')
	add_child(gf)
	
	dad = Character.new(stage.dad_pos, SONG.player2)
	add_child(dad)
	if dad.cur_char == gf.cur_char and dad.cur_char.contains('gf'): #and SONG.song == 'Tutorial':
		dad.position = gf.position
		dad.focus_offsets.x -= dad.width / 4
		gf.visible = false
	
	boyfriend = Character.new(stage.bf_pos, SONG.player1, true)
	add_child(boyfriend)
	
	ui.icon_p1.change_icon(boyfriend.icon, true)
	ui.icon_p2.change_icon(dad.icon)
	
	ui.characters = [boyfriend, dad, gf]
	ui.player_group.singer = boyfriend
	ui.opponent_group.singer = dad
	
	if cur_stage.contains('school'):
		ui.cur_style = 'pixel'
	if cur_stage == 'limo': # lil dumb...
		remove_child(gf)
		stage.add_child(gf)
		stage.move_child(gf, 2)
		
	if Prefs.rating_cam == 'game':
		Judge.rating_pos = boyfriend.position + Vector2(-15, -15)
		Judge.combo_pos = boyfriend.position + Vector2(-150, 60)
	elif Prefs.rating_cam == 'hud':
		Judge.rating_pos = Vector2(580, 300)
		Judge.combo_pos = Vector2(450, 400)
		
	print(SONG.song)
	
	Discord.change_presence('Playing '+ SONG.song.capitalize())
	
	#SONG.speed = 10
	#var thread = Thread.new()
	#thread.start(JsonHandler.generate_chart.bind(SONG)) 
	# since im doing something different, this thread will need to be changed
	if !JsonHandler.chart_notes.is_empty():
		chart_notes = JsonHandler.chart_notes.duplicate()
		print('already loaded')
	else:
		chart_notes = JsonHandler.generate_chart(SONG)
		print('made chart')
		
	start_time = chart_notes[0][0]
	events = JsonHandler.song_events.duplicate()
	print(events.size())
	
	#await thread.wait_to_finish()
	ui.start_countdown(true)

	section_hit(0) #just for 1st section stuff

var section_data
var chunk:int = 0
func _process(delta):
	if Input.is_key_pressed(KEY_R): ui.hp = 0
	if ui.hp <= 0:
		print('die')
		try_death()
		
	if Input.is_action_just_pressed("debug_1"):
		Game.switch_scene('debug/Charting_Scene')
	if Input.is_action_just_pressed("back"):
		auto_play = !auto_play
	if Input.is_action_just_pressed("accept"):
		get_tree().paused = true
		var pause = load('res://game/scenes/pause_screen.tscn').instantiate()
		ui.add_child(pause)
	
	ui.zoom = lerpf(ui.zoom, 1, delta * 4)
	cam.zoom.x = lerpf(cam.zoom.x, default_zoom, delta * 4)
	cam.zoom.y = cam.zoom.x
	
	if chart_notes != null:
		while chart_notes.size() > 0 and chunk != chart_notes.size() and chart_notes[chunk][0] - Conductor.song_pos < spawn_time / cur_speed:
			if chart_notes[chunk][0] - Conductor.song_pos > spawn_time / cur_speed:
				break
			
			var note_info = NoteData.new(chart_notes[chunk])
			var new_note:Note = Note.new(note_info)
			new_note.speed = cur_speed
			notes.append(new_note)

			if chart_notes[chunk][2]: # if it has a sustain
				var new_sustain:Note = Note.new(new_note, true)
				new_sustain.speed = new_note.speed
		
				notes.append(new_sustain)
				ui.add_to_strum_group(new_sustain, new_sustain.must_press)

			ui.add_to_strum_group(new_note, new_note.must_press)
			notes.sort_custom(func(a, b): return a.strum_time < b.strum_time)
			chunk += 1

	if notes.size() != 0:
		for note in notes:
			if note.spawned:
				note.follow_song_pos(ui.player_strums[note.dir] if note.must_press else ui.opponent_strums[note.dir])
				if note.is_sustain:
					if note.must_press:
						if note.can_hit and note.should_hit:
							#var check = (auto_play or Input.is_action_pressed(key_names[note.dir]))
							note.holding = (auto_play or Input.is_action_pressed(key_names[note.dir]))
							good_sustain_press(note, delta)
					else:
						if note.can_hit and !note.was_good_hit:
							opponent_sustain_press(note)
					
					if note.temp_len <= 0: kill_note(note)
				else:
					if note.must_press:
						if auto_play and note.strum_time <= Conductor.song_pos and note.should_hit:
							good_note_hit(note)
						if !auto_play and note.strum_time < Conductor.song_pos - (300 / note.speed) and !note.was_good_hit:
							note_miss(note)
					else:
						if note.was_good_hit:
							opponent_note_hit(note)
	if events.size() != 0:
		for event in events:
			if event.strum_time <= Conductor.song_pos:
				event_hit(event)
				events.remove_at(0)

func beat_hit(beat):
	for i in ui.characters:
		if !i.animation.contains('sing') and beat % i.dance_beat == 0:
			i.dance()
		
	ui.icon_p1.bump()
	ui.icon_p2.bump()
	if stage.has_method('beat_hit'):
		stage.call('beat_hit')

func step_hit(_step): pass

func section_hit(section):
	ui.zoom += 0.04
	cam.zoom += Vector2(0.08, 0.08)

	if SONG.notes.size() > section:
		section_data = SONG.notes[section]

		move_cam(section_data.mustHitSection)
		if section_data.has('changeBPM') and section_data.has('bpm'):
			if section_data.changeBPM and Conductor.bpm != section_data.bpm:
				Conductor.bpm = section_data.bpm
				print('Changed BPM: ' + str(section_data.bpm))

func move_cam(to_player:bool = true):
	var char = boyfriend if to_player else dad
	var cam_off:Vector2 = stage.bf_cam_offset if to_player else stage.dad_cam_offset
	var new_pos:Vector2 = char.get_cam_pos()
	cam.position = new_pos + cam_off

func _unhandled_key_input(_event):
	if auto_play: return
	for i in 4:
		if Input.is_action_just_pressed(key_names[i]): key_press(i)
		if Input.is_action_just_released(key_names[i]): key_release(i)

func key_press(key:int = 0):
	var hittable_notes:Array[Note] = notes.filter(func(i:Note):
		return i.dir == key and i.spawned and !i.is_sustain and i.must_press and i.can_hit and !i.was_good_hit
	)
	hittable_notes.sort_custom(func(a, b): return a.strum_time < b.strum_time)
	
	if hittable_notes.size() != 0:
		var note:Note = hittable_notes[0]
			
		if hittable_notes.size() > 1: # mmm idk anymore
			for funny in hittable_notes: # temp dupe note thing killer bwargh i hate it
				if note == funny: continue 
				if absf(funny.strum_time - note.strum_time) < 1.0:
					kill_note(funny)
					
		good_note_hit(note)

	var strum = ui.player_strums[key]
	if !strum.animation.contains('confirm') and !strum.animation.contains('press'):
		strum.play_anim('press')
		strum.reset_timer = 0

func key_release(key:int = 0):
	ui.player_strums[key].play_anim('static')

func try_death():
	for item in ['combo', 'score', 'misses']: set(item, 0)
	ui.total_hit = 0
	ui.note_percent = 0
	ui.accuracy = -1
	
	ui.update_score_txt()
	boyfriend.process_mode = Node.PROCESS_MODE_ALWAYS
	gf.play_anim('sad')
	get_tree().paused = true
	var death_screen = load('res://game/scenes/game_over.tscn').instantiate()
	add_child(death_screen)

func song_end():
	refresh(false)
	#Conductor.reset()
	#Game.switch_scene("menus/freeplay")
	
func refresh(restart:bool = true): # start song from beginning with no restarts
	Conductor.reset_beats()
	Conductor.bpm = SONG.bpm # reset bpm to init whoops

	while notes.size() != 0:
		kill_note(notes[0])
	notes.clear()
	events.clear()
	chart_notes = JsonHandler.chart_notes.duplicate()
	events = JsonHandler.song_events.duplicate()
	chunk = 0
	if restart:
		Conductor.song_pos = (-Conductor.crochet * 4)
		ui.start_countdown(true)
		ui.hp = 50
	else:
		Conductor.start(0)
	section_hit(0)

func event_hit(event:EventNote):
	print(event.event, event.values)
	match event.event:
		'Hey!':
			boyfriend.play_anim('hey', true)
			boyfriend.anim_timer = 0.6
			gf.play_anim('cheer', true)
			gf.anim_timer = 0.6
		'Change Scroll Speed': 
			var new_speed = SONG.speed * float(event.values[0])
			var len := float(event.values[1])
			if len > 0:
				create_tween().tween_property(Game.scene, 'cur_speed', new_speed, len)
			else:
				cur_speed = new_speed
		'Add Camera Zoom': true
		'Change Character': 
			var char = "boyfriend"
			var new_char:Character
			match event.values[0].to_lower():
				'2', 'gf', 'girlfriend': char = "gf"
				'1', 'dad', 'opponent': char = "dad"
				
			#new_char = Character.new(char.position, event.values[1], char == boyfriend)
			#remove_child(char)
			#char.queue_free()
			
			#char = new_char
		_: false

func good_note_hit(note:Note):
	if note.type.length() > 0: print(note.type, ' bf')

	if Conductor.vocals.stream != null: 
		Conductor.vocals.volume_db = linear_to_db(1)
		
	ui.player_group.singer = gf if note.type.to_lower().contains('gf') else boyfriend 
	ui.player_group.note_hit(note)
	combo += 1
	
	var time = Conductor.song_pos - note.strum_time if !auto_play else 0
	var hit_rating = Judge.get_rating(time)
	pop_up_combo(hit_rating, combo)
	
	score += Judge.get_score(hit_rating)[0]
	ui.note_percent += Judge.get_score(hit_rating)[1]
	ui.total_hit += 1
	ui.hit_count[hit_rating] += 1
	ui.hp += 2.3
	
	if Prefs.note_splashes != 'none':
		if Prefs.note_splashes == 'all' or (Prefs.note_splashes == 'sicks' and hit_rating == 'sick'):
			ui.spawn_splash(ui.player_strums[note.dir])
			
	ui.update_score_txt()
	kill_note(note)
	if Prefs.hitsounds:
		Audio.play_sound('hitsound', 0.7)
	#	ui

var time_dropped:float = 0
func good_sustain_press(sustain:Note, delt:float = 0.0):
	if !auto_play and Input.is_action_just_released(key_names[sustain.dir]) and !sustain.was_good_hit:
		#sustain.dropped = true
		sustain.holding = false
		print('let go too soon ', sustain.length)
		time_dropped += delt
		note_miss(sustain)
		return
	
	if sustain.holding:
		if Conductor.vocals.stream != null: 
			Conductor.vocals.volume_db = linear_to_db(1) 
		ui.player_group.singer = gf if sustain.type.to_lower().contains('gf') else boyfriend
		ui.player_group.note_hit(sustain)

		score += floor(500 * delt)
		ui.hp += (4 * delt)
		ui.update_score_txt()

func opponent_note_hit(note:Note):
	if note.type.length() > 0: print(note.type, ' dad')
	if section_data.has('altAnim') and section_data.altAnim:
		note.alt = '-alt'
		
	if Conductor.vocals.stream != null:
		var v = Conductor.vocals_opp if Conductor.mult_vocals else Conductor.vocals
		v.volume_db = linear_to_db(1)
	ui.opponent_group.singer = gf if note.type.to_lower().contains('gf') else dad
	ui.opponent_group.note_hit(note)
	kill_note(note)

func opponent_sustain_press(sustain:Note):
	if Conductor.vocals.stream != null:
		var v = Conductor.vocals_opp if Conductor.mult_vocals else Conductor.vocals
		v.volume_db = linear_to_db(1)
		
	if section_data.has('altAnim') and section_data.altAnim:
		sustain.alt = '-alt'
	ui.opponent_group.singer = gf if sustain.type.to_lower().contains('gf') else dad
	ui.opponent_group.note_hit(sustain)

func note_miss(note:Note):
	if note.should_hit:
		ui.player_group.note_miss(note)
		score -= 10 if !note.is_sustain else floor(note.length * 5)
		misses += 1
		ui.total_hit += 1
		ui.hp -= 4.7
	
		if combo >= 5: pop_up_combo('', '000', true)
		
		combo = 0
	
		if Conductor.vocals != null:
			Conductor.vocals.volume_db = linear_to_db(0)
		ui.update_score_txt()
	#if !note.sustain: 
	kill_note(note)
	
	
func pop_up_combo(rating:String = 'sick', combo = -1, is_miss:bool = false):
	if Prefs.rating_cam != 'none':
		var cam:Callable = ui.add_behind if Prefs.rating_cam == 'hud' else add_child
	
		if rating.length() != 0:
			var new_rating = Judge.make_rating(rating)
			cam.call(new_rating)
	
			var r_tween = create_tween()
			r_tween.tween_property(new_rating, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.001)
			r_tween.finished.connect(new_rating.queue_free)
		
		if (combo is int and combo > -1) or (combo is String and combo.length() > 0):
			for num in Judge.make_combo(combo):
				cam.call(num)
				var n_tween = create_tween()
				if is_miss: num.modulate = Color.DARK_RED
				n_tween.tween_property(num, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.002)
				n_tween.finished.connect(num.queue_free)
	
func kill_note(note:Note):
	note.spawned = false
	notes.remove_at(notes.find(note))
	note.queue_free()
