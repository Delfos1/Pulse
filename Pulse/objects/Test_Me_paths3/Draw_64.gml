

if !debug exit

draw_path(path,x,y,true)
var num = part_particles_count(global.pulse.systems[0]._system)

draw_set_font(Font1)
draw_text(50,50,string(num))

var size = path_get_number(path)
var i = 0
repeat(size-1)
{
	var __x = path_get_point_x(path,i)
	var __y = path_get_point_y(path,i)
	draw_circle_color(__x,__y,1,c_red,c_red,false)
	
	i++
}

/*
draw_text(50,100,"Mouse Wheel UP/DN to change emitter scale")
draw_text(50,150,"Arrows to change angle of emitter relative to normal")
draw_text(50,200,"1 will cahnge emitter to 'attractor' mode")
draw_text(50,250,"Shift and control will add 10 to the radius or reset it")


draw_circle(x,y,sys._radius_external,true)
draw_circle(x,y,sys._radius_internal,true)
draw_line_width_color(x-10,y,x+10,y,1,c_green,c_green)
draw_line_width_color(x,y-10,x,y+10,1,c_green,c_green)