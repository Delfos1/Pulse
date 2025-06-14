debug = true
show_debug_overlay(debug)

// Welcome to Pulse!

system = pulse_store_system( new pulse_system("sys_1") )


particle =  new pulse_particle("a_particle_name")

particle.set_sprite(s_hand)
		.set_speed(1,6,-.002)
		.set_life(20,50)
		.set_size(1,1.35,-.002)
		.set_color(c_yellow,c_lime)
		
pulse_store_particle(particle)
		
emitter = new pulse_emitter("sys_1","a_particle_name");

emitter.set_radius(0,300,50,300);
emitter.set_distribution_size(PULSE_DISTRIBUTION.LINKED,[sizeToU,"x","y"],PULSE_LINK_TO.DIRECTION)
emitter.set_distribution_color_mix(c_lime,c_yellow,PULSE_DISTRIBUTION.LINKED,[colorToV,0],PULSE_LINK_TO.SPEED)
//emitter	.set_mask_spread(0,75)
emitter.force_to_edge  = PULSE_TO_EDGE.SPEED
//emitter.form_path(Path10)
emitter.add_collisions(o_Collider)
emitter.set_stencil(ac_Shape,"Star")
//cache = sys.pulse(300,0,0,true)
pulse_export_emitter(emitter)
