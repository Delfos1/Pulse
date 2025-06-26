debug = true
show_debug_overlay(debug)


// Welcome to Pulse!
pulse_destroy_particle("a_particle_name")

/*var _p = get_open_filename("*.pulse","")


particle = pulse_import_particle(_p,true) /* new pulse_particle("a_particle_name")*/

//particle = pulse_store_particle(particle)

var _e = get_open_filename("*.pulse","")
emitter= pulse_import_emitter(_e)
system = pulse_fetch_system("sys_1")
particle = pulse_fetch_particle("a_particle_name")
/*
emitter.set_radius(50,300,50,800).set_distribution_size(PULSE_DISTRIBUTION.LINKED,[sizeToU,"x","y"],PULSE_LINK_TO.DIRECTION).set_distribution_color_mix(c_lime,c_yellow,PULSE_DISTRIBUTION.LINKED,[colorToV,0],PULSE_LINK_TO.SPEED)
emitter.set_mask_spread(0,75)
emitter.boundary=PULSE_BOUNDARY.LIFE
*/
//sys.add_collisions(o_Collider)
//sys.set_stencil(ac_empty,"curve1")
//sys.set_stencil(ac_Shape,"Star")
//cache = sys.pulse(300,0,0,true)
