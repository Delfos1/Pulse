#region LOOK UP Helper functions

function __pulse_lookup_system	(_name)
{
	var system_found = pulse_exists_system(_name)
	
	switch(system_found)
	{
		case 2:
				return _name
		break
		case 1:
				return global.pulse.systems[$_name];
		break
		case 0:
				__pulse_show_debug_message($"System {_name} not found, creating system by that name",1)
				return new pulse_system(_name);
		break
		case -1:
				__pulse_show_debug_message($"System {_name} not found, creating system with default name",1)
				return new pulse_system(__PULSE_DEFAULT_SYS_NAME);
		break
	}
	
}

function __pulse_lookup_particle(_name)
{
	var particle_found = pulse_exists_particle(_name)
	
	switch(particle_found)
	{
		case 2:
				return _name
		break
		case 1:
				return global.pulse.part_types[$_name];
		break
		case 0:
				__pulse_show_debug_message($"Particle \"{_name}\" not found, creating particle with that name",1)
				return	pulse_store_particle(new pulse_particle(_name));
		break
		case -1:
				__pulse_show_debug_message($"Particle argument is not a string or a Pulse Particle, creating particle with default name" ,1)
				return new pulse_particle(__PULSE_DEFAULT_PART_NAME);
		break
	}
	
}

#endregion

#region CLONE
/// @desc Duplicates the given system. Returns a reference to the system.
/// @param {string} __name The name of the system to clone
/// @param {string} __new_name Optional: The name of the cloned system. By default it appends "_copy" to the original name 
/// @returns {Struct}
function pulse_clone_system		(__name,__new_name=__name)
{
	if  !struct_exists(global.pulse.systems,__name)
	{
		__pulse_show_debug_message($"Couldn't find a particle by the name {__name}",2);
		exit;
	}
		
	if __name == __new_name
	{
	__new_name= __name+"_copy";
	}
		
	global.pulse.systems[$__new_name]		=	variable_clone(global.pulse.systems[$__name])
	global.pulse.systems[$__new_name].index	=	part_system_create()
	global.pulse.systems[$__new_name].reset()

	__pulse_show_debug_message($"System {__name} cloned and named {__new_name}",1);
	
	return global.pulse.systems[$__new_name]
}

/// @desc Duplicates the given particle. Returns a reference to the particle.
/// @param {string} __name The name of the particle to clone
/// @param {string} __new_name Optional: The name of the cloned particle. By default it appends "_copy" to the original name 
/// @returns {Struct}
function pulse_clone_particle	(__name,__new_name=__name)
{

	if  !struct_exists(global.pulse.part_types,__name)
	{
		__pulse_show_debug_message($"Couldn't find a particle by the name {__name}",2);
		exit;
	}
		
	if __name == __new_name
	{
	__new_name= __name+"_copy";
	}
		
	global.pulse.part_types[$__new_name]		=	variable_clone(global.pulse.part_types[$__name])
	global.pulse.part_types[$__new_name].index	=	part_type_create();
	global.pulse.part_types[$__new_name].reset()
	variable_struct_remove(global.pulse.part_types[$__new_name],"subparticle")
	global.pulse.part_types[$__new_name].subparticle= undefined
	__pulse_show_debug_message($"Particle {__name} cloned and named {__new_name}",3);
	
	return global.pulse.part_types[$__new_name]
}

#endregion

#region DESTROY

/// @desc Destroys a system both from the GameMaker index as from Pulse's data
/// @param {string} _name The name of the system to destroy
/// @returns {Struct}
function pulse_destroy_system	(_name)
{
	if is_string(_name)
	{
		if struct_exists(global.pulse.systems,_name)
		{
			// Destroy particle system
			part_system_destroy(global.pulse.systems[$_name].index)
		
			// Destroy time_source
			if time_source_exists(global.pulse.systems[$_name].count)
			{
				time_source_destroy(global.pulse.systems[$_name].count,true)
			}
			//Remove from struct
			variable_struct_remove(global.pulse.systems,_name)
		}
	} 
		else if is_instanceof(_name,pulse_system)
	{
		part_system_destroy(_name.index)
		if time_source_exists(_name.count)
		{
			time_source_destroy(_name.count,true)
		}
		if struct_exists(global.pulse.systems,_name.name)
		{
			variable_struct_remove(global.pulse.systems,_name.name)
		}
	}

}

/// @desc Destroys a particle type both from the GameMaker index as from Pulse's data
/// @param {string} _name The name of the particle to destroy
/// @returns {Struct}
function pulse_destroy_particle	(_name)
{
	if is_string(_name)
	{
		if struct_exists(global.pulse.part_types,_name)
		{
			part_type_destroy(global.pulse.part_types[$_name].index)
			if global.pulse.part_types[$_name].subparticle != undefined 
			{
				part_type_destroy(global.pulse.part_types[$_name].subparticle.index)
			}
			variable_struct_remove(global.pulse.part_types,_name)
		}
	}
	else if is_instanceof(_name,__pulse_particle_class)
	{
		part_type_destroy(_name.index)
		if _name.subparticle != undefined 
		{
			part_type_destroy(_name.subparticle.index)
		}
		if struct_exists(global.pulse.part_types,_name.name)
		{
			variable_struct_remove(global.pulse.part_types,_name.name)
		}
	}

}

