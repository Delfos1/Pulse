debug = true
show_debug_overlay(debug)
debug_resources()
// Welcome to Pulse!

system = pulse_store_system( new pulse_system("sys_1") )

particle =  pulse_store_particle( new pulse_particle("a_particle_name"))
created_maps = false
collision_particle =  pulse_store_particle( new pulse_particle("collision_particle"))
collision_particle.set_direction(0,365).set_shape(pt_shape_line).set_color(c_yellow,c_orange).set_alpha(1,1,.6).set_speed(3,5,-.01).set_life(10,20)

particle.set_death_on_collision(2,collision_particle)
emitter = new pulse_emitter("sys_1","a_particle_name");

path_plus = new PathPlus(ExamplePath,true) 


//////////////////////////
//////////////////////////
///////   SYSTEM  ////////
//////////////////////////
//////////////////////////
#region System
dbg_view("System",true,30,50,350,0)
dbg_section("Import / Export",false)
dbg_button("Import",function(){
	
	var _p = get_open_filename("system.pulses","system.pulses")
	
	if _p != ""
	{
		pulse_destroy_system(system.name)
		system = pulse_import_system(_p,true);
		emitter.set_system(system)
	}
	})
dbg_same_line()
dbg_button("Export",function(){
	pulse_export_system(system)})

dbg_section("Status",true)

s_status = "System is Awake"
ref_s_status= ref_create(self,"s_status")
dbg_text(ref_s_status)	

ref_s_part_amount = ref_create(system,"particle_amount")
dbg_text(ref_s_part_amount)	
ref_s_thresh = ref_create(system,"limit")
dbg_text(ref_s_thresh)	
ref_s_i = ref_create(system,"index")
dbg_text(ref_s_i)	

dbg_section("Automatic Updates",false)

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
	p_time_factor = 1/s_sampling
	particle.scale_time_abs(p_time_factor)
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

dbg_section("Properties",false)

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

//////////////////////////
//////////////////////////
///////   PARTICLE  ///////
//////////////////////////
//////////////////////////
#region Particle

dbg_view("Particle",true,30,70,350,600)
dbg_text(particle.name)

dbg_button("Import",function(){
	
	var _p = get_open_filename("particle.pulsep","particle.pulsep")
	if _p != ""
	{
		pulse_destroy_particle(particle.name)
		particle = pulse_import_particle(_p,true)	
		emitter.set_particle_type(particle)
	}
	})
dbg_same_line()
dbg_button("Export",function(){
	pulse_export_particle(particle,"none")})
	
dbg_text_separator("Life")
p_life = [30,50]
dbg_text_input(ref_create(self,"p_life",0),"Life Minimum","i")
dbg_text_input(ref_create(self,"p_life",1),"Life Maximum","i")
dbg_button("Apply",function(){
	particle.set_life(p_life[0],p_life[1])						})

dbg_text_separator("Speed")
p_speed = [1,2,0,0]

