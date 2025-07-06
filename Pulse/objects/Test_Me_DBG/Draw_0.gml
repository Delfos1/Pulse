if !created_maps
{
	var _displ = buffer_from_sprite(_64_pol,0)
	emitter.set_displacement_map(_displ)

	
	var _color = buffer_from_sprite(mario,0)
	emitter.set_color_map(_color)

	
	created_maps = true
}