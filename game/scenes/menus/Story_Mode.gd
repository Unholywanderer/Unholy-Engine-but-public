extends Node2D

var weeks:Array[Sprite2D] = []
func _ready():
	for i in 8:
		var new_week = Sprite2D.new()
		new_week.texture = load('res://assets/images/story_mode/weeks/'+ ('tutorial' if i == 0 else 'week'+str(i)) +'.png')
		#new_week.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
