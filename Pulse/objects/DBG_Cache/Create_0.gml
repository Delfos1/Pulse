activate_collision =  false
mouse_start = [0,0]
move = false
//////////////////////////
//////////////////////////
///////   CACHE    ///////
//////////////////////////
//////////////////////////



dbg_cache = undefined

emitter.add_collisions(o_Collider)
emitter.set_radius(0,150)
emitter.set_boundaries(PULSE_BOUNDARY.NONE)
dbg_view("Emitter",true,630,330,300,700)

dbg_section("File",true)
#region
dbg_button("Import",function(){
	
	var _p = get_open_filename("particle.pulsep","particle.pulsep")
	
	if _p != ""
	{
		pulse_destroy_particle(particle.name)
		emitter = pulse_import_emitter(_p,true)	
		particle =  emitter.part_type
		system =  emitter.part_system
	}
	})
dbg_same_line()
dbg_button("Export",function(){
	pulse_export_emitter(emitter)})
	
dbg_button("Save and swap to Cache",function(){
		
	cache = new pulse_cache(emitter, emitter.pulse(e_amount*20.5,x,y,true))
	cacheing = true
	cache.collide = true
	
	dbg_cache = dbg_section("Cache Export",true)
	dbg_button("Export Cache",function()
	{
		pulse_export_cache(cache,"cache_export","e")
	})
	dbg_same_line()
	dbg_button("Import Cache",function()
	{
		var _c = get_open_filename("*.pulsec"," ")
	
		if _c != ""
		{
			cache = pulse_import_cache(_c)
		}
		
	})
	
})
dbg_same_line()
dbg_button("Swap to live",function(){
		
	cache = undefined
	cacheing = false
	
	if dbg_section_exists(dbg_cache)
	{
		dbg_section_delete(dbg_cache)
	}
})

dbg_text_separator("Elements:")
dbg_text($"Particle : {emitter.part_type.name}")
dbg_text($"System   : {emitter.part_system.name}")

dbg_text_separator("Emission properties:")
e_amount = 50
e_freq = 1
counter = 0
dbg_text_input(ref_create(self,"e_amount"),"Amount of particles emitted","i")
dbg_slider_int(ref_create(self,"e_freq"),1,120,"Frequency for emitter burst")

dbg_text_separator("Others:")
e_dbg_check = true
dbg_checkbox(ref_create(self,"e_dbg_check"),"Draw debug helpers")
#endregion

#region Shape
dbg_section("Form",true)


dbg_button("Apply Ellipse",function(){
	emitter.form_ellipse()		})


#endregion




e_collide = false
e_collide_prev = false

dbg_checkbox(ref_create(self,"e_collide"),"Activate collisions");
#endregion



