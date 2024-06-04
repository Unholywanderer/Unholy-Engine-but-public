class_name Checkbox; extends AnimatedSprite2D;

var follow_spr = null
var offsets = [-6, -39]
var checked:bool = false:
	set(checked): 
		if checked: 
			play('selected')
			offset = Vector2(offsets[0], offsets[1])
		else:
			play('unselected')
			offset = Vector2.ZERO
			
func _init():
	sprite_frames = load('res://assets/images/checkbox.res')

func _process(_delta):
	if follow_spr != null:
		position.x = follow_spr.position.x - 15
		position.y = -15 #follow_spr.position.y + follow_spr.height / 2