/// @desc Destroys all particle types, particle systems, and emitters

function pulse_destroy_all()
{	var sys, part, i
	
	sys		= struct_get_names(global.pulse.systems)
	part	= struct_get_names(global.pulse.part_types)

	if array_length(sys)>0
	{
		for(i=0;i==array_length(sys);i++)
		{
			part_system_destroy(global.pulse.systems[$sys[i]].index)
			if time_source_exists(global.pulse.systems[$sys[i]].count)
			{
				time_source_destroy(global.pulse.systems[$sys[i]].count,true)
			}
		}
		global.pulse.systems={}
		
		__pulse_show_debug_message("Systems destroyed",3);
	}
	
	if array_length(part)>0
	{
		for(i=0;i==array_length(part);i++)
		{
			part_type_destroy(global.pulse.part_types[$part[i]].index)
			if global.pulse.part_types[$part[i]].subparticle != undefined 
			{
				part_type_destroy(global.pulse.part_types[$part[i]].subparticle.index)
			}
		}
		global.pulse.part_types={}
		
		__pulse_show_debug_message("Particles destroyed",3);
	}
	
}	

#endregion

#region EXISTS

/// Checks if a system exists with the name provided as string or if its a struct.
/// Returns 1 = found , 0 = not found ,-1 = not a struct and not a string, create with default name
function pulse_exists_system	(_name)
{
	var system_found =  1 /// 2 found, ref on a variable, 1 = found , 0 = not found ,-1 = not a struct and not a string, create with default name , 
	
	if is_string(_name) 
	{
		if struct_exists(global.pulse.systems,_name)
		{
			system_found =  1 //found in storage
		}
		else
		{
			system_found =  0 //create with provided name
		}
	}
	else if  is_instanceof(_name,pulse_system)
	{
		system_found =  2 //found locally
	}
	else
	{
		system_found =  -1 //Not found, make 
	}
	
	return system_found
}

/// Checks if a particle exists with the name provided as string or if its a struct.
/// Returns 1 = found , 0 = not found ,-1 = not a struct and not a string, 2 = Particle struct
function pulse_exists_particle	(_name)
{
	var particle_found =  1 /// 1 = found , 0 = not found ,-1 = not a struct and not a string, create with default name
	
	if is_string(_name) 
	{
		if struct_exists(global.pulse.part_types,_name)
		{
			particle_found =  1 //found in storage
		}
		else
		{
			particle_found =  0 //create with provided name
		}
	}
	else if  is_instanceof(_name,__pulse_particle_class)
	{
		particle_found =  2 //found locally
	}
	else
	{
		 particle_found =  -1 //Not found, make 
	}
	
	return particle_found
}

/// Checks if a emitter exists with the name provided as string or if its a struct.
/// Returns 1 = found , 0 = not found ,-1 = not a struct and not a string, create with default name
function pulse_exists_emitter	(_name)
{
	var emitter_found =  1 /// 1 = found , 0 = not found ,-1 = not a struct and not a string, create with default name
	
	if is_string(_name) 
	{
		if struct_exists(global.pulse.emitters,_name)
		{
			emitter_found =  1 //found in storage
		}
		else
		{
			emitter_found =  0 //create with provided name
		}
	}
	else if  is_instanceof(_name,pulse_emitter)
	{
		if struct_exists(global.pulse.emitters,_name.name)
		{
			_name = _name.name
			emitter_found =  2 //found in storage
		}
		else
		{
			emitter_found =  3 //found locally
		}
	}
	else
	{
		 emitter_found =  -1 //Not found, make 
	}
	
	return emitter_found
}

#endregion

/// @description			   
///							Convert particle assets made with the Particle Editor into Pulse Particles. The emitter configuration is not copied.
///							Particles are named after the emitter they are on.
/// @param {Asset.GMParticleSystem}	part_system : The particle system asset you wish to convert.
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

#region IMPORTING / EXPORTING

//////// Particles

/// @description			   Exports a particle as a .pulsep file . Returns the file path as a string.
/// @param {Struct.__pulse_particle_class}	_particle : The particle you wish to export.

