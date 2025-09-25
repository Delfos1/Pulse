/// @description			Use this to create a new instance particle 
/// @param {Asset.GMObject}		_object : Object that will be instantiated
/// @param {String}			_name : Name your particle or leave empty to use the default name
/// @return {Struct}
function pulse_instance_particle	(_object,_name=__PULSE_DEFAULT_PART_NAME) : __pulse_particle_class(_name) constructor
{
	name			=	string(_name)
	if particle_exists(index) part_type_destroy(index)
	index			=	_object
	sprite			=	[object_get_sprite(_object),false,false,true]
	
	alpha_mode =  false // TRUE for Curve, FALSE for Lerp
	alpha_curve = undefined
	
	#region //SET BASIC PROPERTIES
	#region jsDoc
		/// @desc    Sets the size of the particle, as a percentage of the sprite, 1 == 100%. 
		///          The arguments can be arrays as a [x,y]. This will make the two axis independently random
		/// @param   {Real,Array<Real>} _min : The minimum size a particle can start at. Can be an array as a [x,y]
		/// @param   {Real,Array<Real>} _max : The maximum size a particle can start at. Can be an array as a [x,y]
		/// @param   {Real,Array<Real>} [_incr] : How much the particle will increment or decrease per step. Can be an array as a [x,y] . DEFAULT : 0
		/// @param   {Real,Array<Real>} [_wiggle] : How much should randomly be added or substracted per step (frequency is fixed at every step). Can be an array as a [x,y]. DEFAULT : 0
		#endregion
	static set_size			=	function(_min,_max,_incr=0,_wiggle=0)
	{
		size	=[_min,_max,_incr,_wiggle]
		
		return self
	}
	#region jsDoc
		/// @desc    Sets the horizontal and vertical scale of the particle, regardless of the size of the particle.
		/// @param   {Real} [_scalex] : Scale of the x axis.  DEFAULT = 0
		/// @param   {Real} [_scaley] : Scale of the y axis.  DEFAULT = 0
		#endregion
	static set_scale		=	function(scalex,_scaley)
	{
		scale			= [scalex,_scaley]
		return self
	}
	#region jsDoc
			/// @desc    It sets the range a particle will last, in amount of steps.
			/// @param   {Real} _min : The minimum a particle will last.
			/// @param   {Real} _max : The maximum a particle will last.
		#endregion
	static set_life			=	function(_min,_max)
	{
		life	=[_min,_max]
		return self
	}
	#region jsDoc
			/// @desc    It sets the color of a particle. It combines the regular color options for particles.
			/// __PULSE_COLOR_MODE.COLOR will use one to three colors, and interpolate them throughout the particles life.
			///  __PULSE_COLOR_MODE.RGB will use either three colors or three arrays, corresponding to the minimum and maximum values of the Red,Green and Blue components
			///  __PULSE_COLOR_MODE.HSV will use either three colors or three arrays, corresponding to the minimum and maximum values of the Hue,Saturation and Value components
			///  __PULSE_COLOR_MODE.MIX will use two colors, which will be mixed at random for each particle.
			/// @param   {Real, Array<Real>} color1 : Can be a color, a Red value, a Hue value, or an array of minimum or maximum Red/Hue
			/// @param   {Real, Array<Real>} [color2] : Can be a color, a Green value, a Saturation value, or an array of minimum or maximum Green/Saturation
			/// @param   {Real, Array<Real>} [color3] : Can be a color, a Blue value, a Value component, or an array of minimum or maximum Blue/Value
			/// @param   {Enum.__PULSE_COLOR_MODE} [_mode] :  The mode which will be used. Use the enum __PULSE_COLOR_MODE.
		#endregion
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
	#region jsDoc
			/// @desc    It sets the alpha of a particle. It can use from one to three values.
			/// @param   {Real} alpha1 : Alpha (transparency) value from 0 to 1
			/// @param   {Real} [alpha2] : Alpha (transparency) value from 0 to 1
			/// @param   {Real} [alpha3] : Alpha (transparency) value from 0 to 1
		#endregion
	static set_alpha		=	function(alpha1,alpha2=-1,alpha3=-1)
	{

		if alpha3 >= 0
		{
			alpha1 = clamp(alpha1,0,1)
			alpha2 = clamp(alpha2,0,1)
			alpha3 = clamp(alpha3,0,1)
			
			alpha=[alpha1,alpha2,alpha3]	
		}
		else if alpha2 >= 0
		{
			alpha1 = clamp(alpha1,0,1)
			alpha2 = clamp(alpha2,0,1)
			alpha=[alpha1,alpha2]
		}
		else
		{
			alpha1 = clamp(alpha1,0,1)
			alpha=[alpha1]
		}
		return self
	}
	#region jsDoc
			/// @desc    It sets the alpha of a particle. It can use from one to two values plus an animation curve
			/// @param   {Real} alpha1 : Alpha (transparency) value from 0 to 1
			/// @param   {Real} [alpha2] : Alpha (transparency) value from 0 to 1
			/// @param   {Array} [ac_curve] : The animation curve and channel to use for the alpha. Must be supplied as an array like [curve, "channel_name"]
		#endregion
	static set_alpha_curve	=	function(alpha1,alpha2=-1,ac_curve=undefined)
	{
		if alpha2 != -1
		{
			alpha=[alpha1,alpha2]
			if ac_curve != undefined
				{
					if is_array(ac_curve)
					{
						if animcurve_really_exists(ac_curve[0]) && animcurve_channel_exists(ac_curve[0],ac_curve[1])
						{
								alpha_mode		=	true;
								alpha_curve	=	animcurve_get_channel(ac_curve[0],ac_curve[1]);
						}
							else{		__pulse_show_debug_message("Anim Curve or channel not found",2) }
					}else{				__pulse_show_debug_message("Anim Curve argument must be an array [curve,channel]",2)	}
			
				}
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
	#region jsDoc
			/// @desc    It sets the minimum and maximum speed of a particle. A deaccelerating particle can only go up to speed 0 (completely static), not to negative nummbers.
			/// @param   {Real} _min : The minimum starting speed of a particle, in pixels per game frame.
			/// @param   {Real} _max : The maximum starting speed of a particle, in pixels per game frame.
			/// @param   {Real} [_incr] : The acceleration of a particle. It can be a negative number, in pixels per game frame.
			/// @param   {Real} [_wiggle] : The wiggle value of the speed, to change every frame.
	#endregion
	static set_speed		=	function(_min,_max,_incr=0,_wiggle=0)
	{
		speed	=[_min,_max,_incr,_wiggle]
		return self
	}
	#region jsDoc
			/// @desc    Sets the image for the particle as one of the sprites loaded into the project.
			/// @param   {Asset.GMSprite} _sprite : The sprite to use.
			/// @param   {Bool} [_animate] : Whether to animate the sprite over time (true) or not. DEFAULT: FALSE
			/// @param   {Bool} [_stretch] : Whether to stretch the animation over the particle's life (true) or loop over it (false). DEFAULT: FALSE
			/// @param   {Bool} [_random] : Whether to pick a random starting frame (true) or not.
			/// @param   {Real} [_subimg] : The sub image (frame number) to use as a starting point, if randomness is false.  DEFAULT: 0.
	#endregion
	static set_sprite		=	function(_sprite,_animate=false,_stretch=false,_random=true)
	{
		sprite			=	[_sprite,_animate,_stretch,_random]

	}
	#region jsDoc
			/// @desc    It sets the minimum and maximum orientation of a particle.
			/// @param   {Real} _min : The minimum starting orientation of a particle, in degrees.
			/// @param   {Real} _max : The maximum starting orientation of a particle, in degrees.
			/// @param   {Real} [_incr] : The increase in degrees per game frame. Positive is CounterClockwise,negative is Clockwise. DEFAULT: 0
			/// @param   {Real} [_wiggle] : The wiggle value of the degrees, to change every frame, both CCW and CW. DEFAULT: 0
			/// @param   {Bool} [_relative] : Wheter to set its angle relative to the direction of the particle's motion or not. DEFAULT: TRUE
	#endregion
	static set_orient		=	function(_min,_max,_incr=0,_wiggle=0,_relative=true)
	{
		orient	=[_min,_max,_incr,_wiggle,_relative]
		return self
	}
	#region jsDoc
			/// @desc    Sets a force (usually the gravity) affecting the particle throughout its life. Its an acceleration added on top of the particle's acceleration.
			/// @param   {Real} _amount : The amount of acceleration added every frame to the particle.
			/// @param   {Real} _direction : The direction angle, in degrees, of that force.
	#endregion
	static set_gravity		=	function(_amount,_direction)
	{
		gravity	=[_amount,_direction]
		return self
	}
	#region jsDoc
		/// @desc    Sets the initial direction of a particle, in degrees. In Pulse, this direction will often be replaced by the emitter's properties.
		/// @param   {Real} _min : The minimum direction a particle can start at, in degrees.
		/// @param   {Real} _max : The maximum direction a particle can start at, in degrees.
		/// @param   {Real} [_incr] : How much the particle's direction will increment or decrease per step, in degrees. Can be negative or positive, and its the same (and simultaneous) for all particles. DEFAULT: 0
		/// @param   {Real} [_wiggle] : How much should randomly be added or substracted per step (frequency is fixed at every step). Its the same (and simultaneous) for all particles. DEFAULT: 0
		#endregion
	static set_direction	=	function(_min,_max,_incr=0,_wiggle=0)
	{
		direction	=[_min,_max,_incr,_wiggle]
		return self
	}
	#endregion
	
	static launch		=	function(_struct)
	{	
		var _i
		if _struct.part_system.layer == -1
		{
			_i = instance_create_depth(_struct.x_origin,_struct.y_origin,_struct.part_system.depth,index,_struct)
		}
		else
		{
			_i = instance_create_layer(_struct.x_origin,_struct.y_origin,_struct.part_system.layer,index,_struct)	
		}

	}
}