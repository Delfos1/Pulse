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
	angle			=	0;
	samples			=	1;
	persistent		=	_persistent;
	factor			=	1;
	color			=	c_white
	alpha			=	1
	global_space	=	false
	particle_amount =	0
	
	// wake-sleep rules
	
	wake_on_emit		= true
	sleep_when_empty	= true
	
	static set_depth				= function(_depth=depth)
	{
		depth	=	_depth;
		layer = -1
		
		if index == -1 
		{
			__pulse_show_debug_message("System is asleep",1)
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
			__pulse_show_debug_message("System is asleep",1)
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
			__pulse_show_debug_message("System is asleep",1)
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
			__pulse_show_debug_message("System is asleep",1)
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
			__pulse_show_debug_message("System is asleep",1)
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
			__pulse_show_debug_message("System is asleep",1)
			return self
		}
		part_system_position(index,x,y);
		
		return self
	}
	
	static set_angle				= function(_angle)
	{
		if index == -1 
		{
			__pulse_show_debug_message("System is asleep and properties can't be set",1)
			return self
		}
		angle = _angle
		
		part_system_angle(index,angle)
		
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
	
	static set_color				= function(_color,_alpha)
	{
		if index == -1 
		{
			__pulse_show_debug_message("System is asleep and properties can't be set",1)
			return self
		}
			color			=	_color
			alpha			=	_alpha
			part_system_color(index,_color,_alpha)
		return self
	}
	
	static set_global_space			= function(_enable)
	{
		if index == -1 
		{
			__pulse_show_debug_message("ystem is asleep and properties can't be set",1)
			return self
		}
			global_space	=	_enable
			part_system_global_space(_enable)
		return self
	}
	
	static reset					= function()
	{
		if index == -1 
		{
			__pulse_show_debug_message("System is asleep and can't be reset",1)
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
		part_system_automatic_draw	(index,draw);
		part_system_draw_order		(index,draw_oldtonew);
		part_system_position		(index,x,y);
		part_system_angle			(index,angle);
		part_system_color			(index,color,alpha);
		part_system_global_space	(global_space);
	}
	
	static update_system			= function(_resample=1)
	{
		if index == -1 
		{
			__pulse_show_debug_message("System is asleep and can't be updated",1)
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
	
	static get_particle_count		= function()
	{
		if index == -1 
		{
			__pulse_show_debug_message("System is asleep",1)
			return 0
		}
		particle_amount =  part_particles_count(index)
		
		return particle_amount
	}
	
	static draw_it					= function()
	{
		if index == -1 
		{
			__pulse_show_debug_message("System is asleep",1)
			exit
		}
	
		part_system_drawit(index)	
	}
	
	//RESOURCE MANAGEMENT
	
	static make_asleep				= function()
	{
		if index == -1 
		{
			__pulse_show_debug_message("System is already asleep",1)
		}
		part_system_destroy(index)
		index = -1
	}
	
	static make_awake				= function()
	{
		if index != -1 
		{
			__pulse_show_debug_message("System is already awake",1)
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
					particle_amount =  part_particles_count(index)
								
					// if there are more particles than desired threshold
					if particle_amount-threshold > threshold*.1
					{
						factor *= (threshold/particle_amount)
					} 
					else if threshold-particle_amount > threshold*.1 && factor<1
					{
						factor /= (particle_amount/threshold)
						factor = min(1,factor)
					}
					else if particle_amount == 0
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

/// @description			Use this to create a new particle system. It returns a reference to the struct by default, but it will return the system index if the second argument is true.
/// @param {String}			_name : Name your particle or leave empty to use the default name
/// @param {Bool}			_return_index	: Whether to return the particle index or not (false by default)
/// @param {ID.Layer}		_layer	: Which layer to place the system
/// @param {Bool}			_persistent	: Whether to make the system persistent or not (true by default)
/// @return {Struct}
function pulse_make_system			(_name=__PULSE_DEFAULT_SYS_NAME,_return_index=false,_layer= undefined,_persistent=true)
{
	if _name		==__PULSE_DEFAULT_SYS_NAME
	{
		var l		=	struct_names_count(global.pulse.systems)		
		_name		=	$"{_name}_{l}";		
	}

	if pulse_exists_system(_name) <= 0 
	{
		global.pulse.systems[$_name] = new __pulse_system(_name,_layer,_persistent);
		__pulse_show_debug_message($"Created system by the name {_name}",3);
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
