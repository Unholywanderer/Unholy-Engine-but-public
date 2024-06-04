class_name NoteData; extends Resource;

var strum_time:float
var must_press:bool
var dir:int

var speed:float
var type:String

var length:float

func _init(data):
	if data != null:
		strum_time = floor(data[0])
		dir = data[1] % 4
		length = data[3]
		must_press = data[4]
		type = data[5]
