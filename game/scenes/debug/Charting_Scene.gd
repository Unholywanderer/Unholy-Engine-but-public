extends Node2D

var total_notes = []

var total_grids = []
var loaded_notes:Dictionary = {
	last = [], curr = [], next = []
}

var def_order = [ # fuck you!!
	'bf', 'bf-car', 'bf-christmas', 'bf-pixel', 'bf-holding-gf', 'bf-pixel-opponent', 
	'bf-dead', 'bf-pixel-dead', 'bf-holding-gf-dead',
	'gf', 'gf-car', 'gf-christmas', 'gf-pixel', 'gf-tankmen', 
	'dad', 'spooky', 'monster', 'pico', 'mom', 'mom-car', 
	'parents-christmas', 'monster-christmas', 
	'senpai', 'senpai-angry', 'spirit', 'tankman', 'pico-speaker'
]

var SONG
func _ready():
	Conductor.reset()
	if JsonHandler.chart_notes.is_empty(): 
		JsonHandler.parse_song('dad-battle', 'hard', true)
	SONG = JsonHandler._SONG
	Conductor.load_song(SONG.song)
	Conductor.bpm = SONG.bpm
	
	$Info/BPM.value = SONG.bpm
	$Info/Song.text = SONG.song
	$NoteGroup/PlayIcon.change_icon(SONG.player1, true)
	$NoteGroup/PlayIcon.default_scale = 0.7
	$NoteGroup/OppIcon.change_icon(SONG.player2)
	$NoteGroup/OppIcon.default_scale = 0.7
	
	for char in def_order: 
		$Info/Player1.add_item(char)
		$Info/Player2.add_item(char)
		$Info/GF.add_item(char)
		
	for char in DirAccess.get_files_at('res://assets/data/characters'):
		char = char.replace('.json', '')
		if def_order.has(char): continue
		$Info/Player1.add_item(char)
		$Info/Player2.add_item(char)
		$Info/GF.add_item(char)
		
	#$Info/Player1

	for i in 144: 
		var the = ColorRect.new()
		the.custom_minimum_size = Vector2(40, 40)
		the.modulate = Color.DIM_GRAY if i % 2 == 0 else Color.DARK_GRAY
		$NoteGrid.add_child(the)
		
	for note in JsonHandler.chart_notes:
		var new_note = Note.new(NoteData.new(note))
		new_note.scale = Vector2(0.7, 0.7)
		var group = $NoteGroup/Player if new_note.must_press else $NoteGroup/Opponent
		add_child(new_note)
		new_note.position = group.get_strums()[new_note.dir].position
		var value = new_note.strum_time / (4 * 4 * Conductor.step_crochet)
		new_note.position.y = 64 * 4 * 4 * 1 * value + 0  #(0.45 * new_note.strum_time) + 50
		total_notes.append(new_note)
		#new_note.visible = false
		
		if note[2]:
			var new_sustain:Note = Note.new(new_note, true)
			new_sustain.speed = new_note.speed
			group.add_child(new_sustain)
			total_notes.append(new_sustain)

var time_pressed:float = 0 
var just_pressed:bool = false
func _process(delta):
	# strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) / zoomList[curZoom] % (Conductor.stepCrochet * 16)) / 1);
	# FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height * leZoom)
	var lol = (Conductor.song_pos) / ((Conductor.step_crochet * 16)) / 1
	var olo = remap(lol, 0, 16 * Conductor.step_crochet, 0, Conductor.song_length * 15)
	$NoteGroup.position.y = (100 * lol) #olo #(0.45 * (Conductor.song_pos * Conductor.step_crochet))
	$Cam.position = $NoteGroup.position + Vector2(600, 350)
	$BG.position = $Cam.position
	
	if Input.is_action_just_pressed("back"):
		Conductor.reset_beats()
		Game.switch_scene('Play_Scene')
	
	if Input.is_action_just_pressed("accept"):
		Conductor.reset_beats()
		Game.switch_scene('Play_Scene')
		JsonHandler._SONG.bpm = $Info/BPM.value
		JsonHandler._SONG.player1 = $Info/Player1.text
		JsonHandler._SONG.player2 = $Info/Player2.text
		JsonHandler._SONG.gfVersion = $Info/GF.text
		
	if Input.is_physical_key_pressed(KEY_SPACE):
		time_pressed += delta
		if !just_pressed and time_pressed >= 0.01:
			just_pressed = true
			toggle_play()
	else:
		just_pressed = false
		time_pressed = 0
	
	if Input.is_action_just_pressed("menu_left"):
		$Cam.zoom -= Vector2(0.05, 0.05)
	if Input.is_action_just_pressed("menu_right"):
		$Cam.zoom += Vector2(0.05, 0.05)
	
	for note in total_notes:
		#note.position.y = -(0.45 * (Conductor.song_pos - note.strum_time)) + 50
		if note.strum_time <= Conductor.song_pos and note.modulate != Color.GRAY:
			note.modulate = Color.GRAY
			Audio.play_sound('hitsound', 0.3)
			if note.must_press:
				$NoteGroup/Player.get_strums()[note.dir].play_anim('confirm', true)
				$NoteGroup/Player.get_strums()[note.dir].reset_timer = 0.15
			else:
				$NoteGroup/Opponent.get_strums()[note.dir].play_anim('confirm', true)
				$NoteGroup/Opponent.get_strums()[note.dir].reset_timer = 0.15

func make_grid(pos:Vector2 = Vector2.ZERO):
	var new_grid = GridContainer.new()
	new_grid.columns = 9
	new_grid.position = pos
	for i in 36:
		var grid_square = ColorRect.new()
		grid_square.custom_minimum_size = Vector2(70, 70)
		grid_square.modulate = Color.DIM_GRAY if i % 2 == 0 else Color.DARK_GRAY
		new_grid.add_child(grid_square)
		print(grid_square.position)
	add_child(new_grid)
	move_child(new_grid, 1)
	total_grids.append(new_grid)

func beat_hit(beat:int):
	$NoteGroup/OppIcon.bump(0.8)
	$NoteGroup/PlayIcon.bump(0.8)
	#if beat % 4 == 0:
	#	make_grid(Vector2(70, 0.45 * Conductor.song_pos / 2))

func toggle_play():
	Conductor.paused = !Conductor.paused
	
func song_end():
	Conductor.reset_beats()
	Conductor.start(0)
	for note in total_notes: note.modulate = Color.WHITE

class chart_grid:
	var size
	
	func _init():
		var color
