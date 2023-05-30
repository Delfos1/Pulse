global.pulse =
{
	systems		: {},
	part_types	: {},
}

function __pulse_system(_layer= -1,_persistent=false) constructor
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

function __pulse_particle() constructor
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
	_death_number	=	undefined
	_step_type		=	undefined
	_step_number	=	undefined
	
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
	
	}
	reset()
	
	static size			=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_size	=[_min,_max,_incr,_wiggle]
		part_type_size(_index,_size[0],_size[1],_size[2],_size[3])
	}
	static scale		=	function(_scalex,_scaley)
	{
		_scale			= [_scalex,_scaley]
		part_type_scale(_index,_scale[0],_scale[1]);
	}
	static life			=	function(_min,_max)
	{
		_life	=[_min,_max]
		part_type_life(_index,_life[0],_life[1])
	}
	static color		=	function(color1,color2=-1,color3=-1)
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
	static alpha		=	function(alpha1,alpha2=-1,alpha3=-1)
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
	static blend		=	function(blend)
	{
		_blend	=	blend
		part_type_blend(_index,_blend)
	}
	static speed_start	=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_speed	=[_min,_max,_incr,_wiggle]
		part_type_speed(_index,_speed[0],_speed[1],_speed[2],_speed[3])
	}
	static shape		=	function(shape)
	{
		_shape			=	shape
		_set_to_sprite	=	false
		part_type_shape(_index,_shape)
	}
	static sprite		=	function(sprite,_animate=false,_stretch=false,_random=true)
	{
		_sprite			=	[sprite,_animate,_stretch,_random]
		_set_to_sprite	=	true
		part_type_sprite(_index,_sprite[0],_sprite[1],_sprite[2],_sprite[3])
	}
	static orient		=	function(_min,_max,_incr=0,_wiggle=0,_relative=true)
	{
		_orient	=[_min,_max,_incr,_wiggle,_relative]
		part_type_orientation(_index,_orient[0],_orient[1],_orient[2],_orient[3],_orient[4])
	}
	static gravity_set	=	function(_amount,_direction)
	{
		_gravity	=[_amount,_direction]
		part_type_gravity(_index,_gravity[0],_gravity[1])
	}
	static direction_set=	function(_min,_max,_incr=0,_wiggle=0)
	{
		_direction	=[_min,_max,_incr,_wiggle]
		part_type_direction(_index,_direction[0],_direction[1],_direction[2],_direction[3])
	}
	
}

function pulse_make_system(_name=__PULSE_DEFAULT_SYS_NAME,_return_index=false,_layer= -1,_persistent=false)
{
	if _name		==__PULSE_DEFAULT_SYS_NAME
	{
		var l		=	struct_names_count(global.pulse.systems)		
		_name		=	$"{_name}_{l}";		
	}
	
	global.pulse.systems[$_name] = new __pulse_system(_layer,_persistent);
	show_debug_message($"PULSE SUCCESS: Created system by the name {_name}");
	
		if _return_index
		{
			return global.pulse.systems[$_name]._index
		}
		else
		{
			return global.pulse.systems[$_name]
		}
}

function pulse_make_particle(_name=__PULSE_DEFAULT_PART_NAME,_return_index=false)
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

function pulse_convert_particles(part_system)
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
		target.size(src.size_min,src.size_max,src.size_incr,src.size_wiggle)
		target.scale(src.xscale,src.yscale)
		target.life(src.life_min,src.life_max)
		//death
		//step
		target.speed_start(src.speed_min,src.speed_max,src.speed_incr,src.speed_wiggle)
		target.direction_set(src.dir_min,src.dir_max,src.dir_incr,src.dir_wiggle)
		target.gravity_set(src.grav_amount,src.grav_dir)
		target.orient(src.ang_min,src.ang_max,src.ang_inc,src.ang_wiggle,src.ang_relative)
		target.color(src.color1,src.color2,src.color3)
		target.alpha(src.alpha1,src.alpha2,src.alpha3)
		target.blend(src.additive)
		if src.sprite == -1
		{
			target.shape(src.shape)
		}
		else
		{
			target.sprite(src.sprite,src.animate,src.stretch,src.random)
		}
	l++
	}
	
	
	
	
}