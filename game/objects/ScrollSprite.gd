class_name ScrollSprite; extends Node2D;

@export var scroll_factor:Vector2 = Vector2.ONE

var cam:Camera2D

func _process(_delta):
	cam = get_viewport().get_camera_2d()
	position = (cam.get_screen_center_position() - (get_viewport_rect().size / 2.0)) * (Vector2.ONE - scroll_factor)
