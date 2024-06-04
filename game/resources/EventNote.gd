class_name EventNote; extends Resource;

var strum_time:float = 0.0
var event:String = ''
var values:Array[Variant] = []

# new event should be [strum_time, [eventname, value1, value2,...] and so on 
# but since its psych theres only likely gonna be 2
func _init(new_event):
	print(new_event)
	strum_time = new_event[0]
	event = new_event[1][0]
	for val in new_event[1]:
		if val == event: continue # das the event name dont need that....
		values.append(val)
