extends Node2D;

signal notes_loaded
signal loaded

var base_diffs:Array[String] = ['easy', 'normal', 'hard']
var get_diff:String

var _SONG
var total_notes:int = 0
var chart_notes:Array = [] # keep loaded chart and events for restarting songs
var song_events:Array[EventNote] = []
func parse_song(song:String, diff:String, auto_create:bool = false, type:String = 'psych'):
	song = song.to_lower().strip_edges().replace(' ', '-')
	
	var parsed_song
	get_diff = diff
	match type:
		'base'    : parsed_song = base(song)
		'psych'   : parsed_song = psych(song)
		#'fps_plus': parsed_song = fps_plus(song)
		#'maru'    : parsed_song = maru(song)
		#'osu'     : parsed_song = osu(song)
		#'': parsed_song = psych(song)
	_SONG = parsed_song
	if auto_create:
		#var total_chunks = roundi(_SONG.notes.size() / 4)

		#var split_notes:Array = [[], [], [], []]

		#var last_got:int = 0
		#for i in range(1, 5):
		#	for num in range(total_chunks, total_chunks * i):
		#		pass
		#	last_got
				
		#for i in 3:
		#	var the = Thread.new()
			
		generate_chart(_SONG)
		#var thread = Thread.new()
		#thread.start(generate_chart.bind(_SONG))
		#await thread.wait_to_finish()

func _exit_tree():
	pass 
func base(song:String): 
	var json = you_WILL_get_a_json('chart') #FileAccess.open('res://assets/songs/'+ song +'/charts/chart.json', FileAccess.READ).get_as_text()
	return JSON.parse_string(json.get_as_text())
	
func psych(song:String):
	var json = you_WILL_get_a_json(song)
	var parsed = JSON.parse_string(json.get_as_text())
	return parsed.song # i dont want to have to do no SONG.song.bpm or something

#func fps_plus(song:String): pass
#func maru(song:String): pass
#func osu(song:String): pass

func you_WILL_get_a_json(song:String):
	var path:String = 'res://assets/songs/%s/charts/' % [song]
	var returned:String
	
	if song.contains('chart'):
		returned = 'chart.json'
	else:
		if !FileAccess.file_exists(path + get_diff +'.json'):
			printerr(song +' has no '+ get_diff +'.json')
			get_diff = 'hard'
			return you_WILL_get_a_json('tutorial')
		returned = path + get_diff +'.json'
	#var dir_files = DirAccess.get_files_at(path)

	#if dir_files.has(get_diff):
	#else:
	#	printerr('COULD NOT FIND JSON: "' + song + '/' + get_diff + '.json"')
		
	return FileAccess.open(returned, FileAccess.READ)

func generate_chart(data): # idea, split chart into parts, then load each seperately
	if data == null: 
		parse_song('tutorial', get_diff)
		return
	#var chart = Chart.new()
	#chart.load_chart(_SONG)
	# load events whenever chart is made
	song_events = get_events(data.song.to_lower().strip_edges().replace(' ', '-'))
	
	var _notes = []
	for sec in data.notes:
		for note in sec.sectionNotes:
			var time:float = maxf(0, note[0])
			if note[2] is String: continue
			var sustain_length:float = maxf(0, note[2])
			var is_sustain:bool = sustain_length > 0
			var n_data:int = int(note[1])
			var must_hit:bool = sec.mustHitSection if note[1] <= 3 else not sec.mustHitSection
			var type:String = str(note[3]) if note.size() > 3 else ''
			if type == 'true': type = 'alt'
			
			var to_add = [round(time), n_data, is_sustain, sustain_length, must_hit, type]
			if !_notes.has(to_add): # skip adding a note that exists
				_notes.append(to_add)
			_notes.sort_custom(func(a, b): return a[0] < b[0])
			
	chart_notes = _notes
	return _notes

func generate_chunks(amount):
	pass

func get_events(song:String = ''):
	var path_to_check = 'res://assets/songs/%s/events.json' % [song]
	var events_found:Array = []
	var events:Array[EventNote] = []
	if _SONG.has('events'): # check current song json for any events
		events_found.append_array(_SONG.events)
	
	if FileAccess.file_exists(path_to_check): # then check if there is a event json
		print(path_to_check)
		var json = JSON.parse_string(FileAccess.open(path_to_check, FileAccess.READ).get_as_text()).song
		if json.has('notes') and json.notes.size() > 0: # if events are a -1 note
			for sec in json.notes:
				for note in sec.sectionNotes:
					if note[1] == -1: 
						events_found.append([note[0], [[note[2], note[3], note[4]]]])
		else:
			events_found.append_array(json.events)
	
	for event in events_found:
		var time = event[0]
		for i in event[1]:
			var new_event = EventNote.new([time, i])
			events.append(new_event)
			#print([time, i])
	
	events.sort_custom(func(a, b): return a.strum_time < b.strum_time)
	return events

func get_character(character:String = 'bf'):
	var json_path = 'res://assets/data/characters/%s.json' % [character]
	if !FileAccess.file_exists(json_path):
		printerr('JSON: get_character | JSON FILE [%s.json] COULD NOT BE FOUND' % [character]);
		return 'Nothin'
	var file = FileAccess.open(json_path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func parse_week(week:String = 'week1'): # in week folder
	week = week.replace('.json', '')
	var week_json = FileAccess.open('res://assets/data/weeks/'+ week.strip_edges() +'.json', FileAccess.READ)
	var json = JSON.parse_string(week_json.get_as_text())
	return json
