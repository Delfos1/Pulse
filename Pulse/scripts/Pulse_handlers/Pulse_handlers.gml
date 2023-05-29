function pulse_destroy_all()
{	var sys, part, i
	
	sys		= struct_get_names(global.pulse.systems)
	part	= struct_get_names(global.pulse.part_types)

	for(i=0;i==array_length(sys);i++)
	{
	part_system_destroy(global.pulse.systems[$sys[i]].index)
	}
	global.pulse.systems={}
	
	
	for(i=0;i==array_length(global.pulse.part_types);i++)
	{
	part_type_destroy(global.pulse.part_types[$part[i]]._index)
	}
	global.pulse.part_types={}
	
	show_debug_message("PULSE SUCCESS: Systems and Particles destroyed");
}	


// Will create a new system and reference the previous struct
function pulse_clone_system(__name,__new_name)
{
	if  !struct_exists(global.pulse.systems,__name)
	{
		show_debug_message("PULSE ERROR: Couldn't find a particle by the name {0}",__name);
		exit;
	}
		
	if __name == __new_name
	{
	__new_name= __name+"_copy";
	}
		
	global.pulse.systems[$__new_name]		=	variable_clone(global.pulse.systems[$__name])
	global.pulse.systems[$__new_name].index	=	part_type_create();
	global.pulse.systems[$__new_name].reset()

	show_debug_message("PULSE SUCCESS: Particle {0} cloned and named {1}",__name,__new_name);
	
	return global.pulse.systems[$__new_name]
}
// Will create a new particle and reference the previous struct
function pulse_clone_particle(__name,__new_name)
{

	if  !struct_exists(global.pulse.part_types,__name)
	{
		show_debug_message("PULSE ERROR: Couldn't find a particle by the name {0}",__name);
		exit;
	}
		
	if __name == __new_name
	{
	__new_name= __name+"_copy";
	}
		
	global.pulse.part_types[$__new_name]		=	variable_clone(global.pulse.part_types[$__name])
	global.pulse.part_types[$__new_name]._index	=	part_type_create();
	global.pulse.part_types[$__new_name].reset()

	show_debug_message("PULSE SUCCESS: Particle {0} cloned and named {1}",__name,__new_name);
	
	return global.pulse.part_types[$__new_name]
}
