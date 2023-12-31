global.pulse =
{
	systems		:	{},
	part_types	:	{},
	emitters	:	{},
	particle_factor:1,
}


function __pulse_particle			(_name) : __pulse_particle_class(_name) constructor
{
	

	#region //SET BASIC PROPERTIES
		#region jsDoc
		/// @desc    sets the size of the pulse particle
		///          
		/// @param   {Real} _min : Minimum size
		/// @param   {Real} _max : Maximum size
		/// @param   {Real} _incr : Size Increment
		/// @param   {Real} _wiggle : Size wiggle range (frequency is fixed)
		#endregion
	static set_size			=	function(_min,_max,_incr=0,_wiggle=0)
	{
		if is_array(_min) or is_array(_max) or is_array(_incr) or is_array(_wiggle)
		{
			size[0]= is_array(_min) ? _min[0] : _min
			size[1]= is_array(_min) ? _min[1] : _min
			size[2]= is_array(_max) ? _max[0] : _max
			size[3]= is_array(_max) ? _max[1] : _max
			size[4]= is_array(_incr) ? _incr[0] : _incr
			size[5]= is_array(_incr) ? _incr[1] : _incr
			size[6]= is_array(_wiggle) ? _wiggle[0] : _wiggle
			size[7]= is_array(_wiggle) ? _wiggle[1] : _wiggle

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
	static set_scale		=	function(scalex,_scaley)
	{
		scale			= [scalex,_scaley]
		part_type_scale(index,scale[0],scale[1]);
		return self
	}
	static set_life			=	function(_min,_max)
	{
		life	=[_min,_max]
		part_type_life(index,life[0],life[1])
		return self
	}
	static set_color		=	function(color1,color2=-1,color3=-1,_mode = __PULSE_COLOR_MODE.COLOR)
	{
		if color3 != -1
		{
			color=[color1,color2,color3]
			
			switch(_mode)
			{
				case __PULSE_COLOR_MODE.COLOR :
					part_type_color3(index,color[0],color[1],color[2])
				break
				case __PULSE_COLOR_MODE.RGB :
					if is_array(color1) && is_array(color2) && is_array(color3)
					{
						part_type_color_rgb(index,color[0][0],color[0][1],color[1][0],color[1][1],color[2][0],color[2][1])
					}
					else
					{
						part_type_color_rgb(index,color[0],color[0],color[1],color[1],color[2],color[2])
					}
				break
				case __PULSE_COLOR_MODE.HSV :
					if is_array(color1) && is_array(color2) && is_array(color3)
					{
						part_type_color_hsv(index,color[0][0],color[0][1],color[1][0],color[1][1],color[2][0],color[2][1])
					}
					else
					{
						part_type_color_hsv(index,color[0],color[0],color[1],color[1],color[2],color[2])
					}
				break
			}
		}
		else if color2 != -1
		{
			color=[color1,color2]
			
			if _mode == __PULSE_COLOR_MODE.COLOR
			{
				part_type_color2(index,color[0],color[1])
			}
			else if _mode == __PULSE_COLOR_MODE.MIX
			{
				part_type_color_mix(index,color[0],color[1])
			}
			
		}
		else
		{
			_mode = __PULSE_COLOR_MODE.COLOR
			color=[color1]
			part_type_color1(index,color[0])
		}
		color_mode		= _mode
		return self
	}
	static set_alpha		=	function(alpha1,alpha2=-1,alpha3=-1)
	{
		if alpha3 != -1
		{
			alpha=[alpha1,alpha2,alpha3]	
			part_type_alpha3(index,alpha[0],alpha[1],alpha[2])
		}
		else if alpha2 != -1
		{
			alpha=[alpha1,alpha2]
			part_type_alpha2(index,alpha[0],alpha[1])
		}
		else
		{
			alpha=[alpha1]
			part_type_alpha1(index,alpha[0])
		}
		return self
	}
	static set_blend		=	function(_blend)
	{
		blend	=	_blend
		part_type_blend(index,blend)
		return self
	}
	static set_speed		=	function(_min,_max,_incr=0,_wiggle=0)
	{
		speed	=[_min,_max,_incr,_wiggle]
		part_type_speed(index,speed[0],speed[1],speed[2],speed[3])
		return self
	}
	static set_shape		=	function(_shape)
	{
		shape			=	_shape
		set_to_sprite	=	false
		part_type_shape(index,shape)
		return self
	}
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
	static set_orient		=	function(_min,_max,_incr=0,_wiggle=0,_relative=true)
	{
		orient	=[_min,_max,_incr,_wiggle,_relative]
		part_type_orientation(index,orient[0],orient[1],orient[2],orient[3],orient[4])
		return self
	}
	static set_gravity		=	function(_amount,_direction)
	{
		gravity	=[_amount,_direction]
		part_type_gravity(index,gravity[0],gravity[1])
		return self
	}
	static set_direction	=	function(_min,_max,_incr=0,_wiggle=0)
	{
		direction	=[_min,_max,_incr,_wiggle]
		part_type_direction(index,direction[0],direction[1],direction[2],direction[3])
		return self
	}
	static set_step_particle=	function(_number,_step)
	{
		step_type	=	_step
		step_number	=	_number
		if is_instanceof(step_type,__pulse_particle)
		{
			part_type_step(index,step_number,step_type.index)
		}
		else
		{
			part_type_step(index,step_number,step_type)
		}

		return self
	}
	static set_death_particle=	function(_amount,_death_particle)
	{
		death_type		=	_death_particle
		death_number	=	_amount
		if is_instanceof(death_type,__pulse_particle)
		{
			part_type_death(index,death_number,death_type.index)
		}
		else
		{
			part_type_death(index,death_number,death_type)
		}
		return self
	}
	static set_death_on_collision=	function(_amount,_death_particle)
	{
		subparticle = new __pulse_subparticle(self,_amount,_death_particle)
		on_collision	= true
		return self
	}
	
#endregion
/*
	static add_dynamic = function(_condition_property,_min,_max,_property)
	{
		var struct = {}
		struct.condition = function(_condition_property,_min,_max)
		{
			if _condition_property> _min && _condition_property< _max
			{return true}
			else
			{return false}			
		}
		struct.property =  _property
		array_push(_dynamics,struct)
		return array_last(_dynamics)
	}
*/
	#region TRANSFORMATION HELPERS

/// @description			It changes Life, Speed and Gravity so the particle does the same trajectory but at a different time factor (faster or slower)
/// @param {Real}			_factor : factor to which to change the time scale of the particle, relative to the current factor
		static scale_time		= function (_factor)
		{
			//If factor is one, nothing to be done here
			if _factor ==1 exit
		
			// Record the changes to be able to reset it later
			time_factor		=	time_factor*_factor
			
			set_life(life[0]*_factor,life[1]*_factor)

			//flip percentage
			_factor = 1/_factor
		
			set_speed(speed[0]*_factor,speed[1]*_factor,speed[2]*_factor,speed[3]*_factor)
			set_gravity(gravity[0]*_factor,gravity[1])
			

		
			return self
		}
/// @description			It changes Life, Speed and Gravity so the particle does the same trajectory but at a different time factor (faster or slower)
/// @param {Real}			_factor : factor to which to change the time scale of the particle in absolute terms	
		static scale_time_abs	= function(_factor)
		{
			var _absolute_factor = _factor
			_factor = _factor/time_factor
			
			scale_time(_factor)
			
			time_factor = _absolute_factor
		
			return self
		}
/// @description			It changes Life, Speed and Gravity so the particle does the same trajectory but at a different time factor (faster or slower)
/// @param {Real}			_factor : factor to which to change the time scale of the particle		
		static scale_space		= function (_factor,_shrink_particle)
		{
		
			set_speed(speed[0]*_factor,speed[1]*_factor,speed[2]*_factor,speed[3]*_factor)
			set_gravity(gravity[0]*_factor,gravity[1])
			if _shrink_particle
			{
				set_size([size[0]*_factor,size[1]*_factor],[size[2]*_factor,size[3]*_factor],[size[4]*_factor,size[5]*_factor],[size[6]*_factor,size[7]*_factor])
			}
		
			return self
		}
/// @description			It changes Life, Speed and Gravity so the particle does the same trajectory but at a different time factor (faster or slower)
/// @param {Real}			_factor : factor to which to change the time scale of the particle		
		static scale_space_abs	= function(_factor,_shrink_particle)
		{
			var _absolute_factor = _factor
			_factor = _factor/space_factor
			
			scale_space(_factor,_shrink_particle)
			
			space_factor = _absolute_factor
		
			return self
		}
/// @description			Change a particle's scale by using absolute pixel size instead of relative scale
/// @param {Real}			_min : minimum size of the particle, in pixels, when created	
/// @param {Real}			_max : maximum size of the particle, in pixels, when created
/// @param {Real}			_incr : +/- additive amount of pixels the particle can grow or shrink step to step	
/// @param {Real}			_wiggle : +/- amount of pixels the particle can vary step to step	
/// @param {Real}			_mode : 0 = average of width and height of sprite, 1 = use as reference the largest side, 2 = use the smallest side
		static set_size_abs		=	function(_min,_max,_incr=0,_wiggle=0,_mode=0)
		{
			var _size
			
			if !set_to_sprite
			{
				return self
			}
		
			if _mode == 0		// average of width and height
			{
				var _size = mean(sprite_get_height(sprite[0]),sprite_get_width(sprite[0]))
			}
			else if _mode == 1	// take the largest of the sprite sides
			{
				var _size = max(sprite_get_height(sprite[0]),sprite_get_width(sprite[0]))
			}
			else				// or take the smallest
			{
				var _size = min(sprite_get_height(sprite[0]),sprite_get_width(sprite[0]))
			}

			if is_array(_min) or is_array(_max) or is_array(_incr) or is_array(_wiggle)
			{
				var _height	=	sprite_get_height(sprite[0])
				var _width	=	sprite_get_width(sprite[0])
				
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
		
		static change_current_speed	=	function(_final_speed, _steps ,_mode=0)
		{
			var _min_accel			=	speed[2]*life[0]
			var _max_accel			=	speed[2]*life[1]
			var _min_final_speed	=	speed[0]+min(_min_accel,_max_accel) // the slowest a particle can go
			var _max_final_speed	=	speed[1]+max(_min_accel,_max_accel)	// the fastest a particle can go
			
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
				default: //avg
					_accel = mean(((_final_speed-speed[0])/_min_life),((_final_speed-speed[1])/_max_life))
			}
			
			set_speed(speed[0],speed[1],_accel,speed[3])
		}
		
	#endregion 

	
	reset()
	
}

function __pulse_subparticle		(_parent,_number,_death_particle) : __pulse_particle_class("child") constructor
{
	parent	= _parent
	index			=	part_type_create();

	death_type		=	_death_particle
	death_number	=	_number

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

function __pulse_instance_particle	(_object,_name) constructor
{
	name			=	string(_name)
	index			=	_object
	size			=	[1,1,1,1,0,0,0,0]
	scale			=	__PULSE_DEFAULT_PART_SCALE
	life			=	__PULSE_DEFAULT_PART_LIFE
	color			=	__PULSE_DEFAULT_PART_COLOR
	color_mode		=	__PULSE_DEFAULT_PART_COLOR_MODE
	alpha			=	__PULSE_DEFAULT_PART_ALPHA
	blend			=	__PULSE_DEFAULT_PART_BLEND
	speed			=	__PULSE_DEFAULT_PART_SPEED
	sprite			=	object_get_sprite(_object)
	orient			=	__PULSE_DEFAULT_PART_ORIENT
	gravity			=	__PULSE_DEFAULT_PART_GRAVITY
	direction		=	__PULSE_DEFAULT_PART_DIRECTION
	death_type		=	undefined
	death_number	=	undefined
	step_type		=	undefined
	step_number	=	undefined
	
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
		if _struct._size == undefined
		{
			_struct._size			=	size
		}
		if _struct._orient == undefined
		{
			_struct._orient			=	orient
		}
		_struct._scale			=	scale
		_struct.color			=	color
		_struct._alpha			=	alpha
		_struct._blend			=	blend
		//_struct._sprite			=	_sprite

		_struct._gravity		=	gravity
		_struct._death_type		=	death_type
		_struct._death_number	=	death_number
		_struct._step_type		=	step_type
		_struct._step_number	=	step_number

		if _struct.part_system.layer == -1
		{
			instance_create_depth(_struct.x_origin,_struct.y_origin,_struct.part_system.depth,_struct.particle_index,_struct)
		}
		else
		{
			instance_create_layer(_struct.x_origin,_struct.y_origin,_struct.part_system.layer,_struct.particle_index,_struct)	
		}
	}
}

function __pulse_particle_class		(_name) constructor
{
	name			=	_name
	index			=	part_type_create();
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
	scale_factor	=	1
	altered_acceleration = 0
	subparticle = undefined
	
	prelaunch		= function(_struct){}
	
	static reset	=	function()
	{
		time_factor		=	1
		scale_factor	=	1
		
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
		
			case __PULSE_COLOR_MODE.COLOR :
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
			case __PULSE_COLOR_MODE.RGB :
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
			case __PULSE_COLOR_MODE.HSV :
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
			if is_instanceof(step_type,__pulse_particle)
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
			if is_instanceof(death_type,__pulse_particle)
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

/// @description			Use this to create a new particle. It returns a reference to the struct by default, but it will return the particle index if the last argument is true.
/// @param {String}			name : Name your particle or leave empty to use the default name
/// @param {Bool}			return_index	: Whether to return the particle index or not (false by default)
/// @return {Struct}
function pulse_make_particle		(_name=__PULSE_DEFAULT_PART_NAME,_return_index=false)
{
	// If using the default name, count particles and rename so there are no repeated entries
	
	if _name		==__PULSE_DEFAULT_PART_NAME
	{
		var l		=	struct_names_count(global.pulse.part_types)		
		_name		=	$"{_name}_{l}";		
	}
	
	if pulse_exists_particle(_name) <= 0 // If it doesnt exist, create it
	{
		global.pulse.part_types[$_name] = new __pulse_particle(_name)
		__pulse_show_debug_message($"PULSE SUCCESS: Created particle by the name {_name}");
	}
	
	if _return_index
	{
		return global.pulse.part_types[$_name].index
	}
	else
	{
		return global.pulse.part_types[$_name]
	}
}

				
/// @description			Use this to create a new Instance particle. It returns a reference to the struct
/// @param {Asset.GMObject}	object : Object to make instances of.
/// @param {String}			name : Name your particle or leave empty to use the default name
/// @param {Real}			depth: Depth in which the instance will be created
/// @return {Struct}
function pulse_make_instance_particle(_object,_name=__PULSE_DEFAULT_PART_NAME)
{
	// If using the default name, count particles and rename so there are no repeated entries
	if _name		==__PULSE_DEFAULT_PART_NAME
	{
		var l		=	struct_names_count(global.pulse.part_types)		
		_name		=	$"{_name}_{l}";		
	}
	
	global.pulse.part_types[$_name] = new __pulse_instance_particle(_object)
	__pulse_show_debug_message($"PULSE SUCCESS: Created particle by the name {_name}");
	
	return global.pulse.part_types[$_name]
}


