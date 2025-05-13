if emit_smaller.displacement_map == undefined
{
	_map = buffer_from_sprite(_64_strght__00003,0)
	emit_smaller.set_displacement_map(_map)
	emit_smaller.displacement_map.set_size(1,[0,.45]).set_speed(.2,[0,20])
	emit.set_displacement_map(_map)
	emit.displacement_map.set_size(1,[0,.9]).set_position(1).set_speed(.2,[0,20])
	
}
else
{

	system.draw_it()
	system2.draw_it()
	draw_rectangle_color(x-200,y,x+200,y+200,c_black,c_black,c_black,c_black,false)

}