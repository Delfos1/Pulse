particle = pulse_make_particle("snow")
system = pulse_make_system("sys")

particle.set_life(768,768).set_speed(.75,1.15,-.0002).set_direction(0,0,0)
.set_size(.3,.5,-0.0005).set_shape(pt_shape_snow).set_orient(0,359,0.2,0,false)
.set_color(c_white,c_aqua).set_alpha(.9,.7,0)

emit = new pulse_local_emitter("sys","snow")
emit.form_line(room_width,0).set_direction_range(180,180)//(160,200)
emit.force_to_edge=PULSE_TO_EDGE.NONE


acc = 0
add = .018