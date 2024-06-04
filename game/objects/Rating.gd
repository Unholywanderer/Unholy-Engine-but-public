class_name Rating; extends Node2D;

var style:StyleInfo = Game.scene.ui.STYLE
var path:String = 'res://assets/images/ui/styles/'+ ''
var rating_pos:Vector2 = Vector2(610, 500)
var combo_pos:Vector2 = Vector2(580, 560)
var spacing:float = 43

var ratings_data:Dictionary = {
	'name':       ['sick', 'good', 'bad', 'shit'],
	'score':      [  350,    200,   100,    50],
	'hit_window': [   45,     90,   135,  null],
	'hit_mod':    [    1,   0.75,   0.5,   0.2] # 1.0, 0.9, 0.7, 0.4, 0.2
}

var cur_index = 0
func get_rating(diff:float):
	cur_index = 0
	for i in ratings_data.hit_window.size() - 1:
		var win = Prefs.get(ratings_data.name[i] + '_window')
		if absf(diff) <= win:
			return ratings_data.name[i]
		cur_index += 1
	return ratings_data.name[ratings_data.name.size() - 1]

func get_score(rating:String):
	var to_return = []
	var index = ratings_data.name.find(rating)
	to_return.append(ratings_data.score[index])
	to_return.append(ratings_data.hit_mod[index])
	return to_return

func make_rating(rate:String = 'sick'):
	var rating = VelocitySprite.new()
	rating.position = rating_pos
	rating.texture = style.rating_skin
	rating.hframes = ratings_data.name.size()
	rating.frame = ratings_data.name.find(rate.to_lower())
	
	rating.moving = true
	rating.velocity.y = randi_range(-140, -175)
	rating.acceleration.y = 550
	rating.scale = style.rating_scale
	rating.antialiasing = style.antialiased
	
	return rating

func make_combo(combo):
	var loops:int = 0
	var all_nums = []
	for i in str(combo).split():
		var num = VelocitySprite.new()
		num.position = combo_pos
		num.position.x += (spacing * loops)
		num.texture = style.num_skin
		num.hframes = 10
		num.frame = int(i)
		all_nums.append(num)
		
		num.moving = true
		num.acceleration.y = randi_range(200, 300)
		num.velocity.y = randi_range(-140, -160)
		num.velocity.x = randf_range(-5, 5)
		
		num.scale = style.num_scale
		num.antialiasing = style.antialiased
		loops += 1

	return all_nums
