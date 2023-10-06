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
		
		__pulse_show_debug_message("PULSE SUCCESS: Systems destroyed");
	}
	
	if array_length(part)>0
	{
		for(i=0;i==array_length(global.pulse.part_types);i++)
		{
			part_type_destroy(global.pulse.part_types[$part[i]].index)
		}
		global.pulse.part_types={}
		
		__pulse_show_debug_message("PULSE SUCCESS: Particles destroyed");
	}
	
}	

// Will create a new system and reference the previous struct
function pulse_clone_system(__name,__new_name=__name)
{
	if  !struct_exists(global.pulse.systems,__name)
	{
		__pulse_show_debug_message($"PULSE ERROR: Couldn't find a particle by the name {__name}");
		exit;
	}
		
	if __name == __new_name
	{
	__new_name= __name+"_copy";
	}
		
	global.pulse.systems[$__new_name]		=	variable_clone(global.pulse.systems[$__name])
	global.pulse.systems[$__new_name].index	=	part_type_create();
	global.pulse.systems[$__new_name].reset()

	__pulse_show_debug_message($"PULSE SUCCESS: Particle {__name} cloned and named {__new_name}");
	
	return global.pulse.systems[$__new_name]
}
// Will create a new particle and reference the previous struct
function pulse_clone_particle(__name,__new_name=__name)
{

	if  !struct_exists(global.pulse.part_types,__name)
	{
		__pulse_show_debug_message($"PULSE ERROR: Couldn't find a particle by the name {__name}");
		exit;
	}
		
	if __name == __new_name
	{
	__new_name= __name+"_copy";
	}
		
	global.pulse.part_types[$__new_name]		=	variable_clone(global.pulse.part_types[$__name])
	global.pulse.part_types[$__new_name].index	=	part_type_create();
	global.pulse.part_types[$__new_name].reset()

	__pulse_show_debug_message($"PULSE SUCCESS: Particle {__name} cloned and named {__new_name}");
	
	return global.pulse.part_types[$__new_name]
}

function pulse_destroy_system(_name)
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

function pulse_destroy_particle(_name)
{
	if struct_exists(global.pulse.part_types,_name)
	{
		part_type_destroy(global.pulse.part_types[$_name].index)
		variable_struct_remove(global.pulse.part_types,_name)
	}

}

/// Checks if a system exists with the name provided as string or if its a struct.
/// Returns 1 = found , 0 = not found ,-1 = not a struct and not a string, create with default name
function pulse_exists_system(_name)
{
	var system_found =  1 /// 2 found, ref on a variable, 1 = found , 0 = not found ,-1 = not a struct and not a string, create with default name , 
	
	if is_string(_name) 
	{
		if struct_exists(global.pulse.systems,_name)
		{
			system_found =  1 //found in struct
		}
		else
		{
			system_found =  0 //create with provided name
		}
	}
	else if  is_instanceof(_name,__pulse_system)
	{
		if struct_exists(global.pulse.systems,_name.name)
		{
			system_found =  2 //found in struct
		}
		else
		{
			system_found =  3 //found locally
		}
	}
	else
	{
		system_found =  -1 //Not found, make 
	}
	
	return system_found
}

/// Checks if a particle exists with the name provided as string or if its a struct.
/// Returns 1 = found , 0 = not found ,-1 = not a struct and not a string, create with default name
function pulse_exists_particle(_name)
{
	var particle_found =  1 /// 1 = found , 0 = not found ,-1 = not a struct and not a string, create with default name
	
	if is_string(_name) 
	{
		if struct_exists(global.pulse.part_types,_name)
		{
			particle_found =  1 //found in struct
		}
		else
		{
			particle_found =  0 //create with provided name
		}
	}
	else if  is_instanceof(_name,__pulse_particle)
	{
		if struct_exists(global.pulse.part_types,_name.name)
		{
			_name = _name.name
			particle_found =  2 //found in struct
		}
		else
		{
			particle_found =  3 //found locally
		}
	}
	else
	{
		 particle_found =  -1 //Not found, make 
	}
	
	return particle_found
}
