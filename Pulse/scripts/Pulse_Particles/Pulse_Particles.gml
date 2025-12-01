global.pulse =
{
	systems		:	{},
	part_types	:	{},
	emitters	:	{},
	particle_factor:1,
}

/// @description			Use this to create a new particle
/// @param {String}			_name : Name your particle or leave empty to use the default name
/// @return {Struct}
function pulse_particle				(_name=__PULSE_DEFAULT_PART_NAME) : __pulse_particle_class(_name) constructor
{
	index			=	part_type_create();
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
		if is_array(_min) or is_array(_max) or is_array(_incr) or is_array(_wiggle)
		{
			size[0]= is_array(_min) ? _min[0] : _min  // x min
			size[1]= is_array(_min) ? _min[1] : _min  // y min
			size[2]= is_array(_max) ? _max[0] : _max  // x max
			size[3]= is_array(_max) ? _max[1] : _max  // y max
			size[4]= is_array(_incr) ? _incr[0] : _incr //x incr
			size[5]= is_array(_incr) ? _incr[1] : _incr  //y incr
			size[6]= is_array(_wiggle) ? _wiggle[0] : _wiggle  // x wigg
			size[7]= is_array(_wiggle) ? _wiggle[1] : _wiggle  // y wigg

			part_type_size_x(index,size[0],size[2],size[4],size[6])
			part_type_size_y(index,size[1],size[3],size[5],size[7])
			
		}
		else
		{
			size	=[_min,_min,_max,_max,_incr,_incr,_wiggle,_wiggle]
			part_type_size(index,size[0],size[2],size[4],size[6])
		}
		return self
	}
		#region jsDoc
		/// @desc    Sets the horizontal and vertical scale of the particle, regardless of the size of the particle.
		/// @param   {Real} [_scalex] : Scale of the x axis.  DEFAULT = 0
		/// @param   {Real} [_scaley] : Scale of the y axis.  DEFAULT = 0
		#endregion
	static set_scale		=	function(_scalex=undefined,_scaley=undefined)
	{
		if _scalex == undefined && _scaley == undefined 
		{
			return self
		}
		
		_scalex ??= scale[0]
		_scaley ??= scale[1]
		scale			= [_scalex,_scaley]
		part_type_scale(index,scale[0],scale[1]);
		return self
	}
		#region jsDoc
			/// @desc    It sets the range a particle will last, in amount of steps.
			/// @param   {Real} _min : The minimum a particle will last.
			/// @param   {Real} _max : The maximum a particle will last.
		#endregion
	static set_life			=	function(_min,_max)
	{
		_min = max(0,_min)
		_max = max(0,_max)
		life	=[_min,_max]
		part_type_life(index,life[0],life[1])
		return self
	}
		#region jsDoc
			/// @desc    It sets the color of a particle. It combines the regular color options for particles.
			/// PULSE_COLOR_PARTICLE.COLOR will use one to three colors, and interpolate them throughout the particles life.
			///  PULSE_COLOR_PARTICLE.RGB will use either three colors or three arrays, corresponding to the minimum and maximum values of the Red,Green and Blue components
			///  PULSE_COLOR_PARTICLE.HSV will use either three colors or three arrays, corresponding to the minimum and maximum values of the Hue,Saturation and Value components
			///  PULSE_COLOR_PARTICLE.MIX will use two colors, which will be mixed at random for each particle.
			/// @param   {Real, Array<Real>} color1 : Can be a color, a Red value, a Hue value, or an array of minimum or maximum Red/Hue
			/// @param   {Real, Array<Real>} [color2] : Can be a color, a Green value, a Saturation value, or an array of minimum or maximum Green/Saturation
			/// @param   {Real, Array<Real>} [color3] : Can be a color, a Blue value, a Value component, or an array of minimum or maximum Blue/Value
			/// @param   {Enum.PULSE_COLOR_PARTICLE} [_mode] :  The mode which will be used. Use the enum PULSE_COLOR_PARTICLE.
		#endregion
	static set_color		=	function(color1,color2=-1,color3=-1,_mode = PULSE_COLOR_PARTICLE.COLOR)
	{
		if color3 != -1 && color2 != -1
		{
			color=[color1,color2,color3]
			
			switch(_mode)
			{

				case PULSE_COLOR_PARTICLE.RGB :
					if is_array(color1) && is_array(color2) && is_array(color3)
					{
						part_type_color_rgb(index,color[0][0],color[0][1],color[1][0],color[1][1],color[2][0],color[2][1])
					}
					else
					{
						part_type_color_rgb(index,color[0],color[0],color[1],color[1],color[2],color[2])
					}
				break
				case PULSE_COLOR_PARTICLE.HSV :
					if is_array(color1) && is_array(color2) && is_array(color3)
					{
						part_type_color_hsv(index,color[0][0],color[0][1],color[1][0],color[1][1],color[2][0],color[2][1])
					}
					else
					{
						part_type_color_hsv(index,color[0],color[0],color[1],color[1],color[2],color[2])
					}
				break
				default: 		//		case PULSE_COLOR_PARTICLE.COLOR :
				_mode = PULSE_COLOR_PARTICLE.COLOR
					part_type_color3(index,color[0],color[1],color[2])
				break
			}
		}
		else if color2 != -1 && color3 == -1
		{
			color=[color1,color2]
			
			 if _mode == PULSE_COLOR_PARTICLE.MIX
			{
				part_type_color_mix(index,color[0],color[1])
			}else		// PULSE_COLOR_PARTICLE.COLOR
			{
				_mode = PULSE_COLOR_PARTICLE.COLOR
				part_type_color2(index,color[0],color[1])
			}
		}
		else
		{
			_mode = PULSE_COLOR_PARTICLE.COLOR
			color=[color1]
			part_type_color1(index,color[0])
		}
		color_mode		= _mode
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
			part_type_alpha3(index,alpha[0],alpha[1],alpha[2])
		}
		else if alpha2 >= 0
		{
			alpha1 = clamp(alpha1,0,1)
			alpha2 = clamp(alpha2,0,1)
			alpha=[alpha1,alpha2]
			part_type_alpha2(index,alpha[0],alpha[1])
		}
		else
		{
			alpha1 = clamp(alpha1,0,1)
			alpha=[alpha1]
			part_type_alpha1(index,alpha[0])
		}
		return self
	}
		#region jsDoc
			/// @desc    It sets the particle renders to be additive (true) or not (false)
			/// @param   {Bool} _blend :  It sets the particle renders to be additive (true) or not (false)
		#endregion
	static set_blend		=	function(_blend)
	{
		blend	=	_blend
		part_type_blend(index,blend)
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
		part_type_speed(index,speed[0],speed[1],speed[2],speed[3])
		return self
	}
		#region jsDoc
			/// @desc    Sets the image for the particle as one of the predifined shapes from GameMaker.
			/// @param   {Constant.ParticleShape} _shape : The shape to use.
	#endregion
	static set_shape		=	function(_shape)
	{
		shape			=	_shape
		set_to_sprite	=	false
		part_type_shape(index,shape)
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
	static set_sprite		=	function(_sprite,_animate=false,_stretch=false,_random=true,_subimg=0)
	{
		sprite			=	[_sprite,_animate,_stretch,_random,_subimg]
		set_to_sprite	=	true
		part_type_sprite(index,_sprite,_animate,_stretch,_random)
		if _random == false
		{
			part_type_subimage(index,_subimg)
		}
		return self
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
		part_type_orientation(index,orient[0],orient[1],orient[2],orient[3],orient[4])
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
		part_type_gravity(index,gravity[0],gravity[1])
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
		part_type_direction(index,direction[0],direction[1],direction[2],direction[3])
		return self
	}
		#region jsDoc
			/// @desc    Sets a particle to be emitted every step.
			/// @param   {Real} _amount : The amount of particles emitted per step
			/// @param   {Struct.__pulse_particle_class} _step : The particle to emit every step
		#endregion
	static set_step_particle=	function(_amount,_step)
	{
		step_type	=	_step
		step_number	=	_amount
		if is_instanceof(step_type,pulse_particle)
		{
			part_type_step(index,step_number,step_type.index)
		}
		else
		{
			part_type_step(index,step_number,step_type)
		}

		return self
	}
		#region jsDoc
			/// @desc    Sets a particle to be emitted at death.
			/// @param   {Real} _amount : The amount of particles emitted
			/// @param   {Struct.__pulse_particle_class} _death_particle : The particle to emit
	#endregion
	static set_death_particle=	function(_amount,_death_particle)
	{
		if is_instanceof(_death_particle,pulse_particle)
		{
			if _death_particle.name == name
			{
				return self
			}
			
			part_type_death(index,_amount,_death_particle.index)
		}
		else
		{
			if _death_particle == index
			{
				return self
			}
			part_type_death(index,_amount,_death_particle)
		}
		
		death_type		=	_death_particle
		death_number	=	_amount
		return self
	}
		#region jsDoc
			/// @desc    Sets a particle to be emitted at death when Pulse detects a collision with the emitter. This creates a subparticle that mirrors the parent particle, but with a death particle.
			/// @param   {Real} _amount : The amount of particles emitted. Set to 0 to turn this property off.
			/// @param   {Struct.__pulse_particle_class} _death_particle : The particle to emit
	#endregion
	static set_death_on_collision=	function(_amount,_death_particle)
	{
		if _amount == 0
		{
			if subparticle != undefined
			{
				part_type_destroy(subparticle.index)
			}
			subparticle = undefined
			on_collision	= false
			
			return self
		}
		
		subparticle		= new __pulse_subparticle(self,_amount,_death_particle)
		on_collision	= true
		return self
	}
	
#endregion

	#region TRANSFORMATION HELPERS

/// @description			It changes Life, Speed and Gravity so the particle does the same trajectory but at a different time factor (faster or slower). The factor is relative to the current time factor of the particle.
/// @param {Real}			_factor : factor to which to change the time scale of the particle, relative to the current factor
		static scale_time		= function (_factor)
		{
			//If factor is one, nothing to be done here
			if _factor ==1 exit
			// Record the changes to be able to reset it later
			time_factor		*=_factor
			
			var _displ = gravity[0]*(life[0]*life[0])*.5

			set_speed(speed[0]*_factor,speed[1]*_factor,speed[2]*_factor,speed[3]*_factor)
			set_direction(direction[0],direction[1],direction[2]*_factor,direction[3]*_factor)
			set_orient(orient[0],orient[1],orient[2]*_factor,orient[3]*_factor)
			var _grav =( 2*_displ) / ( (life[0]*(1/_factor))*(life[0]*(1/_factor)))
			set_gravity(_grav,gravity[1])	

			//flip percentage
			_factor = 1/_factor
		
		// life is inversely proportional to speed and gravity.
			set_life(life[0]*_factor,life[1]*_factor)

			return self
		}
/// @description			It changes Life, Speed and Gravity so the particle does the same trajectory but at a different time factor (faster or slower). The factor is absolute in relation to the original properties of the particle
/// @param {Real}			_factor : factor to which to change the time scale of the particle in absolute terms	
		static scale_time_abs	= function(_factor)
		{
			if _factor == time_factor return
			
			var _absolute_factor = _factor
			_factor = _factor/time_factor
			
			scale_time(_factor)
			
			time_factor = _absolute_factor
		
			return self
		}
/// @description			It changes Life, Speed and Gravity so the particle does a similar trajectory but scaled in space. The factor is relative to the current scale factor of the particle.
/// @param {Real}			_factor : factor to which to change the space scale of the particle, relative to the current factor
/// @param {Bool}			_shrink_particle : Whether to change the particle's size (true) or only it's trajectory (false)
/// @param {Bool}			_gravity : Whether to change the particle's gravity
		static scale_space		= function (_factor,_shrink_particle, _gravity = true)
		{
			set_speed(speed[0]*_factor,speed[1]*_factor,speed[2]*_factor,speed[3]*_factor)
			set_direction(direction[0],direction[1],direction[2]*_factor,direction[3]*_factor)
			if _gravity 
			{
				set_gravity(gravity[0]*_factor,gravity[1])
			}
			
			if _shrink_particle
			{
				set_size([size[0]*_factor,size[1]*_factor],[size[2]*_factor,size[3]*_factor],[size[4]*_factor,size[5]*_factor],[size[6]*_factor,size[7]*_factor])
			}
			
			space_factor *= _factor

			return self
		}
/// @description			It changes Life, Speed and Gravity so the particle does a similar trajectory but scaled in space. The factor is absolute in relation to the original properties of the particle
/// @param {Real}			_factor : factor to which to change the space scale of the particle	in absolute terms	 	
/// @param {Bool}			_shrink_particle : Whether to change the particle's size (true) or only it's trajectory (false)
/// @param {Bool}			_gravity : Whether to change the particle's gravity
		static scale_space_abs	= function(_factor,_shrink_particle,_gravity = true)
		{
			if _factor == space_factor return
			
			var _absolute_factor = _factor
			_factor = _factor/space_factor
			
			scale_space(_factor,_shrink_particle,_gravity)
			
			space_factor = _absolute_factor
		
			return self
		}
/// @description			Change a particle's scale by using absolute pixel size instead of relative scale. 
/// It accepts arrays including different min, max,incr and wiggle for the x and y coord
/// @param {Real}			_min : Minimum size of the particle, in pixels, when created	
/// @param {Real}			_max : Maximum size of the particle, in pixels, when created
/// @param {Real}			_incr : +/- additive amount of pixels the particle can grow or shrink step to step	
/// @param {Real}			_wiggle : +/- amount of pixels the particle can vary step to step	
/// @param {Real}			_mode : 0 = average of width and height of sprite, 1 = use as reference the largest side, 2 = use the smallest side
		static set_size_abs		=	function(_min,_max,_incr=0,_wiggle=0,_mode=0)
		{
			var _size , _height = 0,_width = 0
			
			// If particle is using some of the default "shapes" default size to 64
			if !set_to_sprite
			{
				_height = 64
				_width = 64
			}
			else // Otherwise it is using a sprite
			{
				_height = sprite_get_height(sprite[0])
				_width = sprite_get_width(sprite[0])
			}
		
			if _height = _width // Sprite is a square
			{
				_size = _height
			}
			else if _mode == 0		// average of width and height
			{
				_size = mean(_height,_width)
			}
			else if _mode == 1	// take the largest of the sprite sides
			{
				_size = max(_height,_width)
			}
			else				// or take the smallest
			{
				_size = min(_height,_width)
			}

			if is_array(_min) or is_array(_max) or is_array(_incr) or is_array(_wiggle)
			{
				
				size[0]= is_array(_min) ? _min[0]/_width		: _min/_size
				size[1]= is_array(_min) ? _min[1]/_height		: _min/_size
				size[2]= is_array(_max) ? _max[0]/_width		: _max/_size
				size[3]= is_array(_max) ? _max[1]/_height		: _max/_size
				size[4]= is_array(_incr) ? _incr[0]/_width		: _incr/_size
				size[5]= is_array(_incr) ? _incr[1]/_height		: _incr/_size
				size[6]= is_array(_wiggle) ? _wiggle[0]/_width	: _wiggle/_size
				size[7]= is_array(_wiggle) ? _wiggle[1]/_height : _wiggle/_size

				part_type_size_x(index,size[0],size[2],size[4],size[6])
				part_type_size_y(index,size[1],size[3],size[5],size[7])
			
			}
			else
			{		
				_min	=	_min/_size
				_max	=	_max/_size
				_incr	=	_incr/_size
				_wiggle =	_wiggle/_size
				size	=[_min,_min,_max,_max,_incr,_incr,_wiggle,_wiggle]
				part_type_size(index,size[0],size[2],size[4],size[6])
			}

			return self
		}
/// @description			Choose a particle's final speed by changing its acceleration
/// @param {Real}			_final_speed : Final speed desired
/// @param {Real}			_mode : 0 = apply in relation to slowest,shortest lived particle 1 = fastest, long-lived. 2 =  average of both
/// @param {Real}			_steps : achieve the speed in X amount of steps from birth instead.

		static set_final_speed	=	function(_final_speed,_mode=0,_steps=undefined)
		{
			_steps = _steps<=0 ? undefined : _steps 
			var _accel;
			var _min_life			=	_steps ?? life[0]
			var _max_life			=	_steps ?? life[1] 
			
			switch(_mode)
			{
				case 0: // min
				{
					_accel = (_final_speed-speed[0])/_min_life
					break
				}
				case 1: //max
				{
					_accel = (_final_speed-speed[1])/_max_life
					
					break
				}
				default ://avg
					_accel = mean(((_final_speed-speed[0])/_min_life),((_final_speed-speed[1])/_max_life))
			}
			
			set_speed(speed[0],speed[1],_accel,speed[3])
			return self
		}
		
/// @description			Choose a particle's final size by changing its rate of change, measured in percentage. The first argument can be an array [width,height] or a Real. 
/// WARNING: This will change the behaviour of the particle to either separate or unified axis.
/// @param {Real}			_final_size : Final size desired. can be an array [width,height] or a Real
/// @param {Real}			_mode : 0 = apply in relation to smallest,shortest lived particle 1 = biggest, long-lived. 2 =  average of both
/// @param {Real}			_steps : achieve the size in X amount of steps from birth instead.
		static set_final_size	=	function(_final_size,_mode=0,_steps=undefined)
		{
			_steps = _steps<=0 ? undefined : _steps 
			var _incr_x , _incr_y ,
				_min_life			=	_steps ?? life[0],
				_max_life			=	_steps ?? life[1] ,
				_separate			=	is_array(_final_size) 
			
			switch(_mode)
			{
				case 0: // min
				{
					_incr_x = (_final_size-size[0])/_min_life
					_incr_y	= _separate ? (_final_size-size[1])/_min_life : _incr_x
					
					break
				}
				case 1: //max
				{
					_incr_x = (_final_size-size[2])/_max_life
					_incr_y	= _separate ? (_final_size-size[3])/_max_life : _incr_x
					
					break
				}
				default ://avg
					_incr_x = mean(((_final_size-size[0])/_min_life),((_final_size-size[2])/_max_life))
					_incr_y = _separate ? mean(((_final_size-size[1])/_min_life),((_final_size-size[3])/_max_life)) : _incr_x
			}
			
			if _separate
			{
				set_size([size[0],size[1]],[size[2],size[3]],[_incr_x,_incr_y],[size[6],size[7]])
			}
			else
			{
				set_size(size[0],size[2],_incr_x,size[6])
			}
			
			return self
		}
		
		/// @description			Choose a particle's total amount of spins by changing its rate of change, measured in degrees
/// @param {Real}			_revolutions : Total amount of revolutions (spins on its own axis)
/// @param {Bool}			_cw : Clockwise movement (true) or Counter-clockwise (false)
/// @param {Real}			_mode : 0 = apply in relation to shortest lived particle 1 = longest-lived. 2 =  average of both
/// @param {Real}			_steps : Revolutions over X amount of steps from birth instead of taking the whole life of the particle into account.

		static set_revolutions_over_life	=	function(_revolutions,_cw = false, _mode=0,_steps=undefined)
		{
			var _incr;
			var _min_life			=	_steps ?? life[0]
			var _max_life			=	_steps ?? life[1] 
			_steps = _steps<=0 ? undefined : _steps 
			switch(_mode)
			{
				case 0: // min
				{
					_incr = (_revolutions*360)/_min_life

					break
				}
				case 1: //max
				{
					_incr = (_revolutions*360)/_max_life
					
					break
				}
				default ://avg
					_incr = mean(((_revolutions*360)/_min_life),((_revolutions*360)/_max_life))
			}
			
			_incr = _cw ? -_incr : _incr
			
			set_orient(orient[0],orient[1],_incr,orient[3],orient[4])
			return self
		}


/// @description			Changes a particle's trajectory by changing its rate of change in degrees per step. 
/// @param {Real}			_arc : The arc described by the particle's trajectory before accounting for acceleration or gravity. 0 =  linear, 1 = full circle
/// @param {Real}			_mode : 0 = apply in relation to slowest,shortest lived particle 1 = fastest, long-lived. 2 =  average of both
/// @param {Real}			_steps : achieve the arc in X amount of steps from birth instead.

	static set_arc_trajectory	=	function(_arc,_mode=0,_steps=undefined)
	{
		_steps = _steps<=0 ? undefined : _steps 
		var _min_life			=	_steps ?? life[0]
		var _max_life			=	_steps ?? life[1] ,
		_rot;
			
		switch(_mode)
		{
			case 0: // min
			{
				_rot = (_arc*360)/_min_life
				break
			}
			case 1: //max
			{
				_rot = (_arc*360)/_max_life
					
				break
			}
			default ://avg
				_rot = mean(((_arc*360)/_min_life),((_arc*360)/_max_life))
		}
			
		set_direction(direction[0],direction[1],_rot,direction[3])
		return self
	}	
	#endregion 

	static	launch		=	function(_struct,x=0,y=0,_sys_index= undefined)
	{
		with(_struct)
		{
			_sys_index ??= part_system.index
			var _index = particle.index
			part_type_life(_index,life,life);
			part_type_speed(_index,speed,speed,particle.speed[2],particle.speed[3])
			part_type_direction(_index,dir,dir,particle.direction[2],particle.direction[3])
		
			if size !=undefined
			{
				part_type_size_x(_index,size[0],size[2],particle.size[4],particle.size[6])	
				part_type_size_y(_index,size[1],size[3],particle.size[5],particle.size[7])	
			}
			
			if orient !=undefined
			{
				part_type_orientation(_index,orient,orient,particle.orient[2],particle.orient[3],particle.orient[4])	
			}
			
			if frame != undefined
			{
				part_type_subimage(_index,frame)
			}
			
			if color_mode  !=undefined
			{
				if color_mode == PULSE_COLOR.A_TO_B_RGB or color_mode == PULSE_COLOR.COLOR_MAP
				{
					part_type_color_rgb(_index,r_h,r_h,g_s,g_s,b_v,b_v)
				} 
				else if color_mode == PULSE_COLOR.A_TO_B_HSV
				{
					part_type_color_hsv(_index,r_h,r_h,g_s,g_s,b_v,b_v)
				}
			}
			
			part_particles_create(_sys_index, x_origin+x,y_origin+y,_index, 1);
		}		
	}
	
	static destroy =  function()
	{
		part_type_destroy(index)
		if subparticle != undefined 
		{
			part_type_destroy(subparticle.index)
		}
	}
	
	reset()
}

