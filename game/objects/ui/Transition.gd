extends CanvasLayer

var tween
var def_x = -384
func _ready():
	tween = get_tree().create_tween()
	tween.finished.connect(complete)
	
	tween.tween_property($NormalTrans, "position:x", Game.screen[0], 0.4)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#$dannyboy.position.x = move_toward(def_x, get_viewport().size.x + ($dannyboy.texture.get_width() * $dannyboy.scale.x), delta)

func complete():
	tween = get_tree().create_tween()
	tween.tween_property($NormalTrans, "position:x", Game.screen[0] * 3, 0.4)
	tween.tween_callback($NormalTrans.queue_free)
