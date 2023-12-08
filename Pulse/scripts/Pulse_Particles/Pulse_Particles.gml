global.pulse =
{
	systems		:	{},
	part_types	:	{},
	emitters	:	{},
	particle_factor:1,
}

function __pulse_system				(_name,_layer= -1,_persistent=true) constructor
{
	name = string(_name)
	
	if layer_exists(_layer)
	{
		if is_string(_layer)
		{
			layer	=	layer_get_id(_layer)
			depth	=	layer_get_depth(layer);
		}
		else
		{
			layer	=	_layer
			depth	=	layer_get_depth(layer);
		}
			index	=	part_system_create_layer(layer,_persistent);
	}
	else 
	{
		index			=	part_system_create();
		layer			=	-1
		depth			=	0;
	}
	
	threshold		=	0

	draw			=	true;
	draw_oldtonew	=	true;
	update			=	true;
	x				=	0;
	y				=	0;
	samples			=	1;
	persistent		=	_persistent;
	factor			=	1;
	
	// wake-sleep rules
	
	wake_on_emit		= true
	sleep_when_empty	= true
	
	static set_depth				= function(_depth=depth)
	{
		depth	=	_depth;
		layer = -1
		
		if index == -1 
		{
			__pulse_show_debug_message("PULSE WARNING: System is asleep")
			return self
		}
		part_system_depth(index, depth);

		return self
	}
	
	static set_update				= function(_bool)
	{
		update	=	_bool;
		
		if index == -1 
		{
			__pulse_show_debug_message("PULSE WARNING: System is asleep")
			return self
		}
		part_system_automatic_update(index,update);
		
		return self
	}
	
	static set_draw					= function(_bool)
	{
		
		draw	=	_bool;
		if index == -1 
		{
			__pulse_show_debug_message("PULSE WARNING: System is asleep")
			return self
		}
		
		part_system_automatic_draw(index,draw);
		
		return self
	}
	
	static set_layer				= function(_layer)
	{
		layer	=	_layer;
		
		if index == -1 
		{
			__pulse_show_debug_message("PULSE WARNING: System is asleep")
			return self
		}
		part_system_layer(index,layer);
		
		return self
	}
	
	static set_draw_oldtonew		= function(_bool)
	{
		draw_oldtonew	=	_bool;
		if index == -1 
		{
			__pulse_show_debug_message("PULSE WARNING: System is asleep")
			return self
		}
		part_system_draw_order(index,draw_oldtonew);
		
		return self
	}
	
	static set_position				= function(_x,_y)
	{
		x				=	_x;
		y				=	_y;
		if index == -1 
		{
			__pulse_show_debug_message("PULSE WARNING: System is asleep")
			return self
		}
		part_system_position(index,x,y);
		
		return self
	}

	static set_super_sampling		= function(_active, _samples)
	{
		if _active
		{
			set_update(false)
			samples = _samples>1 ? floor(_samples) : 1
		}
		else
		{
			samples = 1
		}
	}
	
	static reset					= function()
	{
		if index == -1 
		{
			__pulse_show_debug_message("PULSE WARNING: System is asleep")
			return self
		}
		if layer != -1
		{
			part_system_layer(index,layer);
		}
		else
		{
			part_system_depth(index, depth);
		}
		part_system_automatic_update(index,update);
		part_system_automatic_draw(index,draw);
		part_system_draw_order(index,draw_oldtonew);
		part_system_position(index,x,y);
	}
	
	static update_system			= function(_resample=1)
	{
		if index == -1 
		{
			__pulse_show_debug_message("PULSE WARNING: System is asleep")
			exit
		}
		
		if samples > 1 && !update
		{
			//less than 1 numbers will "slow down time", greater than 1 will "accelerate time"
			var new_sample = ceil(samples*abs(_resample))
			
			repeat(new_sample)
			{
				part_system_update(index)
			}
		}
		else
		{
			part_system_update(index)
		}
	}
	
	static draw_it						= function(_blend = bm_normal)
	{
		if index == -1 
		{
			__pulse_show_debug_message("PULSE WARNING: System is asleep")
			exit
		}
		
		part_system_drawit(index)	
	}
	
	//RESOURCE MANAGEMENT
	
	static make_asleep				= function()
	{
		if index == -1 
		{
			__pulse_show_debug_message("PULSE WARNING: System is already asleep")
		}
		part_system_destroy(index)
		index = -1
	}
	
	static make_awake				= function()
	{
		if index != -1 
		{
			__pulse_show_debug_message("PULSE WARNING: System is already awake")
		}
		
		if layer != -1
		{
			index	=	part_system_create_layer(layer,_persistent);
		}
		else
		{
			index	=	part_system_create()
		}
		reset()
	}
	
	
	count			=	time_source_create(time_source_game,__PULSE_DEFAULT_COUNT_TIMER,time_source_units_frames,function()
		{
				if index != -1 && threshold > 0
				{
					var _current_particles =  part_particles_count(index)
								
					// if there are more particles than desired threshold
					if _current_particles-threshold > threshold*.1
					{
						factor *= (threshold/_current_particles)
					} 
					else if threshold-_current_particles > threshold*.1 && factor<1
					{
						factor /= (_current_particles/threshold)
						factor = min(1,factor)
					}
					else if _current_particles == 0
					{
						time_source_stop(count)
						if sleep_when_empty { make_asleep() }
					}
				}
				else
				{
					time_source_stop(count)
				}
			},[],-1)
}

