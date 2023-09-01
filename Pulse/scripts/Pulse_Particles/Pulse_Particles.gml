global.pulse =
{
	systems		:	{},
	part_types	:	{},
	emitters	:	{},
	particle_factor:1,
}

function __pulse_system				(_layer= -1,_persistent=true) constructor
{
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
	
	treshold		=	0
	count			=	time_source_create(time_source_game,__PULSE_DEFAULT_COUNT_TIMER,time_source_units_frames,function()
						{
							if index != -1 && treshold > 0
							{
								var _current_particles =  part_particles_count(index)
								
								// if there are more particles than desired treshold
								if _current_particles-treshold > treshold*.1
								{
									factor *= (treshold/_current_particles)
								} 
								else if treshold-_current_particles > treshold*.1
								{
									factor /= (_current_particles/treshold)
								}
								else if _current_particles == 0
								{
									time_source_stop(count)
								}
							}
							else
							{
								time_source_stop(count)
							}
						},[],-1)
	draw			=	true;
	draw_oldtonew	=	true;
	update			=	true;
	x				=	0;
	y				=	0;
	samples			=	1;
	persistent		=	_persistent;
	factor			=	1;
	
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
			return self
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
	
	//RESOURCE MANAGEMENT
	
	static make_sleep				= function()
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
	
}

