extends Resource

var strum_skin:SpriteFrames = load('res://assets/images/ui/styles/default/strums.res')
var rating_skin:Texture2D = load('res://assets/images/ui/styles/default/ratings.png')
var num_skin:Texture2D = load('res://assets/images/ui/styles/default/nums.png')

var strum_scale:Vector2 = Vector2(0.7, 0.7)
var note_scale:Vector2 = Vector2(0.7, 0.7)
var rating_scale:Vector2 = Vector2(0.7, 0.7)
var num_scale:Vector2 = Vector2(0.5, 0.5)

var has_countdown:bool = true # there are countdown images for the style
var countdown_scale:Vector2 = Vector2(1, 1)

var antialiased:bool = true
