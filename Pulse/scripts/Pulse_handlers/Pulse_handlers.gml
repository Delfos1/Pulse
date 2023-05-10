function pulse_destroy_all()
{
	var i;
	for(i=0;i==array_length(global.pulse.systems);i++)
	{
	part_system_destroy(global.pulse.systems[i]._system)
	}
	global.pulse.systems=0
	
	var i;
	for(i=0;i==array_length(global.pulse.part_types);i++)
	{
	part_type_destroy(global.pulse.part_types[i]._ind)
	}
	global.pulse.part_types=0
	
	show_debug_message("PULSE SUCCESS: Systems and Particles destroyed");
}	

function pulse_system_get_ID(__name)
{
	var i = 0
	var array = global.pulse.systems
	var array_l = array_length(array)
	
	// ARRAY IS EMPTY
	if	array_l == 0
	{
		show_debug_message("PULSE ERROR: Couldn't find a system by the name {0}",__name);
		return -1
	}
	
	//ELSE SEARCH FOR NAME
	while (array[i]._name!=__name)
	{
		i++
		
		if  i>=array_l
		{
			show_debug_message("PULSE ERROR: Couldn't find a system by the name {0}",__name);
			return -1
		}
	}
	
	return array[i]._system
}

function pulse_particle_get_ID(__name)
{
	var i = 0
	var array = global.pulse.part_types
	var array_l = array_length(array)
	
	// ARRAY IS EMPTY
	if	array_l == 0
	{
		show_debug_message("PULSE ERROR: Couldn't find a particle by the name {0}",__name);
		return -1
	}
	
	//ELSE SEARCH FOR NAME
	while (array[i]._name!=__name)
	{
		i++
		
		if  i>=array_l
		{
			show_debug_message("PULSE ERROR: Couldn't find a particle by the name {0}",__name);
			return -1
		}
	}
	
	return array[i]
}


// Will create a new system and reference the previous struct
function pulse_reference_system(__name,__new_name)
{
	var i = 0
	var array = global.pulse.systems
	var array_l = array_length(array)
	
	if	array_l == 0
	{
		show_debug_message("PULSE ERROR: Couldn't find a system by the name {0}",__name);
		exit;
	}
	
	while (array[i]._name!=__name)
	{
		i++
		
		if  i==array_l
		{
			show_debug_message("PULSE ERROR: Couldn't find a system by the name {0}",__name);
			exit;
		}
	}
	array_copy(array,array_l,array,i,1)
	
	if __name == __new_name
	{
	__new_name= __name+"_copy";
	}
	
	array[array_l]._name	=	string(__new_name)	
	array[array_l]._system	=	part_system_create();
	show_debug_message("PULSE SUCCESS: System {0} referenced and named {1}",__name,__new_name);
	return array[array_l]
}
// Will create a new particle and reference the previous struct
function pulse_reference_particle(__name,__new_name)
{
	var i = 0
	var array = global.pulse.part_types
	var array_l = array_length(array)
	
	if	array_l == 0
	{
		show_debug_message("PULSE ERROR: Couldn't find a particle by the name {0}",__name);
		exit;
	}
	
	while (array[i]._name!=__name)
	{
		i++
		
		if  i==array_l
		{
			show_debug_message("PULSE ERROR: Couldn't find a particle by the name {0}",__name);
			exit;
		}
	}
	array_copy(array,array_l,array,i,1)
	
	if __name == __new_name
	{
	__new_name= __name+"_copy";
	}
	
	array[array_l]._name		=	string(__new_name)	
	array[array_l]._ind	=	part_type_create();
	array[array_l].reset();
	show_debug_message("PULSE SUCCESS: Particle {0} referenced and named {1}",__name,__new_name);
	return array[array_l]
}

// Will create a new system and reference the previous struct
function pulse_clone_system(__name,__new_name)
{
	var i = 0
	var array = global.pulse.systems
	var array_l = array_length(array)
	
	if	array_l == 0
	{
		show_debug_message("PULSE ERROR: Couldn't find a system by the name {0}",__name);
		exit;
	}
	
	while (array[i]._name!=__name)
	{
		i++
		
		if  i==array_l
		{
			show_debug_message("PULSE ERROR: Couldn't find a system by the name {0}",__name);
			exit;
		}
	}
	array_copy(array,array_l,array,i,1)
	
	if __name == __new_name
	{
	__new_name= __name+"_copy";
	}
	
	array[array_l]._name	=	string(__new_name)	
	array[array_l]._system	=	part_system_create();
	show_debug_message("PULSE SUCCESS: System {0} referenced and named {1}",__name,__new_name);
	return array[array_l]
}
// Will create a new particle and reference the previous struct
function pulse_clone_particle(__name,__new_name)
{
	var i = 0
	var array = global.pulse.part_types
	var array_l = array_length(array)
	
	if	array_l == 0
	{
		show_debug_message("PULSE ERROR: Couldn't find a particle by the name {0}",__name);
		exit;
	}
	
	while (array[i]._name!=__name)
	{
		i++
		
		if  i==array_l
		{
			show_debug_message("PULSE ERROR: Couldn't find a particle by the name {0}",__name);
			exit;
		}
	}
	
	if __name == __new_name
	{
	__new_name= __name+"_copy";
	}
	
	array[array_l]				=	variable_clone(array[i])
	array[array_l]._name		=	string(__new_name)	
	array[array_l]._ind	=	part_type_create();
	array[array_l].reset();
	show_debug_message("PULSE SUCCESS: Particle {0} cloned and named {1}",__name,__new_name);
	return array[array_l]
}
