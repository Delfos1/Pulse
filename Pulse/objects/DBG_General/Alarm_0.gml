
 var particle		= pulse_store_particle( new pulse_particle("Particle")) ,
	 system			= pulse_store_system(new pulse_system("System")),
	 emitter		= pulse_store_emitter(new pulse_emitter(system,particle),"Default 1"),
particle_instance	= instance_create_layer(0,0,layer,DBG_Particle,{particle: particle, active:1}),
system_instance		= instance_create_layer(0,0,layer,DBG_System,{system: system}),
emitter_instance	= instance_create_layer(random_range(1300,1600),random_range(300,600),layer,DBG_Emitter,{emitter: emitter, system_instance: system_instance , particle_instance : particle_instance})


emitter.set_displacement_map(displ_map[0])
emitter.set_color_map(color_map)
	
array_push(particles,particle_instance)
array_push(systems,system_instance)
array_push(emitters,emitter_instance)