function __pulse_particle			(_name) constructor
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
	death_type		=	undefined
	death_number	=	1
	step_type		=	undefined
	step_number		=	1
	prelaunch		= function(_struct){}
	time_factor		=	1
	scale_factor	=	1
	altered_acceleration = 0

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
		part_type_step(index,step_number,step_type)
		return self
	}
	static set_death_particle=	function(_number,_death)
	{
		
		death_type		=	_death
		death_number	=	_number
		part_type_death(index,death_number,death_type)
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
		
		if step_type != undefined part_type_step(index,step_number,step_type)
		if death_type != undefined part_type_death(index,death_number,death_type)
	
	}
	reset()
	
}

function __pulse_instance_particle	(_object) constructor
{
	name			=	object_get_name(_object)
	index			=	_object
	size			=	__PULSE_DEFAULT_PART_SIZE
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

/// @description			Use this to create a new force to apply within an emitter. Forces can be linear or radial, range of influence is infinite by default.
/// @param {Real}			_x : X coordinate relative to the emitter
/// @param {Real}			_y : Y coordinate relative to the emitter
/// @param {Real}			_direction	: Which layer to place the system
/// @param {Real}			_type	: Can be either PULSE_FORCE.DIRECTION or PULSE_FORCE.RADIAL
/// @param {Real}			_weight	: Amount that this will influence the particle, from 0 to 1.
/// @return {Struct}
function pulse_force				(_x,_y,_direction,_type = PULSE_FORCE.DIRECTION,_weight = 1, _force = 1) constructor
{
	x			= _x
	y			= _y
	type		= _type
	range		= PULSE_FORCE.RANGE_INFINITE
	direction	= _direction
	weight		= _weight
	vec			= [0,0];
	vec[0]		= lengthdir_x(_force,direction)
	vec[1]		= lengthdir_y(_force,direction)
	local		= true
							
	static set_range_directional = function(_north=-1,_south=-1,_east=-1,_west=-1)
	{
		if (_north==-1 &&_south==-1 &&_east==-1 &&_west==-1) 
		{
			range		= PULSE_FORCE.RANGE_INFINITE
			return self
		}
		north	= _north
		south	= _south
		east	= _east
		west	= _west
		
		range		= PULSE_FORCE.RANGE_DIRECTIONAL
		return self
		
	}
	static set_range_radial = function (_radius)
	{
		radius		= _radius
		range		= PULSE_FORCE.RANGE_RADIAL
		return self
	}
	
}

	
/// @description			Use this to create a new particle system. It returns a reference to the struct by default, but it will return the particle index if the second argument is true.
/// @param {String}			name : Name your particle or leave empty to use the default name
/// @param {Bool}			return_index	: Whether to return the particle index or not (false by default)
/// @param {ID.Layer}		_layer	: Which layer to place the system
/// @param {Bool}			_persistent	: Whether to return the particle index or not (false by default)
/// @return {Struct}
function pulse_make_system			(_name=__PULSE_DEFAULT_SYS_NAME,_return_index=false,_layer= undefined,_persistent=false)
{
	if _name		==__PULSE_DEFAULT_SYS_NAME
	{
		var l		=	struct_names_count(global.pulse.systems)		
		_name		=	$"{_name}_{l}";		
	}

	if pulse_exists_system(_name) <= 0 
	{
		global.pulse.systems[$_name] = new __pulse_system(_name,_layer,_persistent);
		__pulse_show_debug_message($"PULSE SUCCESS: Created system by the name {_name}");
	}
	
		if _return_index
		{
			return global.pulse.systems[$_name].index
		}
		else
		{
			return global.pulse.systems[$_name]
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

/// @function				pulse_convert_particles
/// @description			   
///							Convert particle assets made with the Particle Editor into Pulse Particles. The emitter configuration is not copied.
///							Particles are named after the emitter they are on.
/// @param {Asset.GMParticleSystem}	part_system : The particle system asset you wish to convert.
function pulse_convert_particles	(part_system)
{
	var struct = particle_get_info(part_system)
	var length = array_length(struct.emitters)
	
	if length == 0
	{
		exit
	}
	
	var l=0
	
	repeat (length)
	{
		var target	=	pulse_make_particle(struct.emitters[l].name,false)
		var src	=	struct.emitters[l].parttype
		target.set_size([src.size_xmin,src.size_ymin],[src.size_xmax,src.size_ymax],[src.size_xincr,src.size_yincr],[src.size_xwiggle,src.size_ywiggle])
		target.set_scale(src.xscale,src.yscale)
		target.set_life(src.life_min,src.life_max)
		if src.death_type != -1
		{
			target.set_death_particle(src.death_number,src.death_type)
		}
		if src.step_type != -1
		{
			target.set_step_particle(src.step_number,src.step_type)
		}
		target.set_speed(src.speed_min,src.speed_max,src.speed_incr,src.speed_wiggle)
		target.set_direction(src.dir_min,src.dir_max,src.dir_incr,src.dir_wiggle)
		target.set_gravity(src.grav_amount,src.grav_dir)
		target.set_orient(src.ang_min,src.ang_max,src.ang_incr,src.ang_wiggle,src.ang_relative)
		target.set_color(src.color1,src.color2,src.color3)
		target.set_alpha(src.alpha1,src.alpha2,src.alpha3)
		target.set_blend(src.additive)
		
		if src.sprite == -1
		{
			target.set_shape(src.shape)
		}
		else
		{
			target.set_sprite(src.sprite,src.animate,src.stretch,src.random,src.frame)
		}
	l++
	}
}
