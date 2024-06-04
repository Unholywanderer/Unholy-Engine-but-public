class_name StyleInfo; extends Resource;

var style:String = 'default' # just the current style as a string
var strum_skin:SpriteFrames = preload('res://assets/images/ui/styles/default/strums.res')
var rating_skin:Texture2D = preload('res://assets/images/ui/styles/default/ratings.png')
var num_skin:Texture2D = preload('res://assets/images/ui/styles/default/nums.png')

var strum_scale:Vector2 = Vector2(0.7, 0.7)
var note_scale:Vector2 = Vector2(0.7, 0.7)
var rating_scale:Vector2 = Vector2(0.7, 0.7)
var num_scale:Vector2 = Vector2(0.5, 0.5)

var has_countdown:bool = true # there are countdown images for the style
var countdown_scale:Vector2 = Vector2(1, 1)

var antialiased:bool = true

func load_style(style:String = 'default'):
	var style_to_check = 'assets/images/ui/styles/%s/' % [style]
	if DirAccess.dir_exists_absolute('res://'+ style_to_check):
		self.style = style
		var style_file = load('res://game/resources/styles/'+ style +'.gd').new()
		for item in style_file.get_script().get_script_property_list():
			if item.name in self:
				set(item.name, style_file.get(item.name))
	
	else:
		print_debug('STYLE: '+ style +' does not exist')
		return