function pulse_export_particle	(_particle, file = undefined)
{
	if !is_instanceof(_particle,__pulse_particle_class) 
	{
		__pulse_show_debug_message($"Particle wasn't exported (Wrong type provided)",2)
		return
	}
	
	if file == undefined 
	{
		file = __PULSE_DEFAULT_DIRECTORY+$"particle_{_particle.name}.pulsep"
	}
	else if !directory_exists( filename_dir(file))
	{
		file = get_save_filename("*.pulsep", $"{_particle.name}.pulsep");
	
		if (file == "") return
	}
	
	if filename_ext(file) != ".pulsep"
	{
		file = filename_change_ext(file,".pulsep")
	}
		
	var	 _stringy = json_stringify(_particle , true),
			_buff = buffer_create(string_byte_length(_stringy), buffer_fixed, 1);
	
	buffer_write(_buff, buffer_text, _stringy);
	buffer_save(_buff, file);
	buffer_delete(_buff);
	
	__pulse_show_debug_message($"Particle '{_particle.name}' was exported succesfully.",3)
	return file
}

/// @description			Imports a particle saved as a .pulsep file in the safe directory and stores it. Returns a reference to the global storage.
/// @param {String}			_particle_file : The name of the file you wish to import, as a string.
/// @param {Bool}			_overwrite : Whether to overwrite a particle of the same name if it already exists (true) or not (false). DEFAULT: False
function pulse_import_particle	(_particle_file , _overwrite = false)
{	
	/// __assign
	/// @description			Assigns properties to the newly created particle
	/// @param {Sruct}			_parsed : the json parsed particle
	function __assign(_parsed)
	{
		var _new_part = new pulse_particle(_parsed.name)
		with _new_part
		{
				size					=	_parsed.size
				scale					=	_parsed.scale
				life					=	_parsed.life
				color					=	_parsed.color
				color_mode				=	_parsed.color_mode
				alpha					=	_parsed.alpha
				blend					=	_parsed.blend
				speed					=	_parsed.speed
				shape					=	_parsed.shape
				sprite					=	_parsed.sprite
				orient					=	_parsed.orient
				gravity					=	_parsed.gravity
				direction				=	_parsed.direction
				set_to_sprite			=	_parsed.set_to_sprite
				death_type				=	_parsed.death_type
				death_number			=	_parsed.death_number
				subparticle				=	_parsed.subparticle
				on_collision			=   _parsed.on_collision
				step_type				=	_parsed.step_type
				step_number				=	_parsed.step_number
				time_factor				=	_parsed.time_factor
				space_factor			=	_parsed.space_factor
				altered_acceleration	=	_parsed.altered_acceleration
			}
			if _new_part.step_type != undefined 
			{
				var _step = pulse_fetch_particle(_new_part.step_type.name)
					_step ??= __assign(_new_part.step_type)
					_new_part.set_step_particle(_new_part.step_number,_step)

			}
			if _new_part.death_type != undefined 
			{
				var _death = pulse_fetch_particle(_new_part.step_type.name)
				_death ??= __assign(_new_part.death_type)
				_new_part.set_death_particle(_new_part.death_number,_death)
			}
			if _new_part.subparticle != undefined 
			{
				var _subp = pulse_fetch_particle(_new_part.subparticle.death_type.name)
				 _subp ??= __assign(_new_part.subparticle.death_type)
				_new_part.set_death_on_collision(_new_part.subparticle.death_number,_subp)
			}
			
			return _new_part
	}
	
	if filename_ext(_particle_file) != ".pulsep"
	{
		__pulse_show_debug_message("Particle wasn't imported (Wrong type provided)",2)
		return
	}
	
	var _buffer = buffer_load(_particle_file)
		buffer_seek(_buffer, buffer_seek_start, 0);
	var _string = buffer_read(_buffer, buffer_string) ,
		_parsed = json_parse(_string) 
		buffer_delete(_buffer)
		
		var _exists = pulse_exists_particle(_parsed.name)
		if  ( _exists == 1 && _overwrite ) or _exists == 0
		{
			var _new_part = __assign(_parsed)
			_new_part.reset()
			__pulse_show_debug_message($"Particle {_new_part.name} was imported succesfully",)
			return  pulse_store_particle(_new_part,true)
		}

		// else return the existintg particle
		return global.pulse.part_types[$ _parsed.name];
}

//////// Systems

function pulse_export_system	(_system,file = undefined)
{
	if !is_instanceof(_system,pulse_system) 
	{
		__pulse_show_debug_message($"System wasn't exported (Wrong type provided)",2)
		return
	}
	
	if file == undefined 
	{
		file = __PULSE_DEFAULT_DIRECTORY+$"system_{_system.name}.pulses"
	}
	else if !directory_exists( filename_dir(file))
	{
		file = get_save_filename("*.pulses", $"{_system.name}.pulses");
		if (file == "") return
	}
	
	if filename_ext(file) != ".pulses"
	{
		file = filename_change_ext(file,".pulses")
	}
	
	var	 _stringy = json_stringify(_system , true),
			_buff = buffer_create(string_byte_length(_stringy), buffer_fixed, 1);
	
	buffer_write(_buff, buffer_text, _stringy);
	buffer_save(_buff, file);
	buffer_delete(_buff);
		
	__pulse_show_debug_message($"System '{_system.name}' was exported succesfully" ,3)

	return file
}

