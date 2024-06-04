extends StageBase

var dancers:Array[LimoDancer] = []
func _ready():
	bf_pos = Vector2(1030, -120)
	bf_cam_offset.x = -200
	gf_pos.y = 120
	
	default_zoom = 0.9
	#$BGLimo/Sprite.play()
	#$FGLimo.play()
	for i in 5: # fuck positioning things by hand
		var limo = $BGLimo/Sprite.position
		var new_dancer = LimoDancer.new(Vector2((370 * i) + 440 + limo.x, limo.y - 875))
		$BGLimo/LimoDancers.add_child(new_dancer)
		dancers.append(new_dancer)

func _process(delta):
	pass

func beat_hit():
	for dancer in dancers:
		dancer.dance()

class LimoDancer extends AnimatedSprite2D:
	var danced:bool = false
	func _init(pos:Vector2):
		centered = false
		position = pos
		sprite_frames = load('res://assets/images/stages/limo/limoDancer.res')
		frame = sprite_frames.get_frame_count('danceLeft') - 1
	
	func dance():
		danced = !danced
		play('dance'+ ('Right' if danced else 'Left'))
