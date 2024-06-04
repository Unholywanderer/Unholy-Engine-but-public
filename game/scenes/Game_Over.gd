extends Node2D

var dead:Character
var this = Game.scene
var last_cam_pos:Vector2
var last_zoom:Vector2
func _ready():
	#await RenderingServer.frame_post_draw
	this.ui.process_mode = Node.PROCESS_MODE_ALWAYS
	this.cam.process_mode = Node.PROCESS_MODE_ALWAYS
	this.stage.process_mode = Node.PROCESS_MODE_ALWAYS
	this.ui.visible = false
	this.boyfriend.visible = false # hide his ass!!!
	Conductor.paused = true
	
	$BG.modulate.a = 0
	$Fade.modulate.a = 0
	
	dead = Character.new(this.boyfriend.position, this.boyfriend.death_char, true)
	#print(this.boyfriend.position - Vector2(-15, this.boyfriend.height * 0.83))

	add_child(dead)
	move_child(dead, 1)

	dead.play_anim('deathStart', true)
	Audio.play_sound('skins/default/fnf_loss_sfx')
	
	last_cam_pos = this.cam.position
	last_zoom = this.cam.zoom
	#create_tween().tween_property(this.cam, 'zoom', Vector2(1.05, 1.05), 2.5).set_trans(Tween.TRANS_ELASTIC)#\
#	.set_delay(0.7)
	
	fade_in()
	await get_tree().create_timer(2.5).timeout
	
	if !retried:
		Audio.play_music('skins/default/gameOver-pico')
		dead.play_anim('deathLoop')

func fade_in():
	create_tween().tween_property($BG, 'modulate:a', 0.7, 0.7).set_trans(Tween.TRANS_SINE)

var retried:bool = false
var focused:bool = false
func _process(delta):
	$BG.scale = (Vector2.ONE / this.cam.zoom) + Vector2(0.05, 0.05)
	$BG.position = (get_viewport().get_camera_2d().get_screen_center_position() - (get_viewport_rect().size / 2.0) / this.cam.zoom)
	$BG.position -= Vector2(5, 5) # you could see the stage bg leak out
	$Fade.position = $BG.position
	if !retried:
		this.cam.zoom.x = lerpf(this.cam.zoom.x, 1.05, delta * 4)
		this.cam.zoom.y = this.cam.zoom.x
	
	if dead.frame >= 14 and !focused:
		focused = true
		this.cam.position_smoothing_speed = 2
		this.cam.position = dead.position + Vector2(dead.width / 2, (dead.height / 2) - 30)


	if Input.is_action_just_pressed('accept'):
		retried = true
		Audio.play_music('skins/default/gameOverEnd-pico', false)
		dead.play_anim('deathConfirm', true)
		await get_tree().create_timer(2).timeout
		var cam_twen = create_tween().tween_property(this.cam, 'position', last_cam_pos, 1).set_trans(Tween.TRANS_SINE)
		create_tween().tween_property($BG, 'modulate:a', 0, 0.7).set_trans(Tween.TRANS_SINE)
		create_tween().tween_property(this.cam, 'zoom', last_zoom, 1).set_trans(Tween.TRANS_SINE)
		await cam_twen.finished
		this.ui.process_mode = Node.PROCESS_MODE_INHERIT
		this.cam.process_mode = Node.PROCESS_MODE_INHERIT
		this.cam.position_smoothing_speed = 4
		this.boyfriend.process_mode = Node.PROCESS_MODE_INHERIT
		this.stage.process_mode = Node.PROCESS_MODE_INHERIT
		this.boyfriend.visible = true
		this.ui.visible = true
		get_tree().paused = false
		this.refresh()
		queue_free()
		
		#get_tree().reload_current_scene()
	elif Input.is_action_just_pressed('back') and !retried:
		Audio.stop_music()
		Conductor.reset()
		get_tree().paused = false
		Game.switch_scene('menus/freeplay')
