activate_collision =  false
mouse_start = [0,0]
move = false
//////////////////////////
//////////////////////////
///////   CACHE    ///////
//////////////////////////
//////////////////////////


cache.add_collisions(o_Collider)

dbg_view("Cache",true,630,330,300,700)

dbg_section("Properties",true)

/*
dbg_text_separator("Elements:")
dbg_text($"Particle : {cache.particle.name}")
dbg_text($"System   : {cache.part_system.name}")*/

dbg_text_separator("Cache properties:")
e_amount = 50
e_freq = 1
counter = 0
dbg_text_input(ref_create(self,"e_amount"),"Amount of particles emitted","i")
dbg_slider_int(ref_create(self,"e_freq"),1,120,"Frequency for emitter burst")
e_collide = false
e_collide_prev = false

dbg_checkbox(ref_create(self,"e_collide"),"Activate collisions");

e_dbg_check = true
dbg_checkbox(ref_create(self,"e_dbg_check"),"Draw debug helpers")
#endregion



#endregion



