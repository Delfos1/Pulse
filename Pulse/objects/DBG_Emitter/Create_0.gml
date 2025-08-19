cache = undefined
cacheing = false
activate_collision =  false
mouse_start = [0,0]
move = false
//////////////////////////
//////////////////////////
///////   EMITTER  ///////
//////////////////////////
//////////////////////////

emitter.set_displacement_map(DBG_General.displ_map)
emitter.set_color_map(DBG_General.color_map)


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

dbg_button("Apply Line",function(){
	emitter.form_line(line_x,line_y)		})

#endregion

#region Path

dbg_text_separator("Path Properties")
e_path = ExamplePath
dbg_drop_down(ref_create(self,"e_path"),[ExamplePath,DBG_General.path_plus],["GM Path","Path Plus"],"Path to be used")

dbg_button("Apply Path",function(){
	emitter.form_path(e_path)		})
	
#endregion
dbg_section("Form General Properties",false)

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
dbg_slider(ref_create(self,"e_dir",0),0,360,"Minimum Direction",1)
dbg_slider(ref_create(self,"e_dir",1),0,360,"Maximum Direction",1)
dbg_checkbox(ref_create(emitter,"alter_direction"),"Alter Particle's Default Direction");
dbg_checkbox(ref_create(self,"e_collide"),"Activate collisions");
#endregion

#region Focal Point
dbg_text_separator("Focal Point")
dbg_text(" By default a Focal point is at\n the center of the form, but this can be\n changed to achieve different effects")
e_focal =[0,0]
e_focal_prev =[0,0]
dbg_text_input(ref_create(self,"e_focal",0),"Focal Point X","f")
dbg_text_input(ref_create(self,"e_focal",1),"Focal Point Y","f")

#endregion


dbg_text_separator("Forces")

dbg_text("Create New:")
dbg_button("Directional Force", function()
{
	var _f = instance_create_layer(x-50,y-50,"Below_Obstacles",o_Force_Directional,{image_xscale:3,image_yscale:3})
	emitter.add_force(_f.force)
})
dbg_same_line()
dbg_button("Radial Force", function()
{
	var _f = instance_create_layer(x-50,y-50,"Below_Obstacles",o_Force_Radial,{image_xscale:1,image_yscale:1})
	emitter.add_force(_f.force)
})
dbg_text("Forces can affect the direction of one or multiple emitters")

dbg_section("Distributions",false)

dbg_text("Certain properties can be + Uniformly random \n + Random affected by an Animation Curve \n + Directly linked to a different property \n + Linked and affected by an animation curve \n\n When linked it will link the range of one property with the range\n of the other property (min to min and max to max).")
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

