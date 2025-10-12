force = new pulse_force(x,y,0,PULSE_FORCE.POINT,20,1,false)

var name = $"Radial Force : {id} "
dbg_view(name,true,700,50,150,100)
dbg_section("Properties",true)

dbg_text("Position X")
dbg_same_line()
dbg_text(ref_create(self,"x"))
dbg_text("Position Y")
dbg_same_line()
dbg_text(ref_create(self,"y"))

dbg_text_separator("")

dbg_slider(ref_create(force,"weight"),0,1,"Weight")
dbg_slider(ref_create(force,"strength"),0,100,"Strength")
dbg_slider(ref_create(force,"direction"),0,360,"Direction")
mouse_start = [0,0]
action = 0 // 0 nothing, 1  move , 2 rotate
hover = false
force.set_range_radial(64)