/// feather ignore all

function __pulse_map(_map,_parent) constructor
{
	parent			= _parent;
	buffer			= _map;
	scale_u			=	1;
	scale_v			=	1;
	offset_u		=	0;
	offset_v		=	0;
	color_blend		=1;
	
	static	set_uv_scale	=	function(u,v)
	{
		scale_u = abs(u);
		scale_v = abs(v);
		return self
	}
	
	static	set_offset		=	function(x,y)
	{
		offset_u		=	x;
		offset_v		=	y;
		return self
	}
}