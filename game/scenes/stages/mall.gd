extends StageBase

func _ready():
	default_zoom = 0.8
	bf_pos = Vector2(970, 100)
	gf_pos = Vector2(350, 100)
	
	bf_cam_offset = Vector2(-50, -100)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func beat_hit():
	for i in [$UpperBop/Sprite, $BottomBop, $Santa]:
		i.play()
		i.frame = 0
