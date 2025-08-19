if move
{
	x = mouse_x
	y = mouse_y
	
	if !instance_exists(DBG_Emitter) return
	
	if (xprevious != x || yprevious != y)  
	{
		with (DBG_Emitter)
		{
			activate_collision =  true
		}
	}
}






