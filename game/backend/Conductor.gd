extends Node2D

signal beat_hit(beat:int)
signal step_hit(step:int)
signal section_hit(section:int)
signal song_end

var bpm:float = 100.0:
	set(new_bpm):
		bpm = new_bpm
		crochet = ((60.0 / bpm) * 1000.0)
		step_crochet = crochet / 4.0

var crochet:float = ((60.0 / bpm) * 1000.0)
var step_crochet:float = crochet / 4.0
var song_pos:float = 0.0:
	set(new_pos): 
		song_pos = new_pos
		if song_pos < 0: 
			song_started = false
			for_all_audio('stop')

#var offset:float = 0
var safe_zone:float = 166.0
var song_length:float = 0.0

var beat_time:float = 0
var step_time:float = 0
#var sec_time:float = 0

var cur_beat:int = 0
var cur_step:int = 0
var cur_section:int = 0

var last_beat:int = -1
var last_step:int = -1
var last_section:int = -1

var song_loaded:bool = false # song audio files have been added
var song_started:bool = false # song has begun to/is playing
var paused:bool = false:
	set(pause): 
		paused = pause
		pause()
var mult_vocals:bool = false

var inst = AudioStreamPlayer.new()
var vocals = AudioStreamPlayer.new()
var vocals_opp = AudioStreamPlayer.new()

func _ready():
	add_child(inst)
	add_child(vocals)
	add_child(vocals_opp)

func load_song(song:String = ''):
	if song.length() < 1:
		printerr('Conductor.load_song: NO SONG ENTERED')
		song = 'tutorial' #DirAccess.get_directories_at('res://assets/songs')[0]
	
	song = song.to_lower().replace(' ', '-')
	var split = song.split('-')
	var path:String = 'res://assets/songs/'+ song +'/audio/%s.ogg' # myehh

	var suffix:String = ''
	if split[split.size()-1] == JsonHandler.get_diff:
		suffix = '-'+ JsonHandler.get_diff

	#print(path % ['Inst'+ suffix])
	if FileAccess.file_exists(path % ['Inst'+ suffix]):
		inst.stream = load(path % ['Inst'+ suffix])
		song_length = inst.stream.get_length() * 1000.0
	if FileAccess.file_exists(path % ['Voices'+ suffix]):
		mult_vocals = false
		vocals.stream = load(path % ['Voices'+ suffix])
	elif FileAccess.file_exists(path % ['Voices-play'+ suffix]):
		mult_vocals = true
		vocals.stream = load(path % ['Voices-play'+ suffix])
		vocals_opp.stream = load(path % ['Voices-opp'+ suffix])
	
	song_loaded = true
	
func _process(delta):
	if paused: return
	if song_loaded:
		song_pos += (1000 * delta)
	
	if song_pos > 0:
		if !song_started: 
			start()
			return
		if inst.stream != null: 
			if song_pos > beat_time + crochet:
				beat_time += crochet
				cur_beat += 1
				beat_hit.emit(cur_beat)
				Game.call_func('beat_hit', [cur_beat])
				if cur_beat % 4 == 0:
					cur_section += 1
					section_hit.emit(cur_section)
					Game.call_func('section_hit', [cur_section])
			
			if song_pos > step_time + step_crochet:
				step_time += step_crochet
				cur_step += 1
				step_hit.emit(cur_step)
				Game.call_func('step_hit', [cur_step])
			
			if song_pos >= song_length and song_loaded:
				print('Song Finished')
				
				Game.call_func('song_end')
		
		for audio in [inst, vocals, vocals_opp]:
			if audio.stream != null and audio.playing:
				if absf(audio.get_playback_position() * 1000 - song_pos) > 20: 
					resync_audio()
				
func check_resync(sound:AudioStreamPlayer): # ill keep this here for now
	if absf(sound.get_playback_position() * 1000 - song_pos) > 20:
		sound.seek(song_pos / 1000)
		print('resynced')

func resync_audio():
	for_all_audio('seek', song_pos / 1000.0)
	print('resynced audios')

func stop():
	song_pos = 0
	for_all_audio('stop', true)

func pause():
	for_all_audio('stream_paused', paused, true)

func start(at_point:float = -1):
	song_started = true # lol
	if at_point != -1:
		song_pos = absf(at_point) / 1000.0
	for_all_audio('play', song_pos)

func for_all_audio(do:String, arg = null, is_var:bool = false):
	for audio in [inst, vocals, vocals_opp]:
		if audio.stream == null: continue
		if is_var: 
			audio.set(do, arg)
		else:
			if do == 'stop':
				audio.stop()
				if arg == true: audio.stream = null
				continue
			audio.call(do, arg)


func reset():
	reset_beats()
	stop()
	bpm = 100
	
	song_started = false
	song_loaded = false

func reset_beats():
	beat_time = 0; step_time = 0;
	cur_beat = 0; cur_step = 0; cur_section = 0;
	last_beat = -1; last_step = -1; last_section = -1;
	paused = false
