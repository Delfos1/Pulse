particle = pulse_make_particle("snow")
system = pulse_make_system("sys")

particle.set_life(900,900).set_speed(.75,1.15,-.0002).set_direction(0,0,0)
.set_size(.3,.5,-0.0005).set_shape(pt_shape_snow).set_orient(0,359,0.2,0,false)
.set_color(c_white,c_aqua).set_alpha(.9,.7,0)

emit = new pulse_local_emitter(system,"snow")
emit.form_line(room_width,0).set_direction_range(180,180)//(160,200)
emit.force_to_edge=PULSE_TO_EDGE.NONE

/*
force = new pulse_force(300,300,90,PULSE_FORCE.DIRECTION,1,.4)
force.set_range_directional(-1,0,100,650)
emit.add_local_force(force)*/


t = 0;
increment = 1; //degrees 
amplitude = .0025; //acceleration 
_sign = 1

repeat(768)
{
	event_perform(ev_step,ev_step_normal)
	//part_system_update(system.index)
	system.update_system()
}