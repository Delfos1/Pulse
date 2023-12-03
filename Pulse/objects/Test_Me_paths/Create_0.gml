debug = true
show_debug_overlay(debug)


system = pulse_make_system("sys_1")

sys= new pulse_local_emitter("sys_1","particle")


global.pulse.part_types.particle.set_speed(1,5,-.002).set_life(20,50).set_size(0.1,0.35,-.002).set_color(c_yellow,c_lime)
	


sys.set_radius(0,100)
sys.force_to_edge=PULSE_TO_EDGE.LIFE

sys.add_collisions(Object23)
sys.set_stencil(ac_empty,"curve1")


sys.form_path(Path3)
