extends Resource

var strum_skin:SpriteFrames = load('res://assets/images/ui/styles/pixel/strums.res')
var rating_skin:Texture2D = load('res://assets/images/ui/styles/pixel/ratings.png')
var num_skin:Texture2D = load('res://assets/images/ui/styles/pixel/nums.png')

var strum_scale:Vector2 = Vector2(6, 6)
var note_scale:Vector2 = Vector2(6, 6)
var rating_scale:Vector2 = Vector2(5, 5)
var num_scale:Vector2 = Vector2(5.5, 5.5)

var has_countdown:bool = true # there are countdown images for the style
var countdown_scale:Vector2 = Vector2(6, 6)

var antialiased:bool = false
