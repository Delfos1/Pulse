var _d = point_distance(x,y,mouse_x,mouse_y),
 _w = sprite_width*.5 ,
 _h = sprite_height*.5,
_relx = abs(mouse_x-x) ,
_rely =  abs(mouse_y-y),
_dir_to_mouse = point_direction(x, y, mouse_x, mouse_y),
_angle_diff = abs(angle_difference(_dir_to_mouse, image_angle))%90,
_corner = radtodeg(arctan2(sprite_height,sprite_width))


mouse_start = [mouse_x,mouse_y]

if _d < _w*.75 && _d < _h *.75
{
	// move
	action = 1
}
else if abs(_angle_diff - _corner) < 10
{
		// rotate
	action = 2
}
else if _d < _w*.90 && _d < _h *.90
{
	if _relx > _rely
	{
		//scale x
		action = 3
	}
	else
	{
		//scale y
		action = 4
	}
}
