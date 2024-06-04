extends StageBase

func _ready():
	#$FGTrees/Sprite.play()
	#$Petals/Sprite.play()
	default_zoom = 1.05
	bf_pos = Vector2(770, 90)
	dad_pos = Vector2(100, 30)
	gf_pos = Vector2(400, 130)
	
	bf_cam_offset.y = 100
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

class BGFreaks extends AnimatedSprite2D:
	var danced:bool = false
