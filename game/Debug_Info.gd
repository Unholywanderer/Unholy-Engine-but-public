extends CanvasLayer

var time_existed:float = 0
var vol_visible:bool = false
var vol_tween
var volume:float = 1:
	set(vol):
		$VolumeBar.position.y = 0
		vol_visible = true
		time_existed = 0
		AudioServer.set_bus_volume_db(0, linear_to_db(vol))
		volume = vol
var vol_lerp:float = 10

@onready var fps_txt = $FPS
func _ready():
	fps_txt.position = Vector2(10, 10)

func _process(delta):
	if vol_visible:
		vol_lerp = lerpf(vol_lerp, volume * 10, delta * 15)
		$VolumeBar.value = vol_lerp
		time_existed += delta
		if time_existed >= 1:
			vol_visible = false
			if vol_tween:
				vol_tween.kill()
			vol_tween = create_tween()
			vol_tween.tween_property($VolumeBar, 'position:y', -50, 0.5)
	
	
	var mem:String = String.humanize_size(OS.get_static_memory_usage()).replace('i', '')
	var mem_peak:String = String.humanize_size(OS.get_static_memory_peak_usage()).replace('i', '')
	fps_txt.text = 'FPS: ' + str(Engine.get_frames_per_second())+'\n' + 'Mem: ' + mem + ' / ' + mem_peak
	
	
func _unhandled_key_input(_event):
	if Input.is_action_just_pressed('vol_up'): volume = min(volume + 0.1, 1)
	if Input.is_action_just_pressed('vol_down'): volume = max(volume - 0.1, 0)
