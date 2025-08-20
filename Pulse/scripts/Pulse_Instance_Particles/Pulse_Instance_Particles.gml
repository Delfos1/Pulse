/// @description			Use this to create a new instance particle 
/// @param {Asset.GMObject}		_object : Object that will be instantiated
/// @param {String}			_name : Name your particle or leave empty to use the default name
/// @return {Struct}
function pulse_instance_particle	(_object,_name=__PULSE_DEFAULT_PART_NAME) : __pulse_particle_class(_name) constructor
{
	name			=	string(_name)
	if particle_exists(index) part_type_destroy(index)
	index			=	_object
	sprite			=	object_get_sprite(_object)
	
	#region //SET BASIC PROPERTIES
	static set_size			=	function(_min,_max,_incr=0,_wiggle=0)
	{
		size	=[_min,_max,_incr,_wiggle]
		
		return self
	}
	static set_scale		=	function(scalex,_scaley)
	{
		scale			= [scalex,_scaley]
		return self
	}
	static set_life			=	function(_min,_max)
	{
		life	=[_min,_max]
		return self
	}
	static set_color		=	function(color1,color2=-1,color3=-1)
	{
		if color3 != -1
		{
			color=[color1,color2,color3]	
		}
		else if color2 != -1
		{
			color=[color1,color2]
		}
		else
		{
			color=[color1]
		}
		color_mode		= __PULSE_COLOR_MODE.COLOR
		return self
	}
	static set_alpha		=	function(alpha1,alpha2=-1,ac_curve=-1)
	{
		if alpha2 != -1
		{
			alpha=[alpha1,alpha2]

		}
		else
		{
			alpha=[alpha1]

		}
		return self
	}
	static set_blend		=	function(_blend)
	{
		blend	=	_blend
		return self

	}
	static set_speed		=	function(_min,_max,_incr=0,_wiggle=0)
	{
		speed	=[_min,_max,_incr,_wiggle]
		return self
	}
	static set_sprite		=	function(_sprite,_animate=false,_stretch=false,_random=true)
	{
		sprite			=	[_sprite,_animate,_stretch,_random]

	}
	static set_orient		=	function(_min,_max,_incr=0,_wiggle=0,_relative=true)
	{
		orient	=[_min,_max,_incr,_wiggle,_relative]
		return self
	}
	static set_gravity		=	function(_amount,_direction)
	{
		gravity	=[_amount,_direction]
		return self
	}
	static set_direction	=	function(_min,_max,_incr=0,_wiggle=0)
	{
		direction	=[_min,_max,_incr,_wiggle]
		return self
	}
	#endregion
	
	static launch		=	function(_struct)
	{	

		if _struct.part_system.layer == -1
		{
			var _i = instance_create_depth(_struct.x_origin,_struct.y_origin,_struct.part_system.depth,index,_struct)
		}
		else
		{
			var _i = instance_create_layer(_struct.x_origin,_struct.y_origin,_struct.part_system.layer,index,_struct)	
		}
		
		with (_i)
		{
			if size != undefined
			{
				image_xscale = scale[0] * particle.scale[0]
				image_yscale = scale[1] * particle.scale[1]
			}
				//color_mode : distr_color_mix 
			image_angle =  orient ?? image_angle
			image_index = frame ?? image_index 
			direction = dir
		}
	}
}