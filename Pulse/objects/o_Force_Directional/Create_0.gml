force = new pulse_force(x,y,0,PULSE_FORCE.DIRECTION,20,1,false)

mouse_start = [0,0]
action = 0 // 0 nothing, 1  move , 2 rotate
hover = false
force.set_range_directional(sprite_height/2,sprite_height/2,sprite_width/2,sprite_width/2)