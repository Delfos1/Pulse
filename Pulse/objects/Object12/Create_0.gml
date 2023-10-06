particle = pulse_make_particle("particle")
system = pulse_make_system("sys").set_draw(false)
particle.set_life(100,100).set_speed(0,0,0).set_size(1,1).set_shape(pt_shape_disk).set_color(c_grey)

emitter = new pulse_local_emitter("sys","particle")
emitter.set_distribution_u(PULSE_RANDOM.EVEN,10).form_line(50,0)
mode = 0