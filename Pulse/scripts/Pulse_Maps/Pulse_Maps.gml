/// feather ignore all

function __pulse_map(_map) constructor
{
	buffer			= _map;
	scale_u			=	1;
	scale_v			=	1;
	offset_u		=	0;
	offset_v		=	0;
	alpha_mode		=	0;
	static	set_uv_scale	=	function(u,v)
	{
		scale_u = u;
		scale_v = v;
		return self
	}
	
	static	set_offset		=	function(x,y)
	{
		offset_u		=	x;
		offset_v		=	y;
		return self
	}

	/// sets how the alpha is used in color maps. 0 changes the size of particles, 1 turns the particle off if alpha is below 50%, 2 doesn't use the alpha information.
	static	set_alpha_mode = function(_mode)
	{
		alpha_mode = clamp(_mode,0,2)
		return self
	}

    static destroy = function() {
        buffer_delete(buffer.noise);
		delete buffer
    };

}