dbg_text_input(ref_create(self,"p_speed",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_speed",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_speed",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_speed",3),"Wiggle","f")
dbg_button("Apply",function(){
	particle.set_speed(p_speed[0],p_speed[1],p_speed[2],p_speed[3])			})

dbg_text_separator("Direction")
p_dir = [1,2,0,0]
dbg_text_input(ref_create(self,"p_dir",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_dir",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_dir",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_dir",3),"Wiggle","f")
dbg_button("Apply",function(){
	particle.set_direction(p_dir[0],p_dir[1],p_dir[2],p_dir[3])			})


dbg_text_separator("Gravity")
p_grav = [.24,270]
dbg_text_input(ref_create(self,"p_grav",0),"Acceleration","f")
dbg_slider(ref_create(self,"p_grav",1),0,360,"Direction")
dbg_button("Apply",function(){
	particle.set_gravity(p_grav[0],p_grav[1])						})

dbg_text_separator("Orientation")
p_orient = [1,2,0,0,true]
dbg_text_input(ref_create(self,"p_orient",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_orient",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_orient",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_orient",3),"Wiggle","f")
dbg_checkbox(ref_create(self,"p_orient",4),"Relative to direction")
dbg_button("Apply",function(){
	particle.set_orient(p_orient[0],p_orient[1],p_orient[2],p_orient[3],p_orient[4])			})
	
dbg_section("Sprite",false)

dbg_text_separator("Shape")
p_shape = pt_shape_circle
dbg_drop_down(ref_create(self,"p_shape"),[pt_shape_circle,pt_shape_cloud,
pt_shape_disk,pt_shape_explosion,pt_shape_flare,pt_shape_line,pt_shape_pixel,pt_shape_ring,
pt_shape_smoke,pt_shape_snow,pt_shape_spark,pt_shape_star,pt_shape_sphere,pt_shape_square],
["Circle","Cloud","Disk","Explosion","Flare","Line","Pixel","Ring","Smoke","Snow","Spark","Star","Sphere","Square",])

dbg_button("Apply",function(){	particle.set_shape(p_shape)	})

dbg_text_separator("Sprite")
/// Sprite selection
p_sprite = flame_01
p_sprite_ref = ref_create(self,"p_sprite")
dbg_drop_down(p_sprite_ref,[flame_01,s_hand,pt_snow_cartoon,Smoke_center___200_200_],["Flame","Hand","Snow","Smoke"])

/// Sprite Properties

p_anim = false
p_stretch = false
p_sp_random = true
p_sp_frame = 0
p_sp_frame_ref = ref_create(self,"p_sp_frame")
dbg_checkbox(ref_create(self,"p_anim"),"Animate")
dbg_checkbox(ref_create(self,"p_stretch"),"Stretch animation over Life")
dbg_checkbox(ref_create(self,"p_sp_random"),"Random Frame/SubImage")
dbg_text_input(p_sp_frame_ref,"Frame / SubImage","i")

dbg_sprite(p_sprite_ref,p_sp_frame_ref,"Sprite")
dbg_button("Apply",function(){
	particle.set_sprite(p_sprite,p_anim,p_stretch,p_sp_random,p_sp_frame)
						})


dbg_section("Size",false)

dbg_text_separator("Size")

p_size = [1,2,0,0]
dbg_text_input(ref_create(self,"p_size",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_size",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_size",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_size",3),"Wiggle","f")

p_size_split = false
dbg_checkbox(ref_create(self,"p_size_split"),"Split into X and Y dimensions")

dbg_text_separator("Size - Y")
p_size_y = [1,2,0,0]
dbg_text_input(ref_create(self,"p_size_y",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_size_y",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_size_y",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_size_y",3),"Wiggle","f")

dbg_button("Apply",function(){
	if p_size_split
	{
		particle.set_size([p_size[0],p_size_y[0]],[p_size[1],p_size_y[1]],[p_size[2],p_size_y[2]],[p_size[3],p_size_y[3]])
			
	}else
	{
		particle.set_size(p_size[0],p_size[1],p_size[2],p_size[3])
	}
						})
				
dbg_text_separator("Set Absolute Size ")
dbg_text("It sets the size of a particle in absolute pixel size")
p_size_abs = [1,2,0,0]
dbg_text_input(ref_create(self,"p_size_abs",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_size_abs",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_size_abs",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_size_abs",3),"Wiggle","f")

p_size_abs_split = false
dbg_checkbox(ref_create(self,"p_size_abs_split"),"Split into X and Y dimensions")
p_size_abs_mode = 0

dbg_drop_down(ref_create(self,"p_size_abs_mode"),[0,1,2],["Average","Shortest Side","Largest Side"],"Mode")

dbg_text_separator("size_abs - Y")
p_size_abs_y = [1,2,0,0]
dbg_text_input(ref_create(self,"p_size_abs_y",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_size_abs_y",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_size_abs_y",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_size_abs_y",3),"Wiggle","f")

dbg_button("Apply",function(){
	if p_size_abs_split
	{
		particle.set_size_abs([p_size_abs[0],p_size_abs_y[0]],[p_size_abs[1],p_size_abs_y[1]],[p_size_abs[2],p_size_abs_y[2]],[p_size_abs[3],p_size_abs_y[3]],p_size_abs_mode)
			
	}else
	{
		particle.set_size_abs(p_size_abs[0],p_size_abs[1],p_size_abs[2],p_size_abs[3],p_size_abs_mode)
	}
})
	
dbg_text_separator("Set Final Size ")
dbg_text("It sets the size acceleration of a particle to approximate a size in relative scale terms")
p_size_final = [0,0,undefined]
p_size_final_split = false
p_size_final_mode = 0
	dbg_checkbox(ref_create(self,"p_size_final_split"),"Split into X and Y dimensions")
	dbg_text_input(ref_create(self,"p_size_final",0),"Size X","f")
	dbg_text_input(ref_create(self,"p_size_final",1),"Size Y","f")
dbg_drop_down(ref_create(self,"p_size_final_mode"),[0,1,2],["Average","Shortest Side","Largest Side"],"Mode")
	dbg_button("Apply",function(){
	if p_size_final_split
	{
		particle.set_final_size([p_size_final[0],p_size_final[1]],p_size_final_mode,p_size_final[2])
			
	}else
	{
		particle.set_final_size(p_size_final[0],p_size_final_mode,p_size_final[2])
	}
						})

dbg_section("Color",false)

p_color = [c_blue,c_aqua,c_white]


dbg_drop_down(ref_create(self,"p_color",0),[c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,
c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black],
["White","Aqua","Teal","Blue","Navy","Purple","Fuchsia","Red","Maroon","Orange","Yellow","Olive","Bright Green","Light Gray","Silver","Gray","Dark Gray","Black"],"Color 1")
dbg_drop_down(ref_create(self,"p_color",1),[c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,
c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black,undefined],
["White","Aqua","Teal","Blue","Navy","Purple","Fuchsia","Red","Maroon","Orange","Yellow","Olive","Bright Green","Light Gray","Silver","Light Gray","Dark Gray","Black","None"],"Color 2")
dbg_drop_down(ref_create(self,"p_color",2),[c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,
c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black,undefined],
["White","Aqua","Teal","Blue","Navy","Purple","Fuchsia","Red","Maroon","Orange","Yellow","Olive","Bright Green","Light Gray","Silver","Light Gray","Dark Gray","Black","None"],"Color 3")
p_blend = false
dbg_checkbox(ref_create(self,"p_blend"),"Additive Blending")

dbg_button("Apply",function()
{
	particle.set_color(p_color[0],p_color[1],p_color[2])
	particle.set_blend(p_blend)
})

dbg_text_separator("Alpha")

p_alpha = [1,1,0]


dbg_slider(ref_create(self,"p_alpha",0),0,1,"Alpha Start",.1)

dbg_text("Use -.1 to set as undefined ⮧")
dbg_slider(ref_create(self,"p_alpha",1),-.1,1,"Alpha Mid Point",.1)
dbg_slider(ref_create(self,"p_alpha",2),-.1,1,"Alpha End",.1)
dbg_button("Apply",function()
{
	p_alpha[1] = p_alpha[1]<0 ? -1 : p_alpha[1]
	p_alpha[2] = p_alpha[2]<0 ? -1 : p_alpha[2]
	particle.set_alpha(p_alpha[0],p_alpha[1],p_alpha[2])
})

dbg_section("Time and Space Scaling",false)

p_time_factor = 1
dbg_text_input(ref_create(self,"p_time_factor"),"Time Factor","f")
dbg_button("Apply",function()
{
	particle.scale_time_abs(p_time_factor)
})
p_space_factor = [1,true,true]
dbg_text_input(ref_create(self,"p_space_factor",0),"Space Factor","f")
dbg_checkbox(ref_create(self,"p_space_factor",1),"Shrink Particle")
dbg_checkbox(ref_create(self,"p_space_factor",2),"Alter Gravity")
dbg_button("Apply",function()
{
	particle.scale_space_abs(p_space_factor[0],p_space_factor[1],p_space_factor[2])
})
#endregion

//////////////////////////
//////////////////////////
///////   EMITTER  ///////
//////////////////////////
//////////////////////////



emitter.add_collisions(o_Collider)
emitter.set_radius(0,150)
emitter.set_boundaries(PULSE_BOUNDARY.NONE)
dbg_view("Emitter",true,380,70,350,600)

dbg_button("Import",function(){
	
	var _p = get_open_filename("particle.pulsep","particle.pulsep")
	
	if _p != ""
	{
		pulse_destroy_particle(particle.name)
		emitter = pulse_import_emitter(_p,true)	
		particle =  emitter.part_type
	}
	})
dbg_same_line()
dbg_button("Export",function(){
	pulse_export_emitter(emitter)})
	
e_amount = 50
e_freq = 1
counter = 0
dbg_text_input(ref_create(self,"e_amount"),"Amount of particles emitted","i")
dbg_slider_int(ref_create(self,"e_freq"),1,120,"Frequency for emitter burst")

e_dbg_check = true
dbg_checkbox(ref_create(self,"e_dbg_check"),"Draw debug helpers")
#region Shape
dbg_section("Shape",true)

e_shape = "Ellipse"
e_shape_prev = "Ellipse"
dbg_drop_down(ref_create(self,"e_shape"),["Ellipse","Path","Line"],["Ellipse","Path","Line"],"Shape")

#endregion

#region Line

dbg_text_separator("Line Properties")
line_x = 100
line_y = 0
line_x_prev = 100
line_y_prev = 0
line_x_ref = ref_create(self,"line_x")
line_y_ref = ref_create(self,"line_y")

dbg_text_input(line_x_ref, "Line Point B - X " , "r")
dbg_text_input(line_y_ref, "Line Point B - Y " , "r")

#endregion

#region Path

dbg_text_separator("Path Properties")
e_path = ExamplePath
dbg_drop_down(ref_create(self,"e_path"),[ExamplePath,path_plus],["GM Path","Path Plus"],"Path to be used")

dbg_button("Apply",function(){
	emitter.form_path(e_path)		})
	
#endregion
dbg_section("General Properties",true)

#region Boundary
dbg_text_separator("Boundary")

e_bound = "None"
e_bound_prev = "None"
dbg_drop_down(ref_create(self,"e_bound"),["None","Life","Speed","Focal Life","Focal Speed"],["None","Life","Speed","Focal Life","Focal Speed"],"Boundary")
#endregion

#region Radius
dbg_text_separator("Radius")
e_radius_prev	= [0,150,0,150]
e_radius		= [0,150,0,150]
dbg_text_input(ref_create(self,"e_radius",0),"Minimum Radius","f")
dbg_text_input(ref_create(self,"e_radius",1),"Maximum Radius","f")
dbg_text_input(ref_create(self,"e_radius",2),"Minimum Edge","f")
dbg_text_input(ref_create(self,"e_radius",3),"Maximum Edge","f")
#endregion

#region Scale
dbg_text_separator("Scale")
e_scale = [1,1]
e_scale_prev = [1,1]
dbg_text_input(ref_create(self,"e_scale",0),"Scale X","f")
dbg_text_input(ref_create(self,"e_scale",1),"Scale Y","f")
#endregion

#region Masks
dbg_text_separator("Masks")
e_mask_u = [0,1]
e_mask_u_prev = [0,1]
e_mask_v = [0,1]
e_mask_v_prev = [0,1]
dbg_slider(ref_create(self,"e_mask_u",0),0,1,"Minimum Mask U")
dbg_slider(ref_create(self,"e_mask_u",1),0,1,"Maximum Mask U")
dbg_slider(ref_create(self,"e_mask_v",0),0,1,"Minimum Mask V")
dbg_slider(ref_create(self,"e_mask_v",1),0,1,"Maximum Mask V")
#endregion

#region Stencil
dbg_text_separator("Stencil")

e_stencils = ["Triangle","Triangle"]
e_stencils_prev = ["Triangle","Triangle"]
e_stencils_mode = PULSE_STENCIL.NONE
e_stencils_mode_prev = PULSE_STENCIL.NONE
e_stencils_off		= 0
e_stencils_off_prev = 0
e_stencils_tween = 0
e_stencils_tween_prev = 0

dbg_drop_down(ref_create(self,"e_stencils_mode"),[PULSE_STENCIL.NONE,PULSE_STENCIL.A_TO_B,PULSE_STENCIL.EXTERNAL,PULSE_STENCIL.INTERNAL],["None","A to B","External","Internal"],"Stencil Mode")
//dbg_drop_down(ref_create(self,"e_stencils",0),["Circle","Star","Splash","Cat_Eye","Letter_P"],["None","Star","Splash","Cat Eye","Letter P"],"Stencil A")
//dbg_drop_down(ref_create(self,"e_stencils",1),["Circle","Star","Splash","Cat_Eye","Letter_P"],["None","Star","Splash","Cat Eye","Letter P"],"Stencil B")
dbg_drop_down(ref_create(self,"e_stencils",0),["Triangle","Square","Pentagon","Hexagon"],["Triangle","Square","Pentagon","Hexagon"],"Stencil A")
dbg_drop_down(ref_create(self,"e_stencils",1),["Triangle","Square","Pentagon","Hexagon"],["Triangle","Square","Pentagon","Hexagon"],"Stencil B")
dbg_slider(ref_create(self,"e_stencils_off"),0,1,"Stencil Offset")
dbg_slider(ref_create(self,"e_stencils_tween"),0,1,"Stencil Tween")
#endregion



dbg_section("Direction Modifiers",false)
#region Direction
dbg_text_separator("Direction Range")

e_dir = [0,0]
e_dir_prev = [0,0]
e_collide = false
e_collide_prev = false
dbg_slider(ref_create(self,"e_dir",0),0,360,"Minimum Direction")
dbg_slider(ref_create(self,"e_dir",1),0,360,"Maximum Direction")
dbg_checkbox(ref_create(emitter,"alter_direction"),"Alter Particle's Default Direction");
dbg_checkbox(ref_create(self,"e_collide"),"Activate collisions");
#endregion

#region Focal Point
dbg_text_separator("Focal Point")

e_focal =[0,0]
e_focal_prev =[0,0]
dbg_text_input(ref_create(self,"e_focal",0),"Focal Point X","f")
dbg_text_input(ref_create(self,"e_focal",1),"Focal Point Y","f")

#endregion
dbg_text_separator("Forces")

dbg_button("Create New Directional Force", function()
{
	var _f = instance_create_layer(x-50,y-50,"Below_Obstacles",o_Force_Directional,{image_xscale:3,image_yscale:3})
	emitter.add_force(_f.force)
})


dbg_section("Distributions",true)

#region Distributions

dbg_text_separator("U axis")
e_dist_u_mode = PULSE_DISTRIBUTION.NONE
e_dist_u_input = undefined
e_dist_u_input_number = 1
dbg_drop_down(ref_create(self,"e_dist_u_mode"),[PULSE_DISTRIBUTION.RANDOM,PULSE_DISTRIBUTION.ANIM_CURVE,PULSE_DISTRIBUTION.EVEN],["Random","Animation Curve","Even"],"Dist Mode")
dbg_drop_down(ref_create(self,"e_dist_u_input"),["Linear","EaseInOut","EaseIn","EaseOut"],["Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_text_input(ref_create(self,"e_dist_u_input_number"),"Divide evenly by","i")
dbg_button("Apply Distribution", function()
{
	if e_dist_u_mode == PULSE_DISTRIBUTION.EVEN
	{
		emitter.set_distribution_u(e_dist_u_mode,real(e_dist_u_input_number))
	}
	else
	{
		emitter.set_distribution_u(e_dist_u_mode,[Distribution_Sample,e_dist_u_input])
	}
})

e_dist_u_offset = 0
e_dist_u_offset_prev = 0
dbg_slider(ref_create(self,"e_dist_u_offset"),0,1,"U Coord Offset")

dbg_text_separator("V axis")
e_dist_v_mode = PULSE_DISTRIBUTION.NONE
e_dist_v_input = undefined
e_dist_v_input_number = 1
dbg_drop_down(ref_create(self,"e_dist_v_mode"),[PULSE_DISTRIBUTION.RANDOM,PULSE_DISTRIBUTION.ANIM_CURVE,PULSE_DISTRIBUTION.EVEN],["Random","Animation Curve","Even"],"Dist Mode")
dbg_drop_down(ref_create(self,"e_dist_v_input"),["Linear","EaseInOut","EaseIn","EaseOut"],["Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_text_input(ref_create(self,"e_dist_v_input_number"),"Divide evenly by","i")
dbg_button("Apply Distribution", function()
{
	if e_dist_v_mode == PULSE_DISTRIBUTION.EVEN
	{
		emitter.set_distribution_v(e_dist_v_mode,real(e_dist_v_input_number))
	}
	else
	{
		emitter.set_distribution_v(e_dist_v_mode,[Distribution_Sample,e_dist_v_input])
	}
})

e_dist_v_offset = 0
e_dist_v_offset_prev = 0
dbg_slider(ref_create(self,"e_dist_v_offset"),0,1,"V Coord Offset")

dbg_text_separator("Speed")

e_dist_speed_input = undefined
e_dist_speed_link = PULSE_LINK_TO.NONE


dbg_drop_down(ref_create(self,"e_dist_speed_input"),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_drop_down(ref_create(self,"e_dist_speed_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP , PULSE_LINK_TO.COLOR_MAP],
													["None",			"Direction",			"Path Speed",			"Speed",			"U Coord",				"V Coord" , "Displacement Map" , "Color Map"],"Link To")
e_dist_speed_weight = 1
dbg_slider(ref_create(self,"e_dist_speed_weight"),-1,1,"Weight")
dbg_button("Apply Distribution", function()
{
	var _curve = e_dist_speed_input== undefined ? undefined : [Distribution_Sample,e_dist_speed_input]
	emitter.set_distribution_speed(_curve,e_dist_speed_link,e_dist_speed_weight)
})

dbg_text_separator("Life")
e_dist_life_input = undefined
e_dist_life_link = undefined
dbg_drop_down(ref_create(self,"e_dist_life_input"),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_drop_down(ref_create(self,"e_dist_life_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP , PULSE_LINK_TO.COLOR_MAP],
													["None",			"Direction",			"Path Speed",			"Speed",			"U Coord",				"V Coord" , "Displacement Map" , "Color Map"],"Link To")
e_dist_life_weight = 1
dbg_slider(ref_create(self,"e_dist_life_weight"),-1,1,"Weight")
dbg_button("Apply Distribution", function()
{
	var _curve = e_dist_life_input== undefined ? undefined : [Distribution_Sample,e_dist_life_input]
	emitter.set_distribution_life(_curve,e_dist_life_link,e_dist_life_weight)
})

dbg_text_separator("Orient")
e_dist_orient_input = undefined
e_dist_orient_link = undefined
dbg_drop_down(ref_create(self,"e_dist_orient_input"),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_drop_down(ref_create(self,"e_dist_orient_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP , PULSE_LINK_TO.COLOR_MAP],
													["None",			"Direction",			"Path Speed",			"Speed",			"U Coord",				"V Coord" , "Displacement Map" , "Color Map"],"Link To")
e_dist_orient_weight = 1
dbg_slider(ref_create(self,"e_dist_orient_weight"),-1,1,"Weight")
dbg_button("Apply Distribution", function()
{
	var _curve = e_dist_orient_input== undefined ? undefined : [Distribution_Sample,e_dist_orient_input]
	emitter.set_distribution_orient(_curve,e_dist_orient_link,e_dist_orient_weight)
})

dbg_text_separator("Size")
e_dist_size_input = [undefined,undefined]
e_dist_size_link = undefined
dbg_drop_down(ref_create(self,"e_dist_size_input",0),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve for X")
dbg_drop_down(ref_create(self,"e_dist_size_input",1),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curvefor Y")
dbg_drop_down(ref_create(self,"e_dist_size_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP , PULSE_LINK_TO.COLOR_MAP],
													["None",			"Direction",			"Path Speed",			"Speed",			"U Coord",				"V Coord" , "Displacement Map" , "Color Map"],"Link To")
e_dist_size_weight = 1
dbg_slider(ref_create(self,"e_dist_size_weight"),-1,1,"Weight")
dbg_button("Apply Distribution", function()
{
	var _curve = e_dist_size_input[0] == undefined ? undefined : [Distribution_Sample,e_dist_size_input[0]]
	var _curve2 = e_dist_size_input[1]== undefined ? undefined : [Distribution_Sample,e_dist_size_input[1]]
	if _curve2 != undefined
	{
	  _curve = e_dist_size_input[0] == undefined ? undefined : array_concat(_curve,_curve2)
	}
	emitter.set_distribution_size(_curve,e_dist_size_link,e_dist_size_weight)
})

dbg_text_separator("Frame")
e_dist_frame_input = undefined
e_dist_frame_link = undefined
dbg_drop_down(ref_create(self,"e_dist_frame_input"),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_drop_down(ref_create(self,"e_dist_frame_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP , PULSE_LINK_TO.COLOR_MAP],
													["None",			"Direction",			"Path Speed",			"Speed",			"U Coord",				"V Coord" , "Displacement Map" , "Color Map"],"Link To")
e_dist_frame_weight = 1
dbg_slider(ref_create(self,"e_dist_frame_weight"),-1,1,"Weight")
dbg_button("Apply Distribution", function()
{
	var _curve = e_dist_frame_input== undefined ? undefined : [Distribution_Sample,e_dist_frame_input]
	emitter.set_distribution_frame(_curve,e_dist_frame_link,e_dist_frame_weight)
})


p_color = [c_blue,c_aqua,c_white]

dbg_text_separator("Color Mix")

e_dist_color = [c_white,c_aqua]
e_dist_color_input = undefined
e_dist_color_link = undefined
e_dist_color_type = PULSE_COLOR.NONE

dbg_drop_down(ref_create(self,"e_dist_color",0),[c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,
c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black],
["White","Aqua","Teal","Blue","Navy","Purple","Fuchsia","Red","Maroon","Orange","Yellow","Olive","Bright Green","Light Gray","Silver","Mid Gray","Dark Gray","Black"],"Color 1")
dbg_drop_down(ref_create(self,"e_dist_color",1),[c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,
c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black],
["White","Aqua","Teal","Blue","Navy","Purple","Fuchsia","Red","Maroon","Orange","Yellow","Olive","Bright Green","Light Gray","Silver","Mid Gray","Dark Gray","Black"],"Color 2")

dbg_drop_down(ref_create(self,"e_dist_color_input"),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_drop_down(ref_create(self,"e_dist_color_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP , PULSE_LINK_TO.COLOR_MAP],
													["None",			"Direction",			"Path Speed",			"Speed",			"U Coord",				"V Coord" , "Displacement Map" , "Color Map"],"Link To")
dbg_drop_down(ref_create(self,"e_dist_color_type"),[PULSE_COLOR.A_TO_B_RGB,PULSE_COLOR.A_TO_B_HSV,PULSE_COLOR.COLOR_MAP,PULSE_COLOR.NONE],["A to B - RGB","A to B HSV","Color Map","None"],"Animation Curve")
dbg_button("Apply Distribution", function()
{
	var _curve = e_dist_color_input== undefined ? undefined : [Distribution_Sample,e_dist_color_input]
	emitter.set_distribution_color_mix(e_dist_color[0],e_dist_color[1],_curve,e_dist_color_link,,e_dist_color_type)
})
#endregion