/// @description			Imports a system saved as a .pulsep file in the safe directory and stores it. Returns a reference to the global storage.
/// @param {String}			_system_file : The name of the file you wish to import, as a string.
/// @param {Bool}			_overwrite : Whether to overwrite a system of the same name if it already exists (true) or not (false). DEFAULT: False
function pulse_import_system	(_system_file, _overwrite = false)
{
	if filename_ext(_system_file) != ".pulses"	
	{
		__pulse_show_debug_message("System wasn't imported (Wrong type provided)",2)
		return
	}
	
	var _buffer = buffer_load(_system_file)
		buffer_seek(_buffer, buffer_seek_start, 0);
	var _string = buffer_read(_buffer, buffer_string) ,
		_parsed = json_parse(_string) 
		buffer_delete(_buffer)
		
		var _exists = pulse_exists_system(_parsed.name)
		if  ( _exists == 1 && _overwrite ) or _exists == 0
		{
				var _new_sys = new pulse_system(_parsed.name)
				with _new_sys{
					layer			=	_parsed.layer
					depth			=	_parsed.depth
					limit		=	_parsed.limit
					draw			=	_parsed.draw
					draw_oldtonew	=	_parsed.draw_oldtonew
					update			=	_parsed.update
					x				=	_parsed.x
					y				=	_parsed.y
					angle			=	_parsed.angle
					samples			=	_parsed.samples
					persistent		=	_parsed.persistent
					factor			=	_parsed.factor
					color			=	_parsed.color
					alpha			=	_parsed.alpha
					global_space	=	_parsed.global_space
					particle_amount =	_parsed.particle_amount
					wake_on_emit	=	_parsed.wake_on_emit
					sleep_when_empty=	_parsed.sleep_when_empty
				}

			_new_sys.reset()
			return  pulse_store_system(_new_sys,true)
		}

		// else return the existintg particle
		return global.pulse.systems[$ _parsed.name];
}

//////// Emitters

function pulse_export_emitter	(_emitter)
{

	if !is_instanceof(_emitter,pulse_emitter) 
	{
		__pulse_show_debug_message($"Emitter wasn't exported (Wrong type provided)",2)
		return
	}
	var file;
	
	if GM_is_sandboxed
	{
		if  !directory_exists(__PULSE_DEFAULT_DIRECTORY) directory_create("Pulse")
		file =  __PULSE_DEFAULT_DIRECTORY+$"emitter.pulsee"
	}
	else
	{
		file = get_save_filename("*.pulsee", $"emitter_");

		if (file == "") return
	}
	// Export particle and system
	var _fname = filename_change_ext(file,""),
	_fpartname = string_concat(_fname,"_particle",".pulsep"),
	_fsysname = string_concat(_fname,"_system",".pulses")
	
	if filename_ext(file) != ".pulsee"
	{
		file = filename_change_ext(file,".pulsee")
	}
	
	var _pfile = pulse_export_particle(_emitter.part_type,_fpartname)
	var _psys = pulse_export_system(_emitter.part_system,_fsysname)
		
	var	 _stringy = json_stringify(_emitter , true, function(key,value)
	{
		if key == "part_type_array" || key == "part_type" || key == "part_system_array" || key == "part_system"
		{
			return undefined
		}
		return value
	}),
		_buff = buffer_create(string_byte_length(_stringy), buffer_fixed, 1);
	
	buffer_write(_buff, buffer_text, _stringy)
	buffer_save(_buff, file);
	buffer_delete(_buff);
	
}