/// @description			Private constructor used to create sub-particles, which are particles that share most properties with another particle to simulate more dynamic particles.
/// @return {Struct}
function __pulse_subparticle		(_parent,_number,_death_particle) : __pulse_particle_class("child") constructor
{
	parent	= _parent
	index			=	part_type_create();

	death_type		=	_death_particle
	death_number	=	_number
/// @description			It updates the subparticle's properties to match the parent's properties.
	static update = function()
	{
		size			=	parent.size
		scale			=	parent.scale
		life			=	parent.life
		color			=	parent.color
		color_mode		=	parent.color_mode
		alpha			=	parent.alpha
		blend			=	parent.blend
		speed			=	parent.speed
		shape			=	parent.shape

		sprite			=	parent.sprite

		orient			=	parent.orient
		gravity			=	parent.gravity
		direction		=	parent.direction

		set_to_sprite	=	parent.set_to_sprite
		step_type		=	parent.step_type
		step_number		=	parent.step_number
		subparticle		=	undefined
		
		reset()
	}
	
	update()
}

/// @description			Private Particle Class used as a base for all other particles.
/// @param {String}			_name : Name of the particle.
function __pulse_particle_class		(_name) constructor
{
	pulse_ver		=	_PULSE_VERSION
	name			=	string(_name)
	index			=	undefined
	type			=	0;
	size			=	__PULSE_DEFAULT_PART_SIZE
	scale			=	__PULSE_DEFAULT_PART_SCALE
	life			=	__PULSE_DEFAULT_PART_LIFE
	color			=	__PULSE_DEFAULT_PART_COLOR
	color_mode		=	__PULSE_DEFAULT_PART_COLOR_MODE
	alpha			=	__PULSE_DEFAULT_PART_ALPHA
	blend			=	__PULSE_DEFAULT_PART_BLEND
	speed			=	__PULSE_DEFAULT_PART_SPEED
	shape			=	__PULSE_DEFAULT_PART_SHAPE
	sprite			=	undefined
	orient			=	__PULSE_DEFAULT_PART_ORIENT
	gravity			=	__PULSE_DEFAULT_PART_GRAVITY
	direction		=	__PULSE_DEFAULT_PART_DIRECTION
	set_to_sprite	=	false
	//
	death_type		=	undefined
	death_number	=	1
	//
	subparticle		=	undefined
	on_collision	= false
	step_type		=	undefined
	step_number		=	1
	//
	time_factor		=	1
	space_factor	=	1
	altered_acceleration = 0

	
	
	/// @description		Sets the particle's properties to the ones saved by Pulse
	static reset	=	function()
	{
		part_type_scale(index,scale[0],scale[1]);
		
		if size[0]!=size[1] or size[2]!=size[3] or size[4]!=size[5] or size[6]!=size[7]
		{
			part_type_size_x(index,size[0],size[2],size[4],size[6])
			part_type_size_y(index,size[1],size[3],size[5],size[7])
		}
		else
		{
			part_type_size(index,size[0],size[2],size[4],size[6])
		}
		
		part_type_life(index,life[0],life[1])
		
		
		switch(color_mode)
		{
		
			case PULSE_COLOR_PARTICLE.COLOR :
			{
					var _color = array_length(color)
					if _color==3
					{
						part_type_color3(index,color[0],color[1],color[2])
					} else if _color==2
					{
						part_type_color2(index,color[0],color[1])
					} else
					{
						part_type_color1(index,color[0])
					}
				break
			}
			case PULSE_COLOR_PARTICLE.RGB :
			{
				if is_array(color[0]) && is_array(color[1]) && is_array(color[2])
				{
					part_type_color_rgb(index,color[0][0],color[0][1],color[1][0],color[1][1],color[2][0],color[2][1])
				}
				else
				{
					part_type_color_rgb(index,color[0],color[0],color[1],color[1],color[2],color[2])
				}
			break;
			}
			case PULSE_COLOR_PARTICLE.HSV :
			{
				if is_array(color[0]) && is_array(color[1]) && is_array(color[2])
				{
					part_type_color_hsv(index,color[0][0],color[0][1],color[1][0],color[1][1],color[2][0],color[2][1])
				}
				else
				{
					part_type_color_hsv(index,color[0],color[0],color[1],color[1],color[2],color[2])
				}
			break;
			}
				case PULSE_COLOR_PARTICLE.MIX :
			{
				part_type_color_mix(index,color[0],color[1])
				break;
			}
			
		
		}

		var _alpha = array_length(alpha)
		if _alpha==3
		{
			part_type_alpha3(index,alpha[0],alpha[1],alpha[2])
		} else if _alpha==2
		{
			part_type_alpha2(index,alpha[0],alpha[1])
		} else
		{
			part_type_alpha1(index,alpha[0])
		}
				
		part_type_blend(index,blend)
		part_type_speed(index,speed[0],speed[1],speed[2],speed[3])
		if !set_to_sprite
		{
			part_type_shape(index,shape)
		}
		else
		{
			part_type_sprite(index,sprite[0],sprite[1],sprite[2],sprite[3])
		}
		part_type_orientation(index,orient[0],orient[1],orient[2],orient[3],orient[4])
		part_type_gravity(index,gravity[0],gravity[1])
		part_type_direction(index,direction[0],direction[1],direction[2],direction[3])
		
		if step_type != undefined 
		{
			if is_instanceof(step_type,__pulse_particle_class)
			{
				part_type_step(index,step_number,step_type.index)
			}
			else
			{
				part_type_step(index,step_number,step_type)
			}
		}
		if death_type != undefined 
		{
			if is_instanceof(death_type,__pulse_particle_class)
			{
				part_type_death(index,death_number,death_type.index)
			}
			else
			{
				part_type_death(index,death_number,death_type)
			}
		}
		if subparticle != undefined
		{
			subparticle.update()
		}
	
	}
}


				


