draw_path(Path2,290,355,true)

if !debug exit



draw_set_font(Font1)

draw_text(50,100,"Mouse Wheel UP/DN to change emitter scale")
draw_text(50,150,"Arrows to change angle of emitter relative to normal")
draw_text(50,200,"1 will cahnge emitter to 'attractor' mode")
draw_text(50,250,"Shift and control will add 10 to the radius or reset it")


draw_circle(x,y,sys.radius_external,true)
draw_circle(x,y,sys.radius_internal,true)
draw_line_width_color(x-10,y,x+10,y,1,c_green,c_green)
draw_line_width_color(x,y-10,x,y+10,1,c_green,c_green)