function pulse_import_emitter	(file, _overwrite = false)
{
	// Import Particle and System

	var _fname = filename_change_ext(file,""),
	_fpartname = string_concat(_fname,"_particle",".pulsep"),
	_fsysname = string_concat(_fname,"_system",".pulses")

	var _parta =  pulse_import_particle	(_fpartname,false),
	_part = pulse_store_particle(_parta) ,
	_sysa =  pulse_import_system(_fsysname,false),
	_sys = pulse_store_system(_sysa)

	
	var _buffer = buffer_load(file)
		buffer_seek(_buffer, buffer_seek_start, 0);
	var _string = buffer_read(_buffer, buffer_string) ,
		_parsed = json_parse(_string) 
		buffer_delete(_buffer)

		
	var _new_emitter  = new pulse_emitter(_sys,_part)
	with _new_emitter
	{
		#region Emitter Form
		stencil_mode		=	_parsed.stencil_mode
		form_mode			=	_parsed.form_mode
		path				=	_parsed.path
	if path == -1 && form_mode == PULSE_FORM.PATH 
	{
		form_mode = PULSE_FORM.ELLIPSE
		__pulse_show_debug_message("Path not found on import, replacing with ellipse")
	}
	path_res			=	_parsed.path_res
	stencil_tween		=	_parsed.stencil_tween
	radius_external		=	_parsed.radius_external
	radius_internal		=	_parsed.radius_internal
	edge_external		=	_parsed.edge_external
	edge_internal		=	_parsed.edge_internal
	mask_start			=	_parsed.mask_start
	mask_end			=	_parsed.mask_end
	mask_v_start		=	_parsed.mask_v_start
	mask_v_end			=	_parsed.mask_v_end
	line				=	_parsed.line

	#endregion
	
	#region Emitter properties
	x_focal_point		=	_parsed.x_focal_point
	y_focal_point		=	_parsed.y_focal_point
	x_scale				=	_parsed.x_scale
	y_scale				=	_parsed.y_scale
	stencil_offset		=	_parsed.stencil_offset
	direction_range		=	_parsed.direction_range
	#endregion
	
	#region Distributions
	distr_along_v_coord	=	_parsed.distr_along_v_coord
	distr_along_u_coord	=	_parsed.distr_along_u_coord
	distr_speed			=	_parsed.distr_speed
	distr_life			=	_parsed.distr_life
	distr_orient		=	_parsed.distr_orient
	distr_size			=	_parsed.distr_size
	distr_color_mix		=	_parsed.distr_color_mix
	distr_frame			=	_parsed.distr_frame
	divisions_v			=	_parsed.divisions_v
	divisions_u			=	_parsed.divisions_u
	divisions_v_offset	=	_parsed.divisions_v_offset
	divisions_u_offset	=	_parsed.divisions_u_offset
	#endregion
	
	#region Channels

	__color_mix_A		=	_parsed.__color_mix_A
	__color_mix_B		=	_parsed.__color_mix_B
	
if 	_parsed.__v_coord_channel	!=	undefined  || 	_parsed.__u_coord_channel	!=	undefined ||
	_parsed.__speed_channel		!=	undefined  ||	_parsed.__life_channel		!=	undefined ||
	_parsed.__orient_channel	!=	undefined  ||	_parsed.__size_x_channel	!=	undefined ||
	_parsed.__size_y_channel	!=	undefined  || 	_parsed.__color_mix_channel	!=	undefined ||
	_parsed.__frame_channel		!=	undefined
	{
		interpolations = animcurve_really_create( {curve_name : "interpolations" , channels : []})
		var _channels = []
		var _last = -1
		if _parsed.__v_coord_channel	!=	undefined
		{
		var current = _parsed.__v_coord_channel
		var channel				=  animcurve_channel_new()
			channel.name		= "v_coord"
			channel.type		= current.type
			channel.iterations	= current.iterations
			
			var points = current.points 
			var _l = array_length(points)
			var _new_channel = []
			for(_i = 0 ;_i<_l ;_i++)
			{
				animcurve_point_add(_new_channel,points[_i].posx,points[_i].value)
			}
				
			channel.points = _new_channel
			
			array_push(_channels,channel)

		}
		if _parsed.__u_coord_channel	!=	undefined
		{
			var current = _parsed.__u_coord_channel
			var channel				=  animcurve_channel_new()
				channel.name		= "u_coord"
				channel.type		= current.type
				channel.iterations	= current.iterations
			
				var points = current.points 
				var _l = array_length(points)
				var _new_channel = []
				for(_i = 0 ;_i<_l ;_i++)
				{
					animcurve_point_add(_new_channel,points[_i].posx,points[_i].value)
				}
				
				channel.points = _new_channel
			
				array_push(_channels,channel)
		}
		if _parsed.__speed_channel		!=	undefined
		{
			var current = _parsed.__speed_channel
			var channel				=  animcurve_channel_new()
				channel.name		= "speed"
				channel.type		= current.type
				channel.iterations	= current.iterations
			
				var points = current.points 
				var _l = array_length(points)
				var _new_channel = []
				for(_i = 0 ;_i<_l ;_i++)
				{
					animcurve_point_add(_new_channel,points[_i].posx,points[_i].value)
				}
				
				channel.points = _new_channel
			
				array_push(_channels,channel)
		}
		if _parsed.__life_channel		!=	undefined
		{
			var current = _parsed.__life_channel
			var channel				=  animcurve_channel_new()
				channel.name		= "life"
				channel.type		= current.type
				channel.iterations	= current.iterations
			
				var points = current.points 
				var _l = array_length(points)
				var _new_channel = []
				for(_i = 0 ;_i<_l ;_i++)
				{
					animcurve_point_add(_new_channel,points[_i].posx,points[_i].value)
				}
				
				channel.points = _new_channel
			
				array_push(_channels,channel)
		}
		if _parsed.__orient_channel		!=	undefined
		{
			var current = _parsed.__orient_channel
			var channel				=  animcurve_channel_new()
				channel.name		= "orient"
				channel.type		= current.type
				channel.iterations	= current.iterations
			
				var points = current.points 
				var _l = array_length(points)
				var _new_channel = []
				for(_i = 0 ;_i<_l ;_i++)
				{
					animcurve_point_add(_new_channel,points[_i].posx,points[_i].value)
				}
				
				channel.points = _new_channel
			
				array_push(_channels,channel)
		}
		if _parsed.__size_x_channel		!=	undefined
		{
			var current = _parsed.__size_x_channel
			var channel				=  animcurve_channel_new()
				channel.name		= "size_x"
				channel.type		= current.type
				channel.iterations	= current.iterations
			
				var points = current.points 
				var _l = array_length(points)
				var _new_channel = []
				for(_i = 0 ;_i<_l ;_i++)
				{
					animcurve_point_add(_new_channel,points[_i].posx,points[_i].value)
				}
				
				channel.points = _new_channel
			
				array_push(_channels,channel)
		}
		if _parsed.__size_y_channel		!=	undefined
		{
			var current = _parsed.__size_y_channel
			var channel				=  animcurve_channel_new()
				channel.name		= "size_y"
				channel.type		= current.type
				channel.iterations	= current.iterations
			
				var points = current.points 
				var _l = array_length(points)
				var _new_channel = []
				for(_i = 0 ;_i<_l ;_i++)
				{
					animcurve_point_add(_new_channel,points[_i].posx,points[_i].value)
				}
				
				channel.points = _new_channel
			
				array_push(_channels,channel)
		}
		if _parsed.__color_mix_channel	!=	undefined
		{
			var current = _parsed.__color_mix_channel
			var channel				=  animcurve_channel_new()
				channel.name		= "color_mix"
				channel.type		= current.type
				channel.iterations	= current.iterations
			
				var points = current.points 
				var _l = array_length(points)
				var _new_channel = []
				for(_i = 0 ;_i<_l ;_i++)
				{
					animcurve_point_add(_new_channel,points[_i].posx,points[_i].value)
				}
				
				channel.points = _new_channel
			
				array_push(_channels,channel)
		}
		if _parsed.__frame_channel		!=	undefined
		{
			var current = _parsed.__frame_channel
			var channel				=  animcurve_channel_new()
				channel.name		= "frame_channel"
				channel.type		= current.type
				channel.iterations	= current.iterations
			
				var points = current.points 
				var _l = array_length(points)
				var _new_channel = []
				for(_i = 0 ;_i<_l ;_i++)
				{
					animcurve_point_add(_new_channel,points[_i].posx,points[_i].value)
				}
				
				channel.points = _new_channel
			
				array_push(_channels,channel)
		}
	
		interpolations.channels = _channels
		
		if animcurve_channel_exists(interpolations,"v_coord")
		{
			distr_along_v_coord	= PULSE_DISTRIBUTION.ANIM_CURVE
			__v_coord_channel = animcurve_get_channel(interpolations,"v_coord")
		}
		if animcurve_channel_exists(interpolations,"u_coord")
		{
			distr_along_u_coord	= PULSE_DISTRIBUTION.ANIM_CURVE
			__u_coord_channel = animcurve_get_channel(interpolations,"u_coord")
		}
		if animcurve_channel_exists(interpolations,"speed")
		{
			distr_speed	= PULSE_DISTRIBUTION.ANIM_CURVE
			__speed_channel = animcurve_get_channel(interpolations,"speed")
		}
		if animcurve_channel_exists(interpolations,"life")
		{
			distr_life	= PULSE_DISTRIBUTION.ANIM_CURVE
			__life_channel = animcurve_get_channel(interpolations,"life")
		}
		if animcurve_channel_exists(interpolations,"orient")
		{
			distr_orient	= PULSE_DISTRIBUTION.ANIM_CURVE
			__orient_channel = animcurve_get_channel(interpolations,"orient")
		}
		if animcurve_channel_exists(interpolations,"size_x")
		{
			distr_size	= PULSE_DISTRIBUTION.ANIM_CURVE
			__size_x_channel = animcurve_get_channel(interpolations,"size_x")
		}
		if animcurve_channel_exists(interpolations,"size_y")
		{
			distr_size	= PULSE_DISTRIBUTION.ANIM_CURVE
			__size_y_channel = animcurve_get_channel(interpolations,"size_y")
		}
		if animcurve_channel_exists(interpolations,"color_mix")
		{
			distr_color_mix	= PULSE_DISTRIBUTION.ANIM_CURVE
			__color_mix_channel = animcurve_get_channel(interpolations,"color_mix")
		}
		if animcurve_channel_exists(interpolations,"frame")
		{
			distr_color_mix	= PULSE_DISTRIBUTION.ANIM_CURVE
			__frame_channel = animcurve_get_channel(interpolations,"frame")
		}
	}
	
	__speed_link			=	_parsed.__speed_link
	__life_link				=	_parsed.__life_link	
	__orient_link			=	_parsed.__orient_link
	__size_link				=	_parsed.__size_link	
	__color_mix_link		=	_parsed.__color_mix_link
	__frame_link			=	_parsed.__frame_link	

	__speed_weight			=	_parsed.__speed_weight
	__life_weight			=	_parsed.__life_weight
	__orient_weight			=	_parsed.__orient_weight
	__size_weight			=	_parsed.__size_weight
	__color_mix_weight		=	_parsed.__color_mix_weight
	__frame_weight			=	_parsed.__frame_weight
	
	#endregion
	
	boundary			=	_parsed.boundary
	alter_direction		=	_parsed.alter_direction	
	
	//Image maps
	displacement_map	=	_parsed.displacement_map
	color_map			=	_parsed.color_map			

	//Forces, Groups, Colliders
	forces				=	_parsed.forces
		// collisions
	collisions			=	_parsed.collisions
	is_colliding		=	_parsed.is_colliding
	colliding_entities	=	_parsed.colliding_entities
	
	debug_col_rays		=	_parsed.debug_col_rays
	
	
	/// Anim curve conversion
	var points = _parsed.stencil_profile.channels[0].points ,
	_l = array_length(points)
	var _stencil_profile_a = []
	for(var _i = 0 ;_i<_l ;_i++)
	{
		animcurve_point_add(_stencil_profile_a,points[_i].posx,points[_i].value)
	}
	animcurve_points_set(stencil_profile,"a",_stencil_profile_a)
	
	//------
	var points = _parsed.stencil_profile.channels[1].points ,
	_l = array_length(points)
	var _stencil_profile_b = []
	for(_i = 0 ;_i<_l ;_i++)
	{
		animcurve_point_add(_stencil_profile_b,points[_i].posx,points[_i].value)
	}
	animcurve_points_set(stencil_profile,"b",_stencil_profile_b)

	//------
	points = _parsed.stencil_profile.channels[2].points 
	_l = array_length(points)
	var _stencil_profile_c = []
	for(_i = 0 ;_i<_l ;_i++)
	{
		animcurve_point_add(_stencil_profile_c,points[_i].posx,points[_i].value)
	}
	animcurve_points_set(stencil_profile,"c",_stencil_profile_c)

	_channel_01			=	animcurve_get_channel(stencil_profile,0)
	_channel_02			=	animcurve_get_channel(stencil_profile,1)
	_channel_03			=	animcurve_get_channel(stencil_profile,2)
			

			}
	return  _new_emitter
}

