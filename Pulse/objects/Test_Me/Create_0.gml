debug = true
show_debug_overlay(debug)

// Welcome to Pulse!

system = new pulse_system("sys_1")
system = pulse_store_system(system)
particle = new pulse_particle("a_particle_name")
particle = pulse_store_particle(particle)

emitter= new pulse_emitter("sys_1","a_particle_name")

particle.set_speed(1,6,-.002)
			.set_life(20,50)
			.set_size(0.1,0.35,-.002)
			.set_color(c_yellow,c_lime)//.set_death_on_collision(10,particle_on_death)
		
emitter	.set_radius(50,300,50,800)
		.set_distribution_size(PULSE_DISTRIBUTION.LINKED,[sizeToU,"x","y"],PULSE_LINK_TO.DIRECTION)
		.set_distribution_color_mix(c_lime,c_yellow,PULSE_DISTRIBUTION.LINKED,[colorToV,0],PULSE_LINK_TO.SPEED)
emitter	.set_mask_spread(0,75)
emitter	.force_to_edge=PULSE_TO_EDGE.LIFE

//sys.add_collisions(o_Collider)
//sys.set_stencil(ac_empty,"curve1")
//sys.set_stencil(ac_Shape,"Star")
//cache = sys.pulse(300,0,0,true)
