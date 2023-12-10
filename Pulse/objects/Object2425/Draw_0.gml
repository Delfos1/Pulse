/// @description Insert description here
// You can write your code in this editor


draw_circle(circleCenterX,circleCenterY,radius,true)
draw_circle(circleCenterX,circleCenterY,2,false)
draw_circle(startPointX,startPointY,5,false)





draw_set_color(c_red)

var x2 = lengthdir_x(_length_to_edge,angle)+startPointX
var y2 = lengthdir_y(_length_to_edge,angle)+startPointY
draw_line(startPointX,startPointY,x2 , y2);

draw_set_color(c_white)

draw_line(startPointX,startPointY,endPointX , endPointY);










