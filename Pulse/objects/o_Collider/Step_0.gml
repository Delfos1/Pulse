if move
{
	x = mouse_x
	y = mouse_y
	
	if xprevious != x || yprevious != y
	{
		with ParticlesParent
		{
			var col = emitter.check_collision(x,y)
			
			/*
			if (col != undefined)
			{
				if array_contains(col,other.id)
				{
					sys.cache_update_collisions(cache)
				}
			}*/
		}
	}
}






