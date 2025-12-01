if action == 0 exit
var _d_x = mouse_x - mouse_start[0]  
var _d_y = mouse_y - mouse_start[1]  

if action == 1
{
	x += _d_x
	y += _d_y
	
	force.x = x
	force.y = y
}
else if action == 2
{
	image_xscale = 1
		image_yscale = 1
	var _s = point_distance(x,y,mouse_x,mouse_y)/(sprite_width/2)
	image_xscale = _s
	image_yscale = _s
	force.set_range_radial(sprite_height/2)
}
mouse_start = [mouse_x,mouse_y]