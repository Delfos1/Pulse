if !debug exit

var amount = part_particles_count(sys.part_system)


draw_set_font(Font1)
draw_text(50,50,$"{amount}")
draw_text(50,100,"Mouse Wheel UP/DN to change emitter scale")
draw_text(50,150,"Arrows to change angle of emitter")
draw_text(50,200,"1,2,3,4,5,6 Cycle through different emit modes")
draw_text(50,250,"Letter P assigns the letter P shape as an emitter")


sys.draw_debug(x,y)