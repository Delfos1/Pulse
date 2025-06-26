//if !debug exit

var amount = part_particles_count(system.index)


draw_set_font(Font1)
draw_text(50,50,$"{amount}")
draw_text(50,100,"Mouse Wheel UP/DN to change particle's angle")
draw_text(50,150,"Arrows to change emitter's mask")
draw_text(50,200,"1,2,3,4,5,6 Cycle through different emit modes")
draw_text(50,250,"Letter P assigns the letter P shape as an emitter")


emitter.draw_debug(x,y)

	