particle = pulse_make_particle("snow")
system = pulse_make_system("sys")
/*
particle.set_life(900,900).set_speed(.75,1.15,-.0002).set_direction(0,0,0)
.set_size(.3,.5,-0.0005).set_shape(pt_shape_snow).set_orient(0,359,0.2,0,false)
.set_color(c_white,c_aqua).set_alpha(.9,.7,0)
*/

particle.set_life(700,900).set_speed(.70,1.10,-.0002).set_direction(0,0,0)
.set_size(.3,.4,-0.0001).set_sprite(pt_snow_cartoon).set_orient(0,359,0.2,0,false)
.set_color(c_white,c_aqua).set_alpha(.9,.7,0)


emit = new pulse_local_emitter(system,"snow")
emit.form_line(room_width+100,0).set_direction_range(180,180)
emit.force_to_edge=PULSE_TO_EDGE.NONE


t = 0;
increment = 1; //degrees 
amplitude = .0025; //acceleration 
_sign = 1

repeat(particle.life[1])
{
	event_perform(ev_step,ev_step_normal)
	system.update_system()
}