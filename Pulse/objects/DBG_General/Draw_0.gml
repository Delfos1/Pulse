if !created_maps
{
	displ_map = array_create(8)
	var i = 0
	repeat(8){
	displ_map[i] = buffer_from_sprite(_64_pol,i)
	i++
	}
	color_map = buffer_from_sprite(colormap,0)
	created_maps = true
}