/////// Cache

function pulse_export_cache	(_cache,_cache_name,file = undefined)
{
	if !is_instanceof(_cache,pulse_cache) 
	{
		__pulse_show_debug_message($"System wasn't exported (Wrong type provided)",2)
		return
	}
	_cache_name = string(_cache_name)
	
	if file == undefined 
	{
		file = __PULSE_DEFAULT_DIRECTORY+$"cache_{_cache_name}.pulsec"
	}
	else if !directory_exists( filename_dir(file))
	{
		file = get_save_filename("*.pulsec", $"{_cache_name}.pulsec")
		if (file == "") return
	}
	
	if filename_ext(file) != ".pulsec"
	{
		file = filename_change_ext(file,".pulsec")
	}
	
	var	 _stringy = json_stringify(_cache , true),
			_buff = buffer_create(string_byte_length(_stringy), buffer_fixed, 1);
	
	buffer_write(_buff, buffer_text, _stringy);
	buffer_save(_buff, file);
	buffer_delete(_buff);
		
	__pulse_show_debug_message($"Cache '{_cache_name}' was exported succesfully" ,3)

	return file
}

function pulse_import_cache	(_cache_file, _overwrite = false)
{
	if filename_ext(_cache_file) != ".pulsec"	
	{
		__pulse_show_debug_message("Cache wasn't imported (Wrong type provided)",2)
		return
	}


	var _buffer = buffer_load(_cache_file)
	
	if _buffer == -1 return undefined
	
		buffer_seek(_buffer, buffer_seek_start, 0);
	var _string = buffer_read(_buffer, buffer_string) ,
		_parsed = json_parse(_string) 
		buffer_delete(_buffer)

	var _new_cache = new pulse_cache(_parsed,_parsed.cache)

	_new_cache.shuffle				= _parsed.shuffle

	var _exists = pulse_exists_system(_parsed.part_system.name)
	var _sys = pulse_fetch_system(_parsed.part_system.name)
	if  _sys == undefined
	{
		__pulse_show_debug_message("Cache imported doesn't have a system. Please assign one before use",2)
	}
	_new_cache.part_system = _sys

	return _new_cache
}

