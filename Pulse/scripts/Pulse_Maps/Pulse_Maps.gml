/// @function              
/// @description             
/// @param {Id.Instance}     
/// @param {Asset.GMObject}  
/// @return {Bool}
function __pulse_map(_map) constructor
{
	buffer			= _map;
	scale_u			=	1;
	scale_v			=	1;
	offset_u		=	0;
	offset_v		=	0;
	position		=false;
	position_amount	=1;
	speed			=false;
	speed_amount	=1;
	life			=false;
	life_amount		=1;
	size			=false;
	size_amount		=1;
	orientation		=false;
	orient_amount	=1;
	color_A_to_B	=false;
	color_A			=-1;
	color_B			=-1;
	color_mode		= PULSE_COLOR.NONE;
	color_blend		=1;
		
	
	static	set_position	=	function(amount)
	{
		position = true;
		position_amount = amount;
		
		return self
	}
	
	static	set_size		=	function(amount)
	{
		size = true;
		size_amount = amount;
		
		return self
	}
	
	static	set_speed		=	function(amount)
	{
		speed = true;
		speed_amount = amount;
		
		return self
	}
	
	static	set_orientation	=	function(amount)
	{
		orientation = true;
		orient_amount = amount;
		
		return self
	}
	
	static	set_life		=	function(amount)
	{
		life = true;
		life_amount = amount;
		
		return self
	}
	
	static	set_AB_color	=	function(_color_A,_color_B,_color_mode= PULSE_COLOR.A_TO_B_RGB,_blend=1)
	{
		if _color_mode== PULSE_COLOR.A_TO_B_RGB
		{
			color_A			= [color_get_red(_color_A),color_get_blue(_color_A),color_get_green(_color_A)]
			color_B			= [color_get_red(_color_B),color_get_blue(_color_B),color_get_green(_color_B)]
			color_A_to_B	= true
			color_mode		= _color_mode
			color_blend		= _blend
			return self
		}
		else if _color_mode== PULSE_COLOR.A_TO_B_HSV
		{
			
			color_A			= [color_get_hue(_color_A),color_get_saturation(_color_A),color_get_value(_color_A)]
			color_B			= [color_get_hue(_color_B),color_get_saturation(_color_B),color_get_value(_color_B)]
			color_A_to_B	= true
			color_mode		= _color_mode
			color_blend		= _blend
			return self
		}
		else
		{
			__pulse_show_debug_message("PULSE ERROR: Color mode needs to be A to B for displacement maps")
			return self
		}
		
	}
	
	static	set_color_map	=	function(_blend=1)
	{
		color_mode= PULSE_COLOR.COLOR_MAP
		color_blend		= _blend
		return self
	}
	
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