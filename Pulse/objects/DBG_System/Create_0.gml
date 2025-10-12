//////////////////////////
//////////////////////////
///////   SYSTEM  ////////
//////////////////////////
//////////////////////////
	with DBG_System
	{
		active = 0
	}
	active=1

this = dbg_view($"System :{system.name}",true,330,330,300,700)
dbg_section("File",true)
#region File

dbg_text($"System :{system.name}")

active=1
active_spr = s_pulse_star
ref_active = ref_create(self,"active")
ref_active_spr = ref_create(self,"active_spr")
active_func = function(){
	
	with DBG_System
	{
		active = 0
	}
	DBG_General.s_l = array_find_index(DBG_General.systems,function(value){ return value == id })			
	active=1
}
ref_active_func = ref_create(self,"active_func")

dbg_sprite_button(ref_active_func,ref_active_spr,ref_active)
dbg_same_line()
dbg_button("Make Active",ref_active_func)

dbg_text_separator("Clone")

s_newname = system.name+"_clone"

dbg_text_input(ref_create(self,"s_newname"),"New System's name")

dbg_button("Clone",function(){
	var _sys = pulse_clone_system(system,s_newname),
	_inst = instance_create_layer(0,0,layer,DBG_System,{system: _sys})
	array_push(DBG_General.systems,_inst)
	DBG_General.s_l = array_length(DBG_General.systems)-1
})
dbg_button("Destroy",function(){
	
	array_delete(DBG_General.systems, array_find_index(DBG_General.systems,function(_element, _index){return _element==id}),1)
	DBG_General.s_l = array_length(DBG_General.systems)-1
	with DBG_Emitter
	{	
		if system_instance == other.id
		{
			if DBG_General.s_l == -1 
			{
				system_instance =  undefined
			}else{
			system_instance = DBG_General.systems[DBG_General.s_l]
			emitter.set_system(system_instance.system)
			}
		}
	}
	pulse_destroy_system(system.name)
	delete system
	dbg_view_delete(this)
	instance_destroy()
})
dbg_button("Export",function(){
	pulse_export_system(system)})

#endregion

dbg_section("Status",true)
#region Status
s_status = "System is Awake"

ref_s_status= ref_create(self,"s_status")
sleepy = 0
sleepy_spr = s_eye
ref_sleepy_spr = ref_create(self,"sleepy_spr")
ref_sleepy = ref_create(self,"sleepy")
funcsleep = function(){ 
	if sleepy == 1 
		{system.make_asleep(s_wakeup)
	}
	else
	{
		system.make_awake()
	}}
ref_func_sleep =ref_create(self,"funcsleep")
dbg_sprite_button(ref_func_sleep,ref_sleepy_spr,ref_sleepy)
dbg_same_line()
dbg_text(ref_s_status)	


dbg_text("Particle Amount");	 dbg_same_line()
ref_s_part_amount = ref_create(system,"particle_amount")
dbg_text(ref_s_part_amount)	
dbg_text("Limit Particle Amount");	 dbg_same_line()
ref_s_thresh = ref_create(system,"limit")
dbg_text(ref_s_thresh)	
dbg_text("System index ");	 dbg_same_line()
ref_s_i = ref_create(system,"index")
dbg_text(ref_s_i)	
#endregion

dbg_section("Automatic Updates",false)
#region Automatic updates
s_draw = true
s_update = true
s_sampling = 1
s_supersample = false
s_resampling = 1
dbg_checkbox(ref_create(self,"s_draw"),"Automatically Draw")
dbg_checkbox(ref_create(self,"s_update"),"Automatically Update")
dbg_button("Apply",function()
{
	system.set_update(s_update)
	system.set_draw(s_draw)
})
	
dbg_text_separator("Super-sampling")	
dbg_text("Super-sampling allows to speed up or slow down particles by controlling their update cycles")
	
dbg_checkbox(ref_create(self,"s_supersample"),"Super-sample")
dbg_slider(ref_create(self,"s_sampling"),1,10,"Baseline samples",1)
dbg_slider(ref_create(self,"s_resampling"),0.1,2,"Live Re-sampling",.1)
dbg_button("Apply",function()
{
	system.set_super_sampling(s_supersample,s_sampling)
	/*p_time_factor = 1/s_sampling
	particle.scale_time_abs(p_time_factor)*/
	s_update  = !s_supersample
	
})
	
dbg_section("Sleep/Awake/Treshold ",false)

s_wakeup		= true
s_fallasleep	= true
s_limit			= 0
dbg_checkbox(ref_create(self,"s_wakeup"),"Wake up on Emit")

dbg_text(ref_s_status)
dbg_button("Make Asleep",function(){
	system.make_asleep(s_wakeup)})
	dbg_same_line()
dbg_button("Make Awake",function(){
	system.make_awake()})
dbg_text_separator("")
dbg_checkbox(ref_create(self,"s_fallasleep"),"Sleep When Empty")
dbg_text_input(ref_create(self,"s_limit"),"Max Amount of particles in the System","i")
dbg_button("Limit Particles",function(){
	system.set_particle_limit(s_limit, s_fallasleep)})

#endregion

dbg_section("Properties",false)
#region Properties

s_layer = "Same_as_Obstacles"
s_depth = 300
s_position = [0,0]
s_angle = 0
s_color = [c_white,1]
/// Depth
dbg_drop_down(ref_create(self,"s_layer"),["Same_as_Obstacles","Above_Obstacles","Below_Obstacles"],["Same as Obstacles","Above Obstacles","Below Obstacles"],"Layer")
dbg_slider_int(ref_create(self,"s_depth"),200,400,"Depth")

dbg_button("Apply Depth",function(){
	system.set_depth(s_depth)
})
dbg_same_line()
dbg_button("Apply Layer",function(){
	system.set_layer(s_layer)
})
//Position
dbg_text_separator("Position")
dbg_text_input(ref_create(self,"s_position",0),"Position X")
dbg_text_input(ref_create(self,"s_position",1),"Position Y")
dbg_button("Apply",function(){
	system.set_position(s_position[0], s_position[1])
})
/// Angle
dbg_text_separator("Angle")
dbg_slider(ref_create(self,"s_angle"),0,365,"Angle",.5)
dbg_button("Apply",function(){
	system.set_angle(s_angle)
})
/// Color
dbg_drop_down(ref_create(self,"s_color",0),[c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,
c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black],
["White","Aqua","Teal","Blue","Navy","Purple","Fuchsia","Red","Maroon","Orange","Yellow","Olive","Bright Green","Light Gray","Silver","Gray","Dark Gray","Black"],"Color")	
dbg_slider(ref_create(self,"s_color",1),0,1,"Alpha")
dbg_button("Apply",function(){
	system.set_color(s_color[0],s_color[1])
})
#endregion