#endregion

#region STORE / FETCH

/// @description			Stores a Pulse Particle into the global struct. Allows the use of the particle by calling its name as a string. Returns a reference to the global struct.
/// @param {Struct.__pulse_particle_class}	_particle : Pulse Particle to store.
/// @param {Bool}							[_override] : If there is a particle by the same name, override it (true) or change the new particle's name (false).
/// @return {Struct}
function pulse_store_particle		(_particle,_override = false)
{
	// If using the default name, count particles and rename so there are no repeated entries
		/// Check if it is a Pulse Particle
	if !is_instanceof(_particle,__pulse_particle_class)
	{
		__pulse_show_debug_message("Argument provided is not a Pulse Particle",3)
		return
	}
	
	var _name =  _particle.name
	
	if  pulse_exists_particle(_name) > 0
	{
		if !_override
		{
			/// Change name if the name already exists
			var l		=	struct_names_count(global.pulse.part_types)		
			_name		=	$"{_name}_{l}";	
			_particle.name = _name
		}
		else
		{
			pulse_destroy_particle(_particle.name)
		}
	}
	
	__pulse_show_debug_message($" Stored particle \"{_name}\"",3);
		global.pulse.part_types[$_name] = variable_clone(_particle)
		return  global.pulse.part_types[$_name]
}

