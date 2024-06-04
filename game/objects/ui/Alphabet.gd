class_name Alphabet; extends Control;

var all_letters:Array = []
var width:float = 0
var height:float = 0
var spaces:int = 0
var rows:int = 0

var x_diff:int = 45
var y_diff:int = 65
@export var bold:bool = false
var text:String = '':
	set(new_txt):
		while all_letters.size() > 0:
			all_letters[0].queue_free()
			remove_child(all_letters[0])
			all_letters.remove_at(0)
		text = new_txt.replace("\\n", "\n")
		if bold: text = text.to_lower() #picky lil bitch
		make_text(text)

var is_menu:bool = false
var lock = Vector2(-1, -1)
var target_y:int = 0
var spacing:int = 150

func _init(init_text:String = '', is_bold:bool = true):
	bold = is_bold
	if init_text.length() > 0:
		text = init_text
	
func make_text(tx:String):
	all_letters.clear()
	var letters_made:Array[Letter] = []
	
	var sheet:SpriteFrames = load('res://assets/images/ui/alphabet/%s.res' % ['bold' if bold else 'normal'])

	var offsets = Vector2.ZERO
	width = 0
	height = 0
	
	var cur_loop:int = 0
	for i in tx.split():
		var is_space = (i == ' ')
		if is_space: spaces += 1
		if i == '\n': rows += 1
		
		if spaces != 0: offsets.x += (x_diff * spaces)
		spaces = 0
		
		if rows != 0:
			offsets.x = 0
			offsets.y += y_diff * rows
		rows = 0
		
		var anim = get_anim(i)
		var letter = Letter.new(offsets, i, cur_loop, rows)
		if anim != '' and is_instance_valid(sheet):
			var e:= sheet.get_frame_texture(anim, 0)
			var let:String = anim if e != null else "?"
			
			letter.char = anim # just in case
			letter.sprite_frames = sheet
			letter.centered = false
			letter.play(let)
			letter.offset = offset_letter(i) #Vector2.ZERO #true_offsets
			letter.modulate = Color.BLACK if !bold else Color.WHITE
			if !bold: letter.offset.y -= letter._height / 1.2
			offsets.x += letter._width
			
		letters_made.append(letter)
		cur_loop += 1
		
	for i in letters_made:
		if i.char != '': width += i._width
		add_child(i)
		all_letters.append(i)
	height = letters_made.back()._height
	letters_made.clear()

func _process(delta):
	if is_menu:
		var remap_y:float = remap(target_y, 0, 1, 0, 1.1)
		var scroll:Vector2 = Vector2(
			lock.x if lock.x != -1 else lerpf(position.x, (target_y * 35) + 150, (delta / 0.16)),
			lock.y if lock.y != -1 else lerpf(position.y, (remap_y * spacing) +
			 (Game.screen[0] * 0.28), (delta / 0.16))
		)
		position = scroll

func get_anim(item):
	item = item.dedent()
	match item:
		"{": return "(" if !bold else "{"
		"}": return ")" if !bold else "}"
		"[": return "(" if !bold else "["
		"]": return ")" if !bold else "]"
		"&": return "amp"
		"!": return "exclamation"
		"'": return "apostrophe"
		_:
			if item == null or item == "" or item == "\n": return ""
			if !bold:
				if Letter.ALPHABET.find(item.to_lower()) != -1:
					var casing = (' upper' if item.to_lower() != item else ' lower') + 'case'
					return "%s".dedent() % [item.to_lower() + casing]
			return item.to_lower().dedent()

func offset_letter(item):
	match item:
		'-': return Vector2(0, 25)
		'!': return Vector2(0, -5)
		':': return Vector2(0, 7)
		_: return Vector2.ZERO

class Letter extends AnimatedSprite2D:
	const ALPHABET = 'abcdefghijklmnopqrstuvwxyz'
	const SYMBOLS = "(){}[]\"!@#$%'*+-=_.,:;<>?^&\\/|~"
	const NUMBERS = '1234567890'
	
	var is_bold:bool = true
	var char:String = ''
	var id:int = 0
	var row:int = 0
	
	var _width = 0: 
		get: return get_thing('width')
	var _height = 0: 
		get: return get_thing('height')
	
	func _init(pos:Vector2, char:String, id:int, row:int):
		self.position = pos; self.char = char;
		self.id = id; self.row = row;
		
	func get_thing(the:String):
		if sprite_frames == null or !sprite_frames.has_animation(char): return 47 if the == 'width' else 65
		if the == 'width': return sprite_frames.get_frame_texture(char, 0).get_width()
		if the == 'height': return sprite_frames.get_frame_texture(char, 0).get_height()
