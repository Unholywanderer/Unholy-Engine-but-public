class_name UI; extends CanvasLayer;

var SPLASH = preload('res://game/objects/note/note_splash.tscn')

# probably gonna move some note shit in here
@onready var cur_scene = get_tree().current_scene
@onready var score_txt:Label = $Score_Txt
@onready var health_bar:Control = $HealthBar
@onready var icon_p1:Sprite2D = $HealthBar/IconP1
@onready var icon_p2:Sprite2D = $HealthBar/IconP2

@onready var player_group:Strum_Line = $Strum_Group/Player
@onready var opponent_group:Strum_Line = $Strum_Group/Opponent
@onready var player_strums:Array = player_group.get_strums()
@onready var opponent_strums:Array = opponent_group.get_strums()
var strums:Array[Strum] = []
var chart_notes = []

var characters:Array[Character] = []

var STYLE = StyleInfo.new()
var cur_style:String = 'default':
	set(new_style): 
		if new_style != cur_style:
			cur_style = new_style
			change_style(new_style)
			
var countdown_spr:Array[String] = ['ready', 'set', 'go']
var sounds:Array[String] = ['intro3', 'intro2', 'intro1', 'introGo']

var total_hit:float = 0
var note_percent:float = 0
var accuracy:float = -1
var hit_count:Dictionary = {'sick': 0, 'good': 0, 'bad': 0, 'shit': 0}

var zoom:float = 1:
	set(new_zoom):
		zoom = new_zoom
		scale = Vector2(zoom, zoom)

func _ready():
	strums.append_array(opponent_strums)
	strums.append_array(player_strums)
	
	var downscroll = Prefs.downscroll
	var middscroll = Prefs.middlescroll
	#var spltscroll = Prefs.splitscroll
	
	# i am stupid they are a group i dont have to set the strums position manually just the group y pos
	player_group.position.y = 560 if downscroll else 55
	opponent_group.position.y = 560 if downscroll else 55
	
	for i in strums: i.downscroll = downscroll
	
	if middscroll:
		#player_group.position.x = (Game.screen[0] / 2) - 220
		#opponent_group.modulate.a = 0.25
		#opponent_group.z_index = -1
		#opponent_group.position = Vector2((Game.screen[0] / 2) - 220, player_group.position.y)
	
		player_group.position.x = (Game.screen[0] / 2) - 220
		opponent_group.modulate.a = 0.4
		opponent_group.scale = Vector2(0.7, 0.7)
		opponent_group.z_index = -1
		opponent_group.position = Vector2(60, 400 if downscroll else 300)
	
	health_bar.position.x = (Game.screen[0] / 2.0) # 340
	health_bar.position.y = 85 if downscroll else 630
	icon_p1.follow_spr = health_bar
	icon_p2.follow_spr = health_bar
	
	score_txt.position.x = (Game.screen[0] / 2) - (score_txt.size[0] / 2)
	if downscroll:
		score_txt.position.y = 130

var hp:float = 50:
	set(val): hp = clampf(val, 0, 100)
func _process(delta):
	health_bar.value = lerpf(health_bar.value, hp, delta * 7)
	offset.x = (scale.x - 1.0) * -(Game.screen[0] * 0.5)
	offset.y = (scale.y - 1.0) * -(Game.screen[1] * 0.5)
	
func update_score_txt():
	var stuff = [cur_scene.score, get_acc(), cur_scene.misses]
	score_txt.text = 'Score: %s - Accuracy: [%s] - Misses: %s' % stuff

func get_acc():
	var new_acc = clampf(note_percent / total_hit, 0, 1)
	if is_nan(new_acc): return '?'
	return str(Game.round_d(new_acc * 100, 2)) +'%'
	
func spawn_splash(strum:Strum):
	var new_splash = SPLASH.instantiate()
	new_splash.strum = strum
	add_to_strum_group(new_splash, true)
	await new_splash.animation_finished
	$Strum_Group/Player.remove_child(new_splash)
	new_splash.queue_free()
	
func add_to_strum_group(item = null, to_player:bool = true):
	if item == null: return
	var group = $'Strum_Group/Player' if to_player else $'Strum_Group/Opponent'
	group.add_child(item)

func add_behind(item):
	add_child(item)
	move_child(item, 0)

func change_style(new_style:String): # change style of whole hud, instead of one by one
	cur_style = new_style
	STYLE.load_style(new_style)
	for strum in strums: strum.load_skin(STYLE)
	for note in Game.scene.notes: note.load_skin(STYLE)

var count_down:Timer
var times_looped:int = -1

func start_countdown(from_beginning:bool = false):
	if from_beginning:
		Conductor.song_pos = -Conductor.crochet * 5
		count_down = Timer.new() # get_tree.create_timer starts automatically and isn't reusable
		add_child(count_down)
	
	count_down.start(Conductor.crochet / 1000)
	await count_down.timeout
	times_looped += 1
	
	for i in characters:
		if times_looped % i.dance_beat == 0 and !i.animation.begins_with('sing'):
			i.dance()

	if times_looped < 4:
		if times_looped > 0:
			var spr = Sprite2D.new()
			spr.texture = load('res://assets/images/ui/styles/'+ cur_style +'/'+ countdown_spr[times_looped - 1] +'.png')
			add_child(spr)
			spr.scale = STYLE.countdown_scale
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if STYLE.antialiased else CanvasItem.TEXTURE_FILTER_NEAREST
			Game.center_obj(spr)
			
			var tween = create_tween().tween_property(spr, 'modulate:a', 0, Conductor.crochet / 1000)
			tween.finished.connect(spr.queue_free)
		Audio.play_sound('skins/'+ cur_style +'/'+ sounds[times_looped])
		start_countdown()
	else:
		remove_child(count_down)
		count_down.queue_free()
		times_looped = -1
