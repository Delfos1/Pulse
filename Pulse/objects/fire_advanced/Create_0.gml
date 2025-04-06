show_debug_overlay(true)

particle = pulse_make_particle("fire")
system = pulse_make_system("sys").set_draw(false)

system2 = pulse_make_system("sys2").set_draw(false)

//--------- BIG FLAMES

particle.set_life(40,60).set_speed(6,8)
.set_size(.5,.8,-0.0008).set_sprite(flame_01,)
.set_color(c_orange,c_maroon,#200020).set_alpha(.9,.7,.1).set_orient(90,90,0,0,false)//.set_blend(true)//

emit = new pulse_emitter(system,"fire")
emit.force_to_edge=PULSE_TO_EDGE.FOCAL_LIFE
emit.set_focal_point(0,-500).set_direction_range(178,188).form_line(160,0).set_radius(0,26)

// -------- SMALLER FLAMES AT BASE

particle_2 = pulse_clone_particle("fire","fire_2")
.set_color(c_white,c_yellow,c_yellow).set_speed(1,3).set_size(.2,.6,-0.0008).set_orient(0,0,0,0,true).set_life(10,30)
.set_alpha(.9,.7,.1).set_blend(true)

emit_smaller = new pulse_emitter(system2,"fire_2")
emit_smaller.force_to_edge=PULSE_TO_EDGE.FOCAL_LIFE
emit_smaller.set_focal_point(50,-150).set_direction_range(180,180)
emit_smaller.form_line(160,0).set_radius(0,0)


/// --- Sparks

sparks =  pulse_make_particle("sparks")

sparks.set_shape(pt_shape_line).set_color(c_yellow,c_red).set_size(.1,.2,-0.0005).set_life(30,100).set_orient(0,0,0,0,true)
.set_alpha(.9,.7,.1).set_blend(false).set_speed(4,10,-.05).set_scale(1,.5).set_gravity(.02,270)

emit_spark = new pulse_emitter(system2,"sparks")
emit_spark.form_line(0,100).set_radius(-50,50).set_direction_range(35,90)
emit_spark.force_to_edge=PULSE_TO_EDGE.NONE

// SINE WAVES SETUP

t = 0;
increment = 10; //degrees 
amplitude = 45; //acceleration 

t2 = 0;
increment2 = 4; //degrees 
amplitude2 = 25; //acceleration 

///--- Displ map vars

xx = 0
yy = 0

