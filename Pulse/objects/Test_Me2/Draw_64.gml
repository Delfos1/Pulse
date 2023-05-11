if !debug exit

var num = part_particles_count(global.pulse.systems[0]._system)

draw_set_font(Font1)
draw_text(50,50,string(num))
draw_text(50,100,"Mouse Wheel UP/DN to change emitter scale")
draw_text(50,150,"Arrows to change angle of emitter")
draw_text(50,200,"1,2,3,4,5,6 Cycle through different emit modes")
draw_text(50,250,"Letter P assigns the letter P shape as an emitter")


draw_circle(x,y,sys._radius_external,true)
draw_circle(x,y,sys._radius_internal,true)
draw_line_width_color(x-10,y,x+10,y,1,c_green,c_green)
draw_line_width_color(x,y-10,x,y+10,1,c_green,c_green)