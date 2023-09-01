//Generate the buffer from a sprite, but only once!

if emit.color_map == undefined
{
	//You'll need to destroy this buffer when you are done, check the Clean Up event
	_map = buffer_from_sprite(mario,0)
	emit.set_color_map(_map)
	//cache = emit.pulse(5000,x,y,true)
	//_map.Destroy()
}