/// @description			Fetches a Pulse Particle from the global struct. Returns a reference to the global struct, or undefined if particle is not found.
/// @param {String}	_particle : Pulse Particle name to fetch.
/// @return {Struct}
function pulse_fetch_particle		(_name)
{
	/// Check if it is a Pulse System
	if !is_string(_name)
	{
		__pulse_show_debug_message("Argument provided is not a String",3)
		return undefined
	}
	
	if pulse_exists_particle(_name) > 0 
	{
		return global.pulse.part_types[$_name]
	}
	
	__pulse_show_debug_message($"System named '{_name}' not found",3);
	
	return undefined
}

/// @description			Store a emitter in Pulse's Global storage. If there is a emitter of the same name it will override it or change the name.
/// @param {Struct.pulse_emitter}			_emitter : Pulse emitter to store
/// @param {String}			_name : Name for the emitter
/// @param {Bool}			_override	: Whether to override a emitter by the same name or to change the name of the emitter.
/// @return {Struct}
function pulse_store_emitter			(_emitter,_name , _override = false)
{
	/// Check if it is a Pulse emitter
	if !is_instanceof(_emitter,pulse_emitter)
	{
		__pulse_show_debug_message("Argument provided is not a Pulse emitter",3)
		return
	}
	
	_emitter.name = string(_name)

	if pulse_exists_emitter(_name) > 0 && !_override
	{
		/// Change name if the name already exists
		var l		=	struct_names_count(global.pulse.emitters)		
		_name		=	$"{_name}_{l}";	
		_emitter.name = _name
	}
	
	__pulse_show_debug_message($"Created emitter by the name {_name}",3);
	global.pulse.emitters[$_name] = variable_clone(_emitter)
	return  global.pulse.emitters[$_name]
}

/// @description			Fetches a Pulse emitter from the global struct. Returns a reference to the global struct.
/// @param {String}	_name : Pulse emitter name to fetch, as a string.
/// @return {Struct}
function pulse_fetch_emitter			(_name)
{
	/// Check if it is a Pulse emitter
	if !is_string(_name)
	{
		__pulse_show_debug_message("Argument provided is not a String",3)
		return undefined
	}
	
	if pulse_exists_emitter(_name) > 0 
	{
		return global.pulse.emitters[$_name]
	}
	
	__pulse_show_debug_message($"emitter named '{_name}' not found",3);
	
	return undefined
}

/// @description			Store a system in Pulse's Global storage. If there is a system of the same name it will override it or change the name.
/// @param {Struct.pulse_system}			_system : Pulse System to store
/// @param {Bool}			_override	: Whether to override a system by the same name or to change the name of the system.
/// @return {Struct}
function pulse_store_system			(_system,_override = false)
{
	/// Check if it is a Pulse System
	if !is_instanceof(_system,pulse_system)
	{
		__pulse_show_debug_message("Argument provided is not a Pulse System",3)
		return
	}
	
	var _name =  _system.name

	if pulse_exists_system(_name) > 0 
	{
		if !_override
		{
			/// Change name if the name already exists
			var l		=	struct_names_count(global.pulse.systems)		
			_name		=	$"{_name}_{l}";	
			_system.name = _name
		}
		else
		{
			pulse_destroy_system(_name)	
		}	
	}
	
	__pulse_show_debug_message($"Created system by the name {_name}",3);
	global.pulse.systems[$_name] = variable_clone(_system)
	return  global.pulse.systems[$_name]
}

/// @description			Fetches a Pulse System from the global struct. Returns a reference to the global struct.
/// @param {String}	_name : Pulse System name to fetch, as a string.
/// @return {Struct}
function pulse_fetch_system			(_name)
{
	/// Check if it is a Pulse System
	if !is_string(_name)
	{
		__pulse_show_debug_message("Argument provided is not a String",3)
		return undefined
	}
	
	if pulse_exists_system(_name) > 0 
	{
		return global.pulse.systems[$_name]
	}
	
	__pulse_show_debug_message($"System named '{_name}' not found",3);
	
	return undefined
}

#endregion