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
			__pulse_show_debug_message("PULSE WARNING: System is asleep and can't be reset")
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
			__pulse_show_debug_message("PULSE WARNING: System is asleep and can't be updated")
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
	
	static draw_it					= function()
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
