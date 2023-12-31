var amount = part_particles_count(emitter_diffuse.part_system.index)


draw_set_font(Font1)
draw_text(50,50,$"{amount}")

emitter_diffuse.draw_debug(x,y)



