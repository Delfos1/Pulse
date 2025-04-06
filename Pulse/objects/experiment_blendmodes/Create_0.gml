particle = pulse_make_particle("particle2")
system = pulse_make_system("sys2")
system.set_draw(false)
particle.set_life(300,300).set_speed(0,0).set_size(2,2).set_sprite(Sprite50,false,false,false).set_color(c_orange)

emitter = new pulse_emitter("sys2","particle2")
emitter.set_distribution_u(PULSE_DISTRIBUTION.EVEN,10).set_distribution_v(PULSE_DISTRIBUTION.EVEN,2).form_line(0,300).set_radius(0,40)
mode = 0

emitter.force_to_edge=PULSE_TO_EDGE.NONE



