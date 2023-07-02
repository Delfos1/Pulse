//Generate the buffer from a sprite, but only once!

if emit.color_map == undefined
{
	//You'll need to destroy this buffer when you are done, check the Clean Up event
	_map = buffer_from_sprite(mario,0)
	emit.set_color_map(_map)
	//setting the size will make any particles appearing in a spot with 0 alpha to have no size 
	emit.set_displace_size(1)
}