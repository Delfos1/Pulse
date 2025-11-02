if !created_maps
{
	displ_map = array_create(8)
	color_map = array_create(3)
	var i = 0
	repeat(8){
	displ_map[i] = buffer_from_sprite(_64_pol,i)
	i++
	}
	color_map[0] = buffer_from_sprite(colormap_nobg,0)
	color_map[1] = buffer_from_sprite(s_gradient,0)
	color_map[2] = buffer_from_sprite(Smoke_up___200_200__n,0)
	created_maps = true
}