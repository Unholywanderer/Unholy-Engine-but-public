class_name HealthBar; extends Control;

#var lerp_val:bool = false # make value smoothly change instead of instant
#var last_val:float = 50 # for lerping
@onready var bar = $Bar
@onready var spr = $Sprite

var width:float:
	get: return $Bar.get_size()[0]
	
var height:float:
	get: return $Bar.get_size()[1]
	
var value:float = 50:
	set(new_val):
		value = new_val
		$Bar.value = value
		
func set_colors(left:Color, right:Color): # i might use this maybe who knows
	if left != null: $Bar
	if right != null: $Bar
	
	
func _ready():
	if $Sprite == null:
		var new = Sprite2D.new()
		new.name = 'Sprite'
		new.texture = load('res://assets/images/ui/healthBar.png')
		add_child(new)
	if $Bar == null:
		var new = ProgressBar.new()
		new.name = 'Bar'
		add_child(new)

#func _process(delta):
#	pass
