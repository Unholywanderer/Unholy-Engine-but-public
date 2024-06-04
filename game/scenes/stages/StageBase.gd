class_name StageBase extends Node2D

# things all stages will have
var default_zoom:float = 0.8
var cam_speed:float = 4

var beat:int:
	get: return Conductor.cur_beat
var step:int:
	get: return Conductor.cur_step
var section:int:
	get: return Conductor.cur_section

var boyfriend:Character:
	get: return Game.scene.boyfriend
var dad:Character:
	get: return Game.scene.dad
var gf:Character:
	get: return Game.scene.gf

# initial positions the characters will take
# set these on _ready()
var bf_pos:Vector2 = Vector2(770, 100)
var dad_pos:Vector2 = Vector2(100, 100)
var gf_pos:Vector2 = Vector2(450, 70)

# added onto the character's camera position
var bf_cam_offset:Vector2 = Vector2(0, 0)
var dad_cam_offset:Vector2 = Vector2(0, 0)
var gf_cam_offset:Vector2 = Vector2(0, 0)

func _ready():
	pass # Replace with function body.
