debug = false
auto_create = true
if (debug)
{
	show_debug_overlay(debug)
	debug_resources()
}
// Welcome to Pulse!


created_maps = false
collision_particle =  pulse_store_particle( new pulse_particle("collision_particle"))
collision_particle.set_direction(0,365).set_shape(pt_shape_line).set_color(c_yellow,c_orange).set_alpha(1,1,.6).set_speed(3,5,-.01).set_life(10,20)
part_name		= "Particle"
sys_name		= "System"
emitter_name	= "Emitter"
particles		= []
systems			= []
emitters		= []
p_l = 0
s_l = 0

cache = undefined
path_plus = new PathPlus(ExamplePath,true) 
cacheing = false
if auto_create alarm_set(0,2)

dbg_view("Welcome to Pulse!",true,30,30,300,300)

dbg_section("Create")

dbg_text_input(ref_create(self,"part_name"),"New Particle Name")

dbg_button("Create Particle",function()
{
	var _part = pulse_store_particle(new pulse_particle(part_name)),
		_inst = instance_create_layer(0,0,layer,DBG_Particle,{particle: _part})
	array_push(particles,_inst)
	p_l = array_length(particles)-1
})
dbg_same_line()
dbg_button("Create Instance Particle",function()
{
	var _part = pulse_store_particle(new pulse_instance_particle(o_particle_example,part_name)),
		_inst = instance_create_layer(0,0,layer,DBG_Particle,{particle: _part})
	array_push(particles,_inst)
	p_l = array_length(particles)-1
})
dbg_text_separator(" ")

dbg_text_input(ref_create(self,"sys_name"),"New System Name")

dbg_button("Create System",function()
{
	var _sys = pulse_store_system(new pulse_system(sys_name)),
	_inst = instance_create_layer(0,0,layer,DBG_System,{system: _sys})
	array_push(systems,_inst)
	s_l = array_length(systems)-1
})
dbg_text_separator(" ")

dbg_text_input(ref_create(self,"emitter_name"),"New Emitter Name")

dbg_button("Create Emitter",function()
{
	if s_l == -1 or p_l ==-1
	{
		show_message("Can't create an emitter without particles or systems!")
		return
	}
	var _temp_emitter =  new pulse_emitter(systems[s_l].system,particles[p_l].particle)
	var _emitter = pulse_store_emitter(_temp_emitter,emitter_name,false)
	
	pulse_destroy_emitter(_temp_emitter)
	
	var _inst  = instance_create_layer(random_range(1300,1600),random_range(300,600),layer,DBG_Emitter,{emitter: _emitter, system_instance: systems[s_l] , particle_instance : particles[p_l]})
	array_push(emitters,_inst)
})

dbg_text("Emitters are created with the latest \nparticles and systems created \nor selected as active")


dbg_section("Import")


dbg_button("Import Particle",function(){
	
	var _p = get_open_filename("particle.pulsep","particle.pulsep")
	if _p != ""
	{
		var _part = pulse_import_particle(_p,true)	,
			_inst = instance_create_layer(0,0,layer,DBG_Particle,{particle: _part})
			array_push(particles,_inst)
			p_l = array_length(particles)-1
	}
})
dbg_same_line()
dbg_button("Import System",function(){
	
	var _p = get_open_filename("system.pulses","system.pulses")
	
	if _p != ""
	{
		var _sys = pulse_import_system(_p,true),
		_inst = instance_create_layer(0,0,layer,DBG_System,{system: _sys})
		array_push(systems,_inst)
		s_l = array_length(systems)-1
	}
})

dbg_button("Import Emitter",function(){
	
	var _p = get_open_filename("particle.pulsep","particle.pulsep")
	
	if _p != ""
	{
		var _emitter = pulse_import_emitter(_p,true)	
			_emitter = pulse_store_emitter(_emitter,_emitter.name,false)
			///it should try to fetch before creating new particles/system, same for cache
		var _inst_s		= instance_create_layer(0,0,layer,DBG_System,{system: _emitter.part_system})
							array_push(systems,_inst_s)
							s_l = array_length(systems)-1
		var	_inst_p = instance_create_layer(0,0,layer,DBG_Particle,{particle: _emitter.part_type})
							array_push(particles,_inst_p)
							p_l = array_length(particles)-1
		instance_create_layer(random_range(1300,1600),random_range(300,600),layer,DBG_Emitter,{emitter: _emitter, system_instance: systems[s_l] , particle_instance : particles[p_l]})
		array_push(emitters,_emitter)
	}
	})
dbg_same_line()
dbg_button("Import Cache",function(){
	
	var _p = get_open_filename("particle.pulsec","particle.pulsec")
	
	if _p != ""
	{
		var _cache = pulse_import_cache(_p,true)	
		_cache.part_system =  systems[s_l].system
		/*
		var _inst_s		= instance_create_layer(0,0,layer,DBG_System,{system: _cache.part_system})
							array_push(systems,_inst_s)
							s_l = array_length(_inst_s)-1
		var	_inst_p = instance_create_layer(0,0,layer,DBG_Particle,{particle: _cache.part_type})
							array_push(particles,_inst_p)
							p_l = array_length(particles)-1*/
		instance_create_layer(random_range(1300,1600),random_range(300,600),layer,DBG_Cache,{cache: _cache, system_instance: systems[s_l] , particle_instance : particles[p_l]})
	}
})
e_dbg_check = true
dbg_checkbox(ref_create(self,"e_dbg_check"),"Draw debug helpers")

