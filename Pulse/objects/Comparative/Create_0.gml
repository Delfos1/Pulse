/// @description Insert description here
// You can write your code in this editor
debug = true
show_debug_overlay(debug)

sys = part_system_create()
part = part_type_create()
emit = part_emitter_create(sys)

part_type_color2(part,c_yellow,c_lime)
part_type_direction(part,0,360,0,0)
part_type_speed(part,1,5,-.002,0)
part_type_size(part,0.1,0.35,-.002,0)
part_type_life(part,20,50)
part_type_shape(part,pt_shape_disk)
//part_emitter_region(sys,emit,x,y,x,y,ps_shape_ellipse,ps_distr_linear)
//part_emitter_stream(sys,emit,part,100)






