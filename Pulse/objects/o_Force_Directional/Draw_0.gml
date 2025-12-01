if !DBG_General.e_dbg_check exit


var _w = (sprite_width/4)
var _h = (sprite_height/4)

draw_text(bbox_right,bbox_bottom,id)
draw_self()

draw_sprite_ext(s_arrow,0,x,bbox_bottom-_h,1,1,force.direction,c_white,1)
draw_sprite_ext(s_arrow,0,x,bbox_top+_h,1,1,force.direction,c_white,1)
draw_sprite_ext(s_arrow,0,bbox_right-_w,y,1,1,force.direction,c_white,1)
draw_sprite_ext(s_arrow,0,bbox_left+_w,y,1,1,force.direction,c_white,1)


