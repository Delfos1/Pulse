
/// @description			Use this constructor to create a new particle system.
/// @param {String}			_name : Name your particle or leave empty to use the default name
/// @param {ID.Layer}		_layer	: Which layer to place the system
/// @param {Bool}			_persistent	: Whether to make the system persistent or not (true by default)
/// @return {Struct}
function pulse_system				(_name=__PULSE_DEFAULT_SYS_NAME,_layer= -1,_persistent=true) constructor
{
	name = string(_name)
	index = -1
	
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
	
	pulse_ver		=	_PULSE_VERSION
	limit			=	0
	draw			=	true;
	draw_oldtonew	=	true;
	update			=	true;
	x				=	0;
	y				=	0;
	angle			=	0;
	samples			=	1;
	persistent		=	_persistent;
	factor			=	1;
	color			=	c_white;
	alpha			=	1;
	global_space	=	false;
	particle_amount =	0;
	
	// wake-sleep rules

	wake_on_emit		= true
	sleep_when_empty	= true
	count				= undefined
	
	#region jsDoc
	/// @desc    Destroys the system and all its components. It doesn't remove a system from the storage.
	#endregion
	static destroy = function()
	{
		if part_system_exists(index)
		{
			part_system_destroy(index)
		}
		// Destroy time_source
		if time_source_exists(count)
		{
			time_source_destroy(count,true)
		}
	}
	
	#region jsDoc
		/// @desc    Sets the draw depth of the system
		/// @param   {Real} _depth : The depth for the system.
	#endregion
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
	#region jsDoc
	/// @desc    Sets the system on a defined layer to draw it onto.
	/// @param   {Id.Layer, String} _layer : The layer to set the system to.
	#endregion
	static set_layer				= function(_layer)
	{
		if !layer_exists(_layer)
		{
			__pulse_show_debug_message("Layer doesn't exist",1)
			return self	
		}
		layer	=	_layer;
		if index == -1 
		{
			__pulse_show_debug_message("System is asleep",1)
			return self
		}
		part_system_layer(index,layer);
		
		return self
	}
	#region jsDoc
		/// @desc    Sets whether the system is updating automatically every step or not. By default this is true.
		/// @param   {Bool} _bool : Whether the system updates with every step automatically (true) or not (false)
		#endregion
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
	#region jsDoc
		/// @desc    Sets whether the system is drawing automatically every step or not. By default this is true.
		/// @param   {Bool} _bool : Whether the system draws with every step automatically (true) or not (false)
		#endregion
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
	#region jsDoc
		/// @desc    Sets in which order particles are drawn.
		/// @param   {Bool} _bool : Whether the system draws the new particles on top (true) or on the bottom (false)
		#endregion
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
	#region jsDoc
		/// @desc    Sets the position of the system in room coordinates
		/// @param   {Real} _x : X Room coordinate
		/// @param   {Real} _y : Y Room coordinate
		#endregion
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
	#region jsDoc
		/// @desc    Sets the angle of the system
		/// @param   {Real} _angle : new angle of the system, in degrees
		#endregion
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
	#region jsDoc
		/// @desc    Turns super-sampling on or off. Super-Sampling allows to de-couple system ticks and game steps. WARNING: Super sampling turns auto-updating off.
		/// @param   {Bool} _active : Whether to turn super sampling on or off.
		/// @param   {Real} _samples : Amount of system ticks that will happen per step.
		#endregion
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
		return self
	}
	#region jsDoc
		/// @desc   Sets the color and alpha of the whole system
		/// @param   {Real} _color : Color for the system. c_white displays the system normally
		/// @param   {Real} _alpha : Alpha for the system, from 0 (transparent) to 1 (opaque)
		#endregion
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
	#region jsDoc
		/// @desc    Enables setting the particles to global space. By activating this, the particles already created will stay in global space instead of system space.
		/// @param   {Bool} _enable : Whether the system's particles are in global space (true) or not (false)
	#endregion
	static set_global_space			= function(_enable)
	{
		if index == -1 
		{
			__pulse_show_debug_message("ystem is asleep and properties can't be set",1)
			return self
		}
			global_space	=	_enable
			part_system_global_space(index,_enable)
		return self
	}
	#region jsDoc
		/// @desc    Re-applies the saved properties to the system. Not usually required to call manually
	#endregion
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
		part_system_global_space	(index,global_space);
	}
	#region jsDoc
	/// @desc    Updates the particle system manually
	/// @param   {Real} _resample : the amount of times to update the system.
	#endregion
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
			_resample = max(1,_resample)
			repeat(_resample)
			{
				part_system_update(index)
			}
		}
	}
	#region jsDoc
	/// @desc   Gets the amount of particles alive in the system.
	#endregion
	static get_particle_count		= function()
	{
		if index == -1 
		{
			particle_amount = 0
			return 0
		}
		particle_amount =  part_particles_count(index)
		
		return particle_amount
	}
	#region jsDoc
	/// @desc    Draws the Particle System
	#endregion
	static draw_it					= function()
	{
		if index == -1 
		{
			__pulse_show_debug_message("System is asleep",1)
			exit
		}
	
		part_system_drawit(index)	
	}
	#region jsDoc
	/// @desc    Changes the persistency and layer of the system. It destroys the previous system to do so.
	/// @param   {Id.Layer, String} _layer : The layer to set the system to.
	/// @param   {Bool} _persistent : Whether to make the system persistent or not.
	#endregion
	static set_persistent			= function(_layer,_persistent)
	{
		if persistent == _persistent
		{
			if layer != _layer && layer_exists(_layer)
			{
				set_layer(_layer)
			}
		}
		else
		{
			if part_system_exists(index)
			{
				part_system_destroy(index)
			}
			
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
					persistent = _persistent
			}
			
			
		}
		
	}
	//RESOURCE MANAGEMENT
	#region jsDoc
	/// @desc    Makes the system asleep. This frees the system from memory but doesn't detroy its configuration.
	/// @param   {Bool} _wake_on_emit : Whether to automatically wake the system when an emition is requested (true) or not (false). Default: TRUE
	#endregion
	static make_asleep				= function(_wake_on_emit=true)
	{
		wake_on_emit		= _wake_on_emit
		if time_source_exists(count)
		{
			if time_source_get_state(count) != time_source_state_stopped
			{
				time_source_stop(count)
			}
		}
		if index == -1 
		{
			__pulse_show_debug_message("System is already asleep",1)
			return self
		}
		part_system_destroy(index)
		index = -1
		return self
	}
	#region jsDoc
	/// @desc    Makes the system awake. This makes the system available for changes and for emition.
	#endregion
	static make_awake				= function()
	{
		
		if index != -1 
		{
			__pulse_show_debug_message("System is already awake",1)
			return self
		}
		
		if time_source_exists(count)
		{
			time_source_resume(count)
		}
		
		index	=	part_system_create()
		
		reset()
		return self
	}
	#region jsDoc
	/// @desc   Limits the amount of particles sustainable by the system
	/// @param   {Real} max_amount : The max amount of particles
	/// @param   {Bool} _sleep_when_empty : Whether to automatically sleep the system when the system is empty of particles (true) or not (false). Default: TRUE
	#endregion
	static set_particle_limit		= function(max_amount,_sleep_when_empty=true)
	{
		limit = max(0,max_amount)
		
		if !time_source_exists(count)
		{
			count	=	time_source_create(time_source_game,__PULSE_DEFAULT_COUNT_TIMER,time_source_units_frames,function()
			{
				if index == -1
				{
					time_source_stop(count)
					exit
				}
				particle_amount =  part_particles_count(index)
				// if there are more particles than desired limit
				if particle_amount-limit > limit*.125
				{
					factor *= (limit/particle_amount)
				} 
				else if limit-particle_amount > limit*.125 && factor<1
				{
					factor /= (particle_amount/limit)
					factor = min(1,factor)
				}
				else if particle_amount == 0
				{
					if sleep_when_empty 
					{ 
						make_asleep(wake_on_emit) 
					}
					else
					{
						time_source_stop(count)
					}
				}
	
			},[],-1)
		}
		
		if time_source_get_state(count) != time_source_state_active
		{
			time_source_start(count)
		}
		
		particle_amount =  part_particles_count(index)
				// if there are more particles than desired limit
		if particle_amount-limit > limit*.125
		{
			factor *= (limit/particle_amount)
		} 
		else if limit-particle_amount > limit*.125 && factor<1
		{
			factor /= (particle_amount/limit)
			factor = min(1,factor)
		}
		return self
	}

}

