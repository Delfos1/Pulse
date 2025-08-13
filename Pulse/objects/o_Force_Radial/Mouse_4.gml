var _d = point_distance(x,y,mouse_x,mouse_y),
 _w = sprite_width*.5 ,
 _h = sprite_height*.5,
_relx = abs(mouse_x-x) ,
_rely =  abs(mouse_y-y)




mouse_start = [mouse_x,mouse_y]

if _d < _w*.75 && _d < _h *.75
{
	// move
	action = 1
}
else 
{
		action = 2
}