function __pulse_particle			() constructor
{
	_index			=	part_type_create();
	_size			=	__PULSE_DEFAULT_PART_SIZE
	_scale			=	__PULSE_DEFAULT_PART_SCALE
	_life			=	__PULSE_DEFAULT_PART_LIFE
	_color			=	__PULSE_DEFAULT_PART_COLOR
	_color_mode		=	__PULSE_DEFAULT_PART_COLOR_MODE
	_alpha			=	__PULSE_DEFAULT_PART_ALPHA
	_blend			=	__PULSE_DEFAULT_PART_BLEND
	_speed			=	__PULSE_DEFAULT_PART_SPEED
	_shape			=	__PULSE_DEFAULT_PART_SHAPE
	_sprite			=	undefined
	_orient			=	__PULSE_DEFAULT_PART_ORIENT
	_gravity		=	__PULSE_DEFAULT_PART_GRAVITY
	_direction		=	__PULSE_DEFAULT_PART_DIRECTION
	_set_to_sprite	=	false
	_death_type		=	undefined
	_death_number	=	1
	_step_type		=	undefined
	_step_number	=	1
	_dynamics		=	[]
	time_factor		=	1
	scale_factor	=	1
	

	#region //SET BASIC PROPERTIES
		#region jsDoc
		/// @func    set_size()
		/// @desc    sets the size of the pulse particle
		///          
		/// @context    __pulse_particle
		/// @param   {Real} _min : Minimum size
		/// @param   {Real} _max : Maximum size
		/// @param   {Real} _incr : Size Increment
		/// @param   {Real} _wiggle : Size wiggle range (frequency is fixed)
		/// @returns {Struct}
		#endregion
	static set_size			=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_size	=[_min,_max,_incr,_wiggle]
		part_type_size(_index,_size[0],_size[1],_size[2],_size[3])
		return self
	}
	static set_scale		=	function(scalex,_scaley)
	{
		_scale			= [scalex,_scaley]
		part_type_scale(_index,_scale[0],_scale[1]);
		return self
	}
	static set_life			=	function(_min,_max)
	{
		_life	=[_min,_max]
		part_type_life(_index,_life[0],_life[1])
		return self
	}
	static set_color		=	function(color1,color2=-1,color3=-1)
	{
		if color3 != -1
		{
			_color=[color1,color2,color3]	
			part_type_color3(_index,_color[0],_color[1],_color[2])
		}
		else if color2 != -1
		{
			_color=[color1,color2]
			part_type_color2(_index,_color[0],_color[1])
		}
		else
		{
			_color=[color1]
			part_type_color1(_index,_color[0])
		}
		_color_mode		= __PULSE_COLOR_MODE.COLOR
		return self
	}
	static set_alpha		=	function(alpha1,alpha2=-1,alpha3=-1)
	{
		if alpha3 != -1
		{
			_alpha=[alpha1,alpha2,alpha3]	
			part_type_alpha3(_index,_alpha[0],_alpha[1],_alpha[2])
		}
		else if alpha2 != -1
		{
			_alpha=[alpha1,alpha2]
			part_type_alpha2(_index,_alpha[0],_alpha[1])
		}
		else
		{
			_alpha=[alpha1]
			part_type_alpha1(_index,_alpha[0])
		}
		return self
	}
	static set_blend		=	function(blend)
	{
		_blend	=	blend
		part_type_blend(_index,_blend)
		return self
	}
	static set_speed		=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_speed	=[_min,_max,_incr,_wiggle]
		part_type_speed(_index,_speed[0],_speed[1],_speed[2],_speed[3])
		return self
	}
	static set_shape		=	function(shape)
	{
		_shape			=	shape
		_set_to_sprite	=	false
		part_type_shape(_index,_shape)
		return self
	}
	static set_sprite		=	function(sprite,_animate=false,_stretch=false,_random=true)
	{
		_sprite			=	[sprite,_animate,_stretch,_random]
		_set_to_sprite	=	true
		part_type_sprite(_index,_sprite[0],_sprite[1],_sprite[2],_sprite[3])
		return self
	}
	static set_orient		=	function(_min,_max,_incr=0,_wiggle=0,_relative=true)
	{
		_orient	=[_min,_max,_incr,_wiggle,_relative]
		part_type_orientation(_index,_orient[0],_orient[1],_orient[2],_orient[3],_orient[4])
		return self
	}
	static set_gravity		=	function(_amount,_direction)
	{
		_gravity	=[_amount,_direction]
		part_type_gravity(_index,_gravity[0],_gravity[1])
		return self
	}
	static set_direction	=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_direction	=[_min,_max,_incr,_wiggle]
		part_type_direction(_index,_direction[0],_direction[1],_direction[2],_direction[3])
		return self
	}
	static set_step_particle=	function(_number,_step)
	{
		if _step != undefined exit
		_step_type		=	_step
		_step_number	=	_number
		part_type_step(_index,_step_number,_step_type)
		return self
	}
	static set_death_particle=	function(_number,_death)
	{
		if _death != undefined exit
		_death_type		=	_death
		_death_number	=	_number
		part_type_death(_index,_death_number,_death_type)
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

		static scale_time		= function (_factor)
		{
			//If factor is one, nothing to be done here
			if _factor ==1 exit
		
			// Record the changes to be able to reset it later
			time_factor		=	time_factor*_factor
			
			set_life(_life[0]*_factor,_life[1]*_factor)
		
			//flip percentage
			_factor = 1/_factor
		
			set_speed(_speed[0]*_factor,_speed[1]*_factor,_speed[2]*_factor,_speed[3]*_factor)
			set_gravity(_gravity[0]*_factor,_gravity[1])
		
			return self
		}
		
		static scale_time_abs	= function(_factor)
		{
			var _absolute_factor = _factor
			_factor = _factor/time_factor
			
			scale_time(_factor)
			
			time_factor = _absolute_factor
		
			return self
		}
		
		static scale_space		= function (_factor,_shrink_particle)
		{
		
			set_size(_size[0]*_factor,_size[1]*_factor)
			set_speed(_speed[0]*_factor,_speed[1]*_factor,_speed[2]*_factor,_speed[3]*_factor)
			set_gravity(_gravity[0]*_factor,_gravity[1])
		
			return self
		}
		
		static scale_space_abs	= function(_factor)
		{
			var _absolute_factor = _factor
			_factor = _factor/space_factor
			
			scale_space(_factor)
			
			space_factor = _absolute_factor
		
			return self
		}


	#endregion 

	static reset	=	function()
	{
		part_type_scale(_index,_scale[0],_scale[1]);
		part_type_size(_index,_size[0],_size[1],_size[2],_size[3])
		part_type_life(_index,_life[0],_life[1])
		var color = array_length(_color)
		if color==3
		{
			part_type_color3(_index,_color[0],_color[1],_color[2])
		} else if color==2
		{
			part_type_color2(_index,_color[0],_color[1])
		} else
		{
			part_type_color1(_index,_color[0])
		}
		var alpha = array_length(_alpha)
		if alpha==3
		{
			part_type_alpha3(_index,_alpha[0],_alpha[1],_alpha[2])
		} else if alpha==2
		{
			part_type_alpha2(_index,_alpha[0],_alpha[1])
		} else
		{
			part_type_alpha1(_index,_alpha[0])
		}
				
		part_type_blend(_index,_blend)
		part_type_speed(_index,_speed[0],_speed[1],_speed[2],_speed[3])
		if !_set_to_sprite
		{
			part_type_shape(_index,_shape)
		}
		else
		{
			part_type_sprite(_index,_sprite[0],_sprite[1],_sprite[2],_sprite[3])
		}
		part_type_orientation(_index,_orient[0],_orient[1],_orient[2],_orient[3],_orient[4])
		part_type_gravity(_index,_gravity[0],_gravity[1])
		part_type_direction(_index,_direction[0],_direction[1],_direction[2],_direction[3])
		
		if _step_type != undefined part_type_step(_index,_step_number,_step_type)
		if _death_type != undefined part_type_death(_index,_death_number,_death_type)
	
	}
	reset()
	static launch		=	function(_struct)
	{
		with(_struct)
		{
			part_type_life(particle_index,__life,__life);
			part_type_speed(particle_index,_speed,_speed,other._speed[2],0)
			part_type_direction(particle_index,dir,dir,other._direction[2],0)
		
			if _size !=undefined
			{
				part_type_size(particle_index,_size,_size,other._size[2],0)	
			}
			if _orient !=undefined
			{
				part_type_orientation(particle_index,_orient,_orient,other._orient[2],0,other._orient[4])	
			}
			
			if color_mode == PULSE_COLOR.A_TO_B_RGB or color_mode == PULSE_COLOR.COLOR_MAP
			{
				part_type_color_rgb(particle_index,r_h,r_h,g_s,g_s,b_v,b_v)
			} 
			else if color_mode == PULSE_COLOR.A_TO_B_HSV
			{
				part_type_color_hsv(particle_index,r_h,r_h,g_s,g_s,b_v,b_v)
			}
			
			part_particles_create(part_system_index, x_origin,y_origin,particle_index, 1);


		}		
	}
}

