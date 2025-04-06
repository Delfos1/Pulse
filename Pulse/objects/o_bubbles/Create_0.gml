/// @description Insert description here

bubble = pulse_make_particle("bubble")
bubble.set_shape(pt_shape_circle).set_color(c_white).set_speed(1,2,.0002).set_alpha(.8,.5,0).set_size(1,1)
.set_orient(0,0,0,0,false).set_life(600,600).set_direction(90,90,0,5)

bubble2 =pulse_make_particle("bubble2")
bubble2.set_shape(pt_shape_circle).set_color(c_white).set_speed(3,5,.0003).set_alpha(.8,.5,0).set_size(1,1)
.set_orient(0,0,0,0,false).set_life(600,600).set_direction(90,90,0,5)

system = pulse_make_system("bubble_sys")

///
emit = new pulse_emitter(system,"bubble")
emit2 = new pulse_emitter(system,"bubble2")
emit.force_to_edge=PULSE_TO_EDGE.NONE
emit.alter_direction=false
emit2.force_to_edge=PULSE_TO_EDGE.NONE
emit2.alter_direction=false
emit.set_mask(.20,.30).set_radius(0,30)
emit2.set_mask(.20,.30).set_radius(0,30)


// SINE WAVES SETUP

t = 0;
increment = 5; //degrees 
amplitude = .01; //acceleration 
_sign=1

t2 = 0;
t3 = 0;
increment2 = 5; //degrees 
increment3 = 7; //degrees 
amplitude2 = .005; //acceleration 
_sign2=1

var callback = function()
{
	emit.pulse(1,x,y)
	emit2.pulse(3,x,y)
}

_alarm = time_source_create(time_source_game,50,time_source_units_frames,callback,[],-1)

time_source_start(_alarm )



