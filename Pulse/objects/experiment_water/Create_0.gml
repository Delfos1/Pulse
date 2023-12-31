
pulse_make_particle("water").set_size(.35,.35).set_shape(pt_shape_sphere).set_life(7,40).set_speed(03,10,-.15).set_alpha(.7,.2).set_gravity(.45,270)
pulse_make_particle("water_2").set_size(.2,.3).set_shape(pt_shape_sphere).set_life(50,80).set_speed(2,3,-.05).set_color(c_blue).set_alpha(1,.7,0)

front = pulse_make_system("front")
back = pulse_make_system("back")

front.set_draw(false)
back.set_draw(false)


emitter= new pulse_local_emitter("back","water")

emitter.set_scale(1,.5).set_radius(30,50).set_focal_point(0,500).set_mask(0,.5)
emitter.force_to_edge = PULSE_TO_EDGE.NONE

emitter3= new pulse_local_emitter("front","water")

emitter3.set_scale(1,.5).set_radius(30,50).set_focal_point(0,500).set_mask(.5,1)
emitter3.force_to_edge = PULSE_TO_EDGE.NONE

emitter_2= new pulse_local_emitter("back","water_2")
emitter_2.set_scale(1,.5).set_radius(50,50)

emitter_2.force_to_edge = PULSE_TO_EDGE.NONE

surf_Blobs = -1