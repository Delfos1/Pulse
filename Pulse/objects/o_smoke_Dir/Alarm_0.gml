
if parent.x != _x   // If Emitter has moved
{
	/*
	wall = collision_line(x,y,parent.x,parent.y,oWall,false,true)
	
	if wall != noone
	{
		if parent.x > wall.x
		{
			x	=	wall.bbox_right+20
		}
		else
		{
			x	=	wall.bbox_left-20
		}
	}
	else
	{
		x=parent.x
	}
	*/
	x=parent.x
	y=parent.y-300
	
	_x	=	x
}

alarm[0]=3