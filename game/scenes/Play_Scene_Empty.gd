extends Node2D

@onready var ui:UI = $UI
@onready var cam = $Camera

@onready var Judge:Rating = Rating.new()

var default_zoom:float = 0.8
var SONG
var cur_speed:float = 1:
	set(new_speed):
		cur_speed = new_speed
		for note in notes: note.speed = cur_speed

var chart_notes
var notes:Array[Note] = []
var events:Array[EventNote] = []
var start_time:float = 0 # when the first note is actually loaded
var spawn_time:int = 2000

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
	Conductor.bpm = SONG.bpm
	
	ui.icon_p1.change_icon('bf', true)
	ui.icon_p2.change_icon('dad')
	
	ui.icon_p1.default_scale = 0.8
	ui.icon_p1.offset.y = 15
	ui.icon_p2.default_scale = 0.8
	ui.icon_p2.offset.y = 15
	
	if Prefs.rating_cam == 'game':
		Judge.rating_pos = cam.position + Vector2(-15, -15)
		Judge.combo_pos = cam.position + Vector2(-150, 60)
	elif Prefs.rating_cam == 'hud':
		Judge.rating_pos = Vector2(580, 300)
		Judge.combo_pos = Vector2(450, 400)
		
	print(SONG.song)
	
	Discord.change_presence('Playing '+ SONG.song.capitalize())
	
	if JsonHandler.chart_notes.size() > 0:
		chart_notes = JsonHandler.chart_notes.duplicate()
	else:
		chart_notes = JsonHandler.generate_chart(SONG)
		
	start_time = chart_notes[0][0]
	
	ui.start_countdown(true)
	section_hit(0) #just for 1st section stuff

var section_data
var chunk:int = 0
func _process(delta):
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
						if note.can_hit:
							#var check = (auto_play or Input.is_action_pressed(key_names[note.dir]))
							note.holding = (auto_play or Input.is_action_pressed(key_names[note.dir]))
							good_sustain_press(note, delta)
					else:
						if note.can_hit and !note.was_good_hit:
							opponent_sustain_press(note)
					
					if note.temp_len <= 0: kill_note(note)
				else:
					if note.must_press:
						if auto_play and note.strum_time <= Conductor.song_pos:
							good_note_hit(note)
						if !auto_play and note.strum_time < Conductor.song_pos - (300 / note.speed) and !note.was_good_hit:
							note_miss(note)
					else:
						if note.was_good_hit:
							opponent_note_hit(note)

func beat_hit(beat):
	ui.icon_p1.bump(0.82)
	ui.icon_p2.bump(0.82)

func section_hit(section):
	ui.zoom += 0.04
	cam.zoom += Vector2(0.08, 0.08)

	if SONG.notes.size() > section:
		section_data = SONG.notes[section]

		if section_data.has('changeBPM') and section_data.has('bpm'):
			if section_data.changeBPM and Conductor.bpm != section_data.bpm:
				Conductor.bpm = section_data.bpm
				print('Changed BPM: ' + str(section_data.bpm))

func _unhandled_key_input(_event):
	if auto_play: return
	for i in 4:
		if Input.is_action_just_pressed(key_names[i]): key_press(i)
		if Input.is_action_just_released(key_names[i]): key_release(i)

func key_press(key:int = 0):
	var hittable_notes:Array[Note] = notes.filter(func(i:Note):
		return i.spawned and !i.is_sustain and i.must_press and i.can_hit and i.dir == key and !i.was_good_hit
	)
	hittable_notes.sort_custom(func(a, b): return a.strum_time < b.strum_time)
	
	if hittable_notes.size() != 0:
		var note:Note = hittable_notes[0]
			
		#if hittable_notes.size() > 1: # mmm idk anymore
		#	for funny in hittable_notes: # temp dupe note thing killer bwargh i hate it
		#		if note == funny: continue 
		#		if absf(funny.strum_time - note.strum_time) < 1.0:
		#			kill_note(funny)
					
		good_note_hit(note)

	var strum = ui.player_strums[key]
	if !strum.animation.contains('confirm') and !strum.animation.contains('press'):
		strum.play_anim('press')
		strum.reset_timer = 0

func key_release(key:int = 0):
	ui.player_strums[key].play_anim('static')

func song_end():
	Conductor.reset()
	Game.switch_scene("menus/freeplay")

func good_note_hit(note:Note):
	if Conductor.vocals.stream != null: 
		Conductor.vocals.volume_db = linear_to_db(1) 
	ui.player_group.note_hit(note)
	combo += 1
	
	var hit_rating = Judge.get_rating(Conductor.song_pos - note.strum_time)
	if Prefs.rating_cam != 'none':
		var cam:Callable = ui.add_behind if Prefs.rating_cam == 'hud' else add_child
		var new_rating = Judge.make_rating(hit_rating)
		cam.call(new_rating)
	
		var r_tween = create_tween()
		r_tween.tween_property(new_rating, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.001)
		r_tween.finished.connect(new_rating.queue_free)
	
		var new_nums = Judge.make_combo(combo)
		for num in new_nums:
			cam.call(num)
			var n_tween = create_tween()
			n_tween.tween_property(num, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.002)
			n_tween.finished.connect(num.queue_free)
	
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
	
func good_sustain_press(sustain:Note, delt:float = 0.0):
	if !auto_play and Input.is_action_just_released(key_names[sustain.dir]) and !sustain.was_good_hit:
		#sustain.dropped = true
		sustain.holding = false
		print('let go too soon ', sustain.length)
		note_miss(sustain)
		return
	
	if sustain.holding:
		if Conductor.vocals.stream != null: 
			Conductor.vocals.volume_db = linear_to_db(1) 
		ui.player_group.note_hit(sustain)

		score += floor(500 * delt)
		ui.hp += (4 * delt)
		ui.update_score_txt()
	
	
func opponent_note_hit(note:Note):
	if Conductor.vocals.stream != null:
		var v = Conductor.vocals_opp if Conductor.mult_vocals else Conductor.vocals
		v.volume_db = linear_to_db(1)
	ui.opponent_group.note_hit(note)
	kill_note(note)

func opponent_sustain_press(sustain:Note):
	if Conductor.vocals.stream != null:
		var v = Conductor.vocals_opp if Conductor.mult_vocals else Conductor.vocals
		v.volume_db = linear_to_db(1)
	ui.opponent_group.note_hit(sustain)

func note_miss(note:Note):
	ui.player_group.note_miss(note)
	score -= 10 if !note.is_sustain else floor(note.length * 5)
	misses += 1
	ui.total_hit += 1
	ui.hp -= 4.7
	
	if combo > 5:
		var miss = Judge.make_combo('000')
		for num in miss:
			add_child(num)
			num.modulate = Color.DARK_RED
			var n_tween = create_tween()
			n_tween.tween_property(num, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.002)
			n_tween.finished.connect(num.queue_free)
		
	combo = 0
	
	if Conductor.vocals != null:
		Conductor.vocals.volume_db = linear_to_db(0)
	ui.update_score_txt()
	#if !note.sustain: 
	kill_note(note)
	
func kill_note(note:Note):
	note.spawned = false
	notes.remove_at(notes.find(note))
	note.queue_free()
