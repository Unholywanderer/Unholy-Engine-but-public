extends StageBase

func _ready(): 
	$BG.play('background 2 instance 1')
	default_zoom = 1.05
	bf_pos = Vector2(770, -55)
	dad_pos = Vector2(100, -55)
	gf_pos = Vector2(300, -10)
	
	bf_cam_offset.y = 100
	dad_cam_offset.y = 100
