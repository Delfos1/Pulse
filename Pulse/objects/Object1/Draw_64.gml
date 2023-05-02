var num = part_particles_count(system)

draw_set_font(Font1)
draw_text(50,50,string(num))
draw_circle(x,y,sys._radius_external,true)
draw_circle(x,y,sys._radius_internal,true)
draw_line_width_color(x-10,y,x+10,y,1,c_green,c_green)
draw_line_width_color(x,y-10,x,y+10,1,c_green,c_green)