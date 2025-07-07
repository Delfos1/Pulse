//if !debug exit

var amount = part_particles_count(system.index)


draw_set_font(Font1)
draw_text(50,50,$"Amount of particles: {amount}")

emitter.draw_debug(x,y)

	