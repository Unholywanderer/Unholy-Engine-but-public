extends Node2D

var char_list:Array[Label] = []
var anim_list:Array[Label] = []

var sub_anim:Dictionary = {
	'anim': '',
	'offsets': [0, 0],
}
var new_json:Dictionary = {
	'animations': {}
}

var cur:String = ''
var char:Character
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_file_dialog_file_selected(path):
	$FileDialog.popup_centered()
	var split = path.split('/')
	cur = split[split.size()-1].replace('.res', '')
	#char = Character.new([300, 400], cur)
	add_child(char)
	update_anims(char.offsets.keys())
	
func update_anims(anims):
	print(anims)
	for anim in anim_list:
		anim_list.remove_at(anim_list.find(anim))
		$TextLayer.remove_child(anim)
		anim.queue_free()
	anim_list.clear()
	
	for i in anims.size():
		var anim = anims[i]
		var lab = Label.new()
		lab.position.x = 20
		lab.position.y = 50 + (15 * i)
		lab.text = anim
		$TextLayer.add_child(lab)
		anim_list.append(lab)
