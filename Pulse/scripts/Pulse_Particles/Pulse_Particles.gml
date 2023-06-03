global.pulse =
{
	systems		: {},
	part_types	: {},
}

function __pulse_system				(_layer= -1,_persistent=false) constructor
{
	if _layer == -1
	{
		index	=	part_system_create();
	}
	else
	{
		index	=	part_system_create_layer(_layer,_persistent);
	}
	
	draw			=	true;
	draw_oldtonew	=	true
	update			=	true;
	depth			=	0;
	layer			=	_layer;
	x				=	0;
	y				=	0;
	
	static set_depth	= function(_depth)
	{
		depth	=	_depth;
		part_system_depth(index, depth);
	}
	
	static set_update	= function(_bool)
	{
		update	=	_bool;
		part_system_automatic_update(index,update);
	}
	
	static set_draw		= function(_bool)
	{
		draw	=	_bool;
		part_system_automatic_draw(index,draw);
	}
	
	static set_layer	= function(_layer)
	{
		layer	=	_layer;
		part_system_layer(index,layer);
	}
	
	static set_draw		= function(_bool)
	{
		draw_oldtonew	=	_bool;
		part_system_draw_order(index,draw_oldtonew);
	}
	
	static set_position	= function(_x,_y)
	{
		x				=	_x;
		y				=	_y;
		part_system_position(index,x,y);
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
	
	#region //SET BASIC PROPERTIES
	static set_size			=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_size	=[_min,_max,_incr,_wiggle]
		part_type_size(_index,_size[0],_size[1],_size[2],_size[3])
	}
	static set_scale		=	function(_scalex,_scaley)
	{
		_scale			= [_scalex,_scaley]
		part_type_scale(_index,_scale[0],_scale[1]);
	}
	static set_life			=	function(_min,_max)
	{
		_life	=[_min,_max]
		part_type_life(_index,_life[0],_life[1])
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
	}
	static set_blend		=	function(blend)
	{
		_blend	=	blend
		part_type_blend(_index,_blend)
	}
	static set_speed_start	=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_speed	=[_min,_max,_incr,_wiggle]
		part_type_speed(_index,_speed[0],_speed[1],_speed[2],_speed[3])
	}
	static set_shape		=	function(shape)
	{
		_shape			=	shape
		_set_to_sprite	=	false
		part_type_shape(_index,_shape)
	}
	static set_sprite		=	function(sprite,_animate=false,_stretch=false,_random=true)
	{
		_sprite			=	[sprite,_animate,_stretch,_random]
		_set_to_sprite	=	true
		part_type_sprite(_index,_sprite[0],_sprite[1],_sprite[2],_sprite[3])
	}
	static set_orient		=	function(_min,_max,_incr=0,_wiggle=0,_relative=true)
	{
		_orient	=[_min,_max,_incr,_wiggle,_relative]
		part_type_orientation(_index,_orient[0],_orient[1],_orient[2],_orient[3],_orient[4])
	}
	static set_gravity		=	function(_amount,_direction)
	{
		_gravity	=[_amount,_direction]
		part_type_gravity(_index,_gravity[0],_gravity[1])
	}
	static set_direction	=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_direction	=[_min,_max,_incr,_wiggle]
		part_type_direction(_index,_direction[0],_direction[1],_direction[2],_direction[3])
	}
	static set_step_particle=	function(_number,_step)
	{
		if _step != undefined exit
		_step_type		=	_step
		_step_number	=	_number
		part_type_step(_index,_step_number,_step_type)
	}
	static set_death_particle=	function(_number,_death)
	{
		if _death != undefined exit
		_death_type		=	_death
		_death_number	=	_number
		part_type_death(_index,_death_number,_death_type)
	}
#endregion

	static launch		=	function(_struct)
	{
		part_type_life(_struct._index,_struct.__life,_struct.__life);
		part_type_speed(_struct._index,_struct._speed,_struct._speed,_struct._accel,0)
		part_type_direction(_struct._index,_struct.dir,_struct.dir,0,0)
		
		part_particles_create(_struct._part_system, _struct.x_origin,_struct.y_origin,_struct._index, 1);
		//reset()
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
	_shape			=	__PULSE_DEFAULT_PART_SHAPE
	_sprite			=	undefined
	_orient			=	__PULSE_DEFAULT_PART_ORIENT
	_gravity		=	__PULSE_DEFAULT_PART_GRAVITY
	_direction		=	__PULSE_DEFAULT_PART_DIRECTION
	_set_to_sprite	=	false
	_death_type		=	undefined
	_death_number	=	undefined
	_step_type		=	undefined
	_step_number	=	undefined
	
	
	static set_size			=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_size	=[_min,_max,_incr,_wiggle]
	}
	static set_scale		=	function(_scalex,_scaley)
	{
		_scale			= [_scalex,_scaley]
	}
	static set_life			=	function(_min,_max)
	{
		_life	=[_min,_max]
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
	}
	static set_blend		=	function(blend)
	{
		_blend	=	blend

	}
	static set_speed_start	=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_speed	=[_min,_max,_incr,_wiggle]

	}
	static set_sprite		=	function(sprite,_animate=false,_stretch=false,_random=true)
	{
		_sprite			=	[sprite,_animate,_stretch,_random]

	}
	static set_orient		=	function(_min,_max,_incr=0,_wiggle=0,_relative=true)
	{
		_orient	=[_min,_max,_incr,_wiggle,_relative]
	}
	static set_gravity		=	function(_amount,_direction)
	{
		_gravity	=[_amount,_direction]
	}
	static set_direction	=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_direction	=[_min,_max,_incr,_wiggle]
	}
	
	static launch		=	function(_struct)
	{
		
		part_type_life(_struct._index,_struct.__life,_struct.__life);
		part_type_speed(_struct._index,_struct._speed,_struct._speed,_struct._accel,0)
		part_type_direction(_struct._index,_struct.dir,_struct.dir,0,0)
		_struct.x_origin	+= (lengthdir_x(_struct.length,_struct.normal)*_struct._scalex);
		_struct.y_origin	+= (lengthdir_y(_struct.length,_struct.normal)*_struct._scaley);
				
		part_particles_create(_struct._part_system, _struct.x_origin,_struct.y_origin,_struct._index, 1);
		reset()
	}
}

function pulse_make_system			(_name=__PULSE_DEFAULT_SYS_NAME,_return_index=false,_layer= -1,_persistent=false)
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
			return global.pulse.systems[$_name]._index
		}
		else
		{
			return global.pulse.systems[$_name]
		}
}

function pulse_make_particle		(_name=__PULSE_DEFAULT_PART_NAME,_return_index=false)
{
	if _name		==__PULSE_DEFAULT_PART_NAME
	{
		var l		=	struct_names_count(global.pulse.part_types)		
		_name		=	$"{_name}_{l}";		
	}
		global.pulse.part_types[$_name] = new __pulse_particle()
			show_debug_message($"PULSE SUCCESS: Created particle by the name {_name}");
		if _return_index
		{
			return global.pulse.part_types[$_name]._index
		}
		else
		{
			return global.pulse.part_types[$_name]
		}
}

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
		target.set_speed_start(src.speed_min,src.speed_max,src.speed_incr,src.speed_wiggle)
		target.set_direction(src.dir_min,src.dir_max,src.dir_incr,src.dir_wiggle)
		target.set_gravity(src.grav_amount,src.grav_dir)
		target.set_orient(src.ang_min,src.ang_max,src.ang_inc,src.ang_wiggle,src.ang_relative)
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