function __pulse_instance_particle	(_object) constructor
{
	_index			=	_object
	_size			=	__PULSE_DEFAULT_PART_SIZE
	_scale			=	__PULSE_DEFAULT_PART_SCALE
	_life			=	__PULSE_DEFAULT_PART_LIFE
	_color			=	__PULSE_DEFAULT_PART_COLOR
	_color_mode		=	__PULSE_DEFAULT_PART_COLOR_MODE
	_alpha			=	__PULSE_DEFAULT_PART_ALPHA
	_blend			=	__PULSE_DEFAULT_PART_BLEND
	_speed			=	__PULSE_DEFAULT_PART_SPEED
	_sprite			=	object_get_sprite(_object)
	_orient			=	__PULSE_DEFAULT_PART_ORIENT
	_gravity		=	__PULSE_DEFAULT_PART_GRAVITY
	_direction		=	__PULSE_DEFAULT_PART_DIRECTION
	_death_type		=	undefined
	_death_number	=	undefined
	_step_type		=	undefined
	_step_number	=	undefined
	
	#region //SET BASIC PROPERTIES
	static set_size			=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_size	=[_min,_max,_incr,_wiggle]
		
		return self
	}
	static set_scale		=	function(scalex,_scaley)
	{
		_scale			= [scalex,_scaley]
		return self
	}
	static set_life			=	function(_min,_max)
	{
		_life	=[_min,_max]
		return self
	}
	static set_color		=	function(color1,color2=-1,color3=-1)
	{
		if color3 != -1
		{
			_color=[color1,color2,color3]	
		}
		else if color2 != -1
		{
			_color=[color1,color2]
		}
		else
		{
			_color=[color1]
		}
		_color_mode		= __PULSE_COLOR_MODE.COLOR
		return self
	}
	static set_alpha		=	function(alpha1,alpha2=-1,ac_curve=-1)
	{
		if alpha2 != -1
		{
			_alpha=[alpha1,alpha2]

		}
		else
		{
			_alpha=[alpha1]

		}
		return self
	}
	static set_blend		=	function(blend)
	{
		_blend	=	blend
		return self

	}
	static set_speed		=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_speed	=[_min,_max,_incr,_wiggle]
		return self
	}
	static set_sprite		=	function(sprite,_animate=false,_stretch=false,_random=true)
	{
		_sprite			=	[sprite,_animate,_stretch,_random]

	}
	static set_orient		=	function(_min,_max,_incr=0,_wiggle=0,_relative=true)
	{
		_orient	=[_min,_max,_incr,_wiggle,_relative]
		return self
	}
	static set_gravity		=	function(_amount,_direction)
	{
		_gravity	=[_amount,_direction]
		return self
	}
	static set_direction	=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_direction	=[_min,_max,_incr,_wiggle]
		return self
	}
	#endregion
	
	static launch		=	function(_struct)
	{		 
		if _struct._size == undefined
		{
			_struct._size			=	_size
		}
		if _struct._orient == undefined
		{
			_struct._orient			=	_orient
		}
		_struct._scale			=	_scale
		_struct._color			=	_color
		_struct._alpha			=	_alpha
		_struct._blend			=	_blend
		//_struct._sprite			=	_sprite

		_struct._gravity		=	_gravity
		_struct._death_type		=	_death_type
		_struct._death_number	=	_death_number
		_struct._step_type		=	_step_type
		_struct._step_number	=	_step_number

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

function pulse_force				(_x,_y,_direction,_type = PULSE_FORCE.DIRECTION,_weight = 1) constructor
{
	x			= _x
	y			= _y
	type		= _type
	range		= PULSE_FORCE.RANGE_INFINITE
	direction	= _direction
	weight		= _weight
	
	static set_range_directional = function(_north=-1,_south=-1,_east=-1,_west=-1)
	{
		if (_north==-1 &&_south==-1 &&_east==-1 &&_west==-1) 
		{
			range		= PULSE_FORCE.RANGE_INFINITE
			return self
		}
		north	= _north
		south	= _south
		east	=_east
		west	=_west
		
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
	
	global.pulse.systems[$_name] = new __pulse_system(_layer,_persistent);
	__pulse_show_debug_message($"PULSE SUCCESS: Created system by the name {_name}");
	
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
	
	global.pulse.part_types[$_name] = new __pulse_particle()
	__pulse_show_debug_message($"PULSE SUCCESS: Created particle by the name {_name}");
	
	if _return_index
	{
		return global.pulse.part_types[$_name]._index
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
		target.set_size(src.size_min,src.size_max,src.size_incr,src.size_wiggle)
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
			target.set_sprite(src.sprite,src.animate,src.stretch,src.random)
		}
	l++
	}
}