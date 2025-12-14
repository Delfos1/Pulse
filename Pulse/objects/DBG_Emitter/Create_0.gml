cache = undefined
cacheing = false
activate_collision =  false
mouse_start = [0,0]
move = false
/// @description Create Path
PathRecord(mouse_x,mouse_y)
PathRecordStop()

drawing_active = false
start_time = 0
////


//////////////////////////
//////////////////////////
///////   EMITTER  ///////
//////////////////////////
//////////////////////////



dbg_cache = undefined

emitter.add_collisions(o_Collider)

this = dbg_view($"Emitter: {emitter.name}",true,630,330,300,700)

dbg_section("File",true)
#region
dbg_button("Destroy",function(){
	
	array_delete(DBG_General.emitters, array_find_index(DBG_General.emitters,function(_element, _index){return _element==id}),1)
	pulse_destroy_emitter(emitter.name)
	delete emitter
	dbg_view_delete(this)
	instance_destroy()
}
)

dbg_button("Clone",function(){
	
	var _temp_emitter = pulse_clone_emitter(emitter.name)
	var _emitter = pulse_store_emitter(_temp_emitter,string_concat(emitter.name,"_clone"),false)
	
	_temp_emitter.destroy()
	
	var _inst  = instance_create_layer(random_range(1300,1600),random_range(300,600),layer,DBG_Emitter,{emitter: _emitter, system_instance: system_instance , particle_instance : particle_instance})
	array_push(DBG_General.emitters,_inst)
	})
dbg_same_line()
dbg_button("Export",function(){
	emitter.set_default_amount(e_amount)
	pulse_export_emitter(emitter)})
	
dbg_button("Save and swap to Cache",function(){
		
	cache = new pulse_cache(emitter, emitter.pulse(e_amount*20.5,x,y,true))
	cacheing = true
	cache.collide = true
	
	dbg_cache = dbg_section("Cache Export",true)
	dbg_button("Export Cache",function()
	{
		pulse_export_cache(cache,true,true,true)
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

dbg_button("Randomize",function(){

		var _focal = choose(true,false)

		if 		emitter.displacement_map	==	undefined
		{
			emitter.set_displacement_map(DBG_General.displ_map[emap_frame])
		}
		if	emitter.color_map			==	undefined	
		{
			emitter.set_color_map(DBG_General.color_map[ecolormap_frame])
		}

		e_bound = _focal==true ? choose("None","Life","Speed","Focal Life","Focal Speed") : choose("None","Life","Speed")
		e_radius		= [irandom(300),irandom(300),irandom(300),irandom(300)]
		e_scale = [random(1),random(1)]

		e_stencils = [choose("Triangle","Square","Pentagon","Hexagon"),choose("Triangle","Square","Pentagon","Hexagon")]
		e_stencils_mode = choose(PULSE_STENCIL.NONE,PULSE_STENCIL.A_TO_B,PULSE_STENCIL.EXTERNAL,PULSE_STENCIL.INTERNAL)
		e_stencils_off		= random(1)
		e_stencils_tween = random(1)

		e_dir = [random(360),random(360)]

		e_collide =choose(true,false)

		if _focal
		{
		e_focal =[irandom_range(-300,300),irandom_range(-300,300)]	
		}
		else
		{
		e_focal =[0,0]	
		}
		
		//APPLY
		emitter.set_radius(e_radius[0],e_radius[1],e_radius[2],e_radius[3])
		emitter.set_scale(e_scale[0],e_scale[1])
		
		//DISTRIBUTION 
		
		//U
		e_dist_u_mode = choose(PULSE_DISTRIBUTION.RANDOM,PULSE_DISTRIBUTION.ANIM_CURVE,PULSE_DISTRIBUTION.EVEN)
		e_dist_u_input = choose("Linear","EaseInOut","EaseIn","EaseOut")
		e_dist_u_input_number = irandom_range(1,10)

		if e_dist_u_mode == PULSE_DISTRIBUTION.EVEN
		{
			emitter.set_distribution_u(e_dist_u_mode,e_dist_u_input_number)
		}
		else
		{
			emitter.set_distribution_u(e_dist_u_mode,[Distribution_Sample,e_dist_u_input])
		}
		
		//V
		e_dist_v_mode = choose(PULSE_DISTRIBUTION.RANDOM,PULSE_DISTRIBUTION.ANIM_CURVE,PULSE_DISTRIBUTION.EVEN)
		e_dist_v_input = choose("Linear","EaseInOut","EaseIn","EaseOut")
		e_dist_v_input_number = irandom_range(1,10)

		if e_dist_v_mode == PULSE_DISTRIBUTION.EVEN
		{
			emitter.set_distribution_v(e_dist_v_mode,e_dist_v_input_number)
		}
		else
		{
			emitter.set_distribution_v(e_dist_v_mode,[Distribution_Sample,e_dist_v_input])
		}

		//SPEED
		e_dist_speed_input =  choose(undefined,"Linear","EaseInOut","EaseIn","EaseOut")
		e_dist_speed_link = choose(PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP )
		e_dist_speed_weight = random(1)

		var _curve = e_dist_speed_input== undefined ? undefined : [Distribution_Sample,e_dist_speed_input]
		emitter.set_distribution_speed(_curve,e_dist_speed_link,e_dist_speed_weight)

		e_dist_life_input = choose(undefined,"Linear","EaseInOut","EaseIn","EaseOut")
		e_dist_life_link = choose(PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP )
		e_dist_life_weight = random(1)

			 _curve = e_dist_life_input== undefined ? undefined : [Distribution_Sample,e_dist_life_input]
			emitter.set_distribution_life(_curve,e_dist_life_link,e_dist_life_weight)


		e_dist_orient_input = choose(undefined,"Linear","EaseInOut","EaseIn","EaseOut")
		e_dist_orient_link =choose(PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP )
		e_dist_orient_weight = random(1)

			 _curve = e_dist_orient_input== undefined ? undefined : [Distribution_Sample,e_dist_orient_input]
			emitter.set_distribution_orient(_curve,e_dist_orient_link,e_dist_orient_weight)


		e_dist_size_input = [choose(undefined,"Linear","EaseInOut","EaseIn","EaseOut"),choose(undefined,"Linear","EaseInOut","EaseIn","EaseOut")]
		e_dist_size_link = choose(PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP )
		e_dist_size_weight = random(1)


			_curve = e_dist_size_input[0] == undefined ? undefined : [Distribution_Sample,e_dist_size_input[0]]
			var _curve2 = e_dist_size_input[1]== undefined ? undefined : [Distribution_Sample,e_dist_size_input[1]]
			if _curve2 != undefined
			{
			  _curve = e_dist_size_input[0] == undefined ? undefined : array_concat(_curve,_curve2)
			}
			emitter.set_distribution_size(_curve,e_dist_size_link,e_dist_size_weight)

		e_dist_frame_input = choose(undefined,"Linear","EaseInOut","EaseIn","EaseOut")
		e_dist_frame_link = choose(PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP )
		e_dist_frame_weight = random(1)

			_curve = e_dist_frame_input== undefined ? undefined : [Distribution_Sample,e_dist_frame_input]
			emitter.set_distribution_frame(_curve,e_dist_frame_link,e_dist_frame_weight)

		p_color = choose(c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black)



		e_dist_color = [choose(c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black),choose(c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black)]
		e_dist_color_input = choose(undefined,"Linear","EaseInOut","EaseIn","EaseOut")
		e_dist_color_link = choose(PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP , PULSE_LINK_TO.COLOR_MAP)
		e_dist_color_type = choose(PULSE_COLOR.A_TO_B_RGB,PULSE_COLOR.A_TO_B_HSV,PULSE_COLOR.COLOR_MAP,PULSE_COLOR.NONE)

			_curve = e_dist_color_input== undefined ? undefined : [Distribution_Sample,e_dist_color_input]
			emitter.set_distribution_color_mix(e_dist_color[0],e_dist_color[1],_curve,e_dist_color_link,,e_dist_color_type)

}
)
dbg_text_separator("Elements:")
ref_part = ref_create(emitter,"part_type")
ref_partname = ref_create(ref_part,"name")
ref_sys = ref_create(emitter,"part_system")
ref_sysname = ref_create(ref_sys,"name")

dbg_text("Particle :")
dbg_same_line()
dbg_text(ref_partname)
dbg_button("Assign Active",function(){

	if DBG_General.p_l == -1 
	{
		particle_instance =  undefined
	}else{
	particle_instance = DBG_General.particles[DBG_General.p_l]
	emitter.set_particle_type(particle_instance.particle)
	}

})
dbg_text("System :")
dbg_same_line()
dbg_text(ref_sysname)

dbg_button("Assign Active",function(){

	if DBG_General.s_l == -1 
	{
		system_instance =  undefined
	}else{
	system_instance = DBG_General.systems[DBG_General.s_l]
	emitter.set_system(system_instance.system)
	}

})

dbg_text_separator("Emission properties:")
e_amount = emitter.default_amount
e_freq = 1
counter = 0
dbg_text_input(ref_create(self,"e_amount"),"Amount of particles emitted","i")
dbg_slider_int(ref_create(self,"e_freq"),1,120,"Frequency for emitter burst")

dbg_text_separator("Others:")
e_dbg_check = true
dbg_checkbox(ref_create(self,"e_dbg_check"),"Draw debug helpers")
#endregion

#region Shape
dbg_section("Form",false)

dbg_text_separator("Ellipse Properties")
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
e_path_plus = DBG_General.path_plus
eref_pathpluse = ref_create(self,"e_path_plus")
dbg_drop_down(ref_create(self,"e_path"),[ExamplePath,e_path_plus],["GM Path","Path Plus"],"Path to be used")

dbg_button("Apply Path",function(){
	emitter.form_path(e_path)		})
dbg_button("Draw Path",function(){
	drawing_active = true
	})
#endregion
dbg_section("Form General Properties",false)

#region Boundary
dbg_text_separator("Boundary")

switch(emitter.boundary)
{
	case PULSE_BOUNDARY.LIFE:
	e_bound = "Life";
	break;
	case PULSE_BOUNDARY.SPEED: 
		e_bound = "Speed";
	break;
	case PULSE_BOUNDARY.FOCAL_LIFE: 
		e_bound = "Focal Life";
	break;
	case PULSE_BOUNDARY.FOCAL_SPEED: 
		e_bound = "Focal Speed";
	break;
	default :
		e_bound = "None"
}
	
dbg_drop_down(ref_create(self,"e_bound"),["None","Life","Speed","Focal Life","Focal Speed"],["None","Life","Speed","Focal Life","Focal Speed"],"Boundary")
dbg_button("Apply",function(){
	switch(e_bound)
	{
	case "Life": 
		emitter.set_boundaries(PULSE_BOUNDARY.LIFE)
	break
	case "Speed": 
		emitter.set_boundaries(PULSE_BOUNDARY.SPEED)
	break
	case "Focal Life": 
		emitter.set_boundaries(PULSE_BOUNDARY.FOCAL_LIFE)
	break
	case "Focal Speed": 
		emitter.set_boundaries(PULSE_BOUNDARY.FOCAL_SPEED)
	break
	case "None": 
		emitter.set_boundaries(PULSE_BOUNDARY.NONE)
	break
	}	})
#endregion

#region Radius
dbg_text_separator("Radius")
e_radius		= [emitter.radius_internal,emitter.radius_external,emitter.edge_internal,emitter.edge_external]
dbg_text_input(ref_create(self,"e_radius",0),"Radius Internal","f")
dbg_text_input(ref_create(self,"e_radius",1),"Radius External","f")
dbg_text_input(ref_create(self,"e_radius",2),"Edge Internal","f")
dbg_text_input(ref_create(self,"e_radius",3),"Edge External","f")

dbg_button("Apply",function(){
emitter.set_radius(e_radius[0],e_radius[1],e_radius[2],e_radius[3])
})
#endregion

#region Scale
dbg_text_separator("Scale")
e_scale = [emitter.x_scale,emitter.y_scale]
dbg_text_input(ref_create(self,"e_scale",0),"Scale X","f")
dbg_text_input(ref_create(self,"e_scale",1),"Scale Y","f")

dbg_button("Apply",function(){
emitter.set_scale(e_scale[0],e_scale[1])
})
#endregion

#region Masks
dbg_text_separator("Masks")
e_mask_u = [emitter.mask_start,emitter.mask_end]
e_mask_u_prev = [emitter.mask_start,emitter.mask_end]
e_mask_v = [emitter.mask_v_start,emitter.mask_v_end]
e_mask_v_prev = [emitter.mask_v_start,emitter.mask_v_end]
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

e_dir = [emitter.direction_range[0],emitter.direction_range[1]]
e_dir_prev = [emitter.direction_range[0],emitter.direction_range[1]]
e_collide = false
e_collide_prev = false
dbg_slider(ref_create(self,"e_dir",0),0,360,"Minimum Direction",1)
dbg_slider(ref_create(self,"e_dir",1),0,360,"Maximum Direction",1)
dbg_checkbox(ref_create(emitter,"alter_direction"),"Alter Particle's Default Direction");
dbg_checkbox(ref_create(self,"e_collide"),"Activate collisions");
#endregion

#region Focal Point
dbg_text_separator("Focal Point")
dbg_text(" By default a Focal point is at\n zero, which will make the particles \nfollow the normals of the form itself")
e_focal =[emitter.x_focal_point,emitter.y_focal_point]
dbg_text_input(ref_create(self,"e_focal",0),"Focal Point X","f")
dbg_text_input(ref_create(self,"e_focal",1),"Focal Point Y","f")
dbg_button("Apply",function(){
emitter.set_focal_point(e_focal[0],e_focal[1])
})


#endregion

#region Forces
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

#endregion

#region Maps
dbg_section("Maps",false)

dbg_text_separator("Displacement Map")

e_map = _64_pol
e_map_ref = ref_create(self,"e_map")
emap_frame = 0
emap_frame_ref = ref_create(self,"emap_frame")

dbg_slider(emap_frame_ref,0,7,"Map",1)
dbg_sprite(e_map_ref,emap_frame_ref,"Selected Map")

dbg_button("Apply", function()
{
	emitter.set_displacement_map(DBG_General.displ_map[emap_frame])
})
dbg_text_separator("Displacement Map Properties")

s_dips_uv = [1,1]
s_dips_xy = [1,1]

dbg_text_input(ref_create(self,"s_dips_uv",0),"U scale","r")
dbg_text_input(ref_create(self,"s_dips_uv",1),"V scale","r")
dbg_button("Apply", function()
{
	emitter.displacement_map.set_uv_scale(s_dips_uv[0],s_dips_uv[1])
})

dbg_slider(ref_create(self,"s_dips_xy",0),0,1,"X Offset")
dbg_slider(ref_create(self,"s_dips_xy",1),0,1,"Y Offset")
dbg_button("Apply", function()
{
	emitter.displacement_map.set_offset(s_dips_xy[0],s_dips_xy[1])
})

dbg_text_separator("Color Map")


e_colormap = colormap_nobg
e_colormap_ref = ref_create(self,"e_colormap")
ecolormap_frame = 0
ecolormap_frame_ref = ref_create(self,"ecolormap_frame")

dbg_slider(ecolormap_frame_ref,0,2,"Map",1)
//dbg_sprite(e_colormap_ref,0,"Selected Map")

dbg_button("Apply", function()
{
	emitter.set_color_map(DBG_General.color_map[ecolormap_frame])
	if ecolormap_frame == 0
	{
		e_colormap = colormap_nobg
	} else if ecolormap_frame == 1
	{
		e_colormap = s_gradient
	}else
	{
		e_colormap = Smoke_up___200_200__n
	}
})
dbg_text_separator("Color Map Properties")

s_color_uv = [1,1]
s_color_xy = [1,1]
s_color_alpha = 0
dbg_text_input(ref_create(self,"s_color_uv",0),"U scale","r")
dbg_text_input(ref_create(self,"s_color_uv",1),"V scale","r")
dbg_button("Apply", function()
{
	emitter.color_map.set_uv_scale(s_color_uv[0],s_color_uv[1])
})

dbg_slider(ref_create(self,"s_color_xy",0),0,1,"X Offset")
dbg_slider(ref_create(self,"s_color_xy",1),0,1,"Y Offset")
dbg_button("Apply", function()
{
	emitter.color_map.set_offset(s_color_xy[0],s_color_xy[1])
})
dbg_text("Sets how the alpha is used in color maps.\n 0 changes the size of particles\n 1 turns the particle off if alpha is below 50%\n 2 doesn't use the alpha information.")
dbg_drop_down(ref_create(self,"s_color_alpha"),[0,1,2],["Alpha to Size","Alpha Threshold","No Alpha"])
dbg_button("Apply", function()
{
	emitter.color_map.set_alpha_mode(s_color_alpha)
})
#endregion

dbg_section("Distributions",false)


#region Distributions
dbg_text("Certain properties can be + Uniformly random \n + Random affected by an Animation Curve \n + Directly linked to a different property \n + Linked and affected by an animation curve \n\n When linked it will link the range of one property with the range\n of the other property (min to min and max to max).")
dbg_text_separator("U axis")
e_dist_u_mode = emitter.distr_along_u_coord	
e_dist_u_input = undefined
e_dist_u_input_number = emitter.divisions_u
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

e_dist_u_offset = emitter.divisions_u_offset
e_dist_u_offset_prev = emitter.divisions_u_offset
dbg_slider(ref_create(self,"e_dist_u_offset"),0,1,"U Coord Offset")

dbg_text_separator("V axis")
e_dist_v_mode = emitter.distr_along_v_coord	
e_dist_v_input = undefined
e_dist_v_input_number =  emitter.divisions_v
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

e_dist_v_offset = emitter.divisions_v_offset
e_dist_v_offset_prev = emitter.divisions_v_offset
dbg_slider(ref_create(self,"e_dist_v_offset"),0,1,"V Coord Offset")
dbg_text_separator("WARNING!")
dbg_text("Set the maps BEFORE applying distributions to them.")
dbg_text_separator("Speed")

e_dist_speed_input = undefined
e_dist_speed_link = emitter.__speed_link


dbg_drop_down(ref_create(self,"e_dist_speed_input"),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_drop_down(ref_create(self,"e_dist_speed_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP ],
													["None",			"Direction",			"Path Speed",			"U Coord",				"V Coord" , "Displacement Map" ],"Link To")
e_dist_speed_weight = emitter.__speed_weight
dbg_slider(ref_create(self,"e_dist_speed_weight"),-1,1,"Weight")
dbg_button("Apply Distribution", function()
{
	var _curve = e_dist_speed_input== undefined ? undefined : [Distribution_Sample,e_dist_speed_input]
	emitter.set_distribution_speed(_curve,e_dist_speed_link,e_dist_speed_weight)
})

dbg_text_separator("Life")
e_dist_life_input =  undefined
e_dist_life_link = emitter.__life_link
dbg_drop_down(ref_create(self,"e_dist_life_input"),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_drop_down(ref_create(self,"e_dist_life_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP ],
													["None",			"Direction",			"Path Speed",			"Speed",			"U Coord",				"V Coord" , "Displacement Map" ],"Link To")
e_dist_life_weight = emitter.__life_weight
dbg_slider(ref_create(self,"e_dist_life_weight"),-1,1,"Weight")
dbg_button("Apply Distribution", function()
{
	var _curve = e_dist_life_input== undefined ? undefined : [Distribution_Sample,e_dist_life_input]
	emitter.set_distribution_life(_curve,e_dist_life_link,e_dist_life_weight)
})

dbg_text_separator("Orient")
e_dist_orient_input = undefined
e_dist_orient_link = emitter.__orient_link
dbg_drop_down(ref_create(self,"e_dist_orient_input"),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_drop_down(ref_create(self,"e_dist_orient_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP ],
													["None",			"Direction",			"Path Speed",			"Speed",			"U Coord",				"V Coord" , "Displacement Map" ],"Link To")
e_dist_orient_weight = emitter.__orient_weight
dbg_slider(ref_create(self,"e_dist_orient_weight"),-1,1,"Weight")
dbg_button("Apply Distribution", function()
{
	var _curve = e_dist_orient_input== undefined ? undefined : [Distribution_Sample,e_dist_orient_input]
	emitter.set_distribution_orient(_curve,e_dist_orient_link,e_dist_orient_weight)
})

dbg_text_separator("Size")
e_dist_size_input = [undefined,undefined]
e_dist_size_link = emitter.__size_link
dbg_drop_down(ref_create(self,"e_dist_size_input",0),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve for X")
dbg_drop_down(ref_create(self,"e_dist_size_input",1),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curvefor Y")
dbg_drop_down(ref_create(self,"e_dist_size_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP ],
													["None",			"Direction",			"Path Speed",			"Speed",			"U Coord",				"V Coord" , "Displacement Map" ],"Link To")
e_dist_size_weight = emitter.__size_weight
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
e_dist_frame_link = emitter.__frame_link
dbg_drop_down(ref_create(self,"e_dist_frame_input"),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_drop_down(ref_create(self,"e_dist_frame_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP ],
													["None",			"Direction",			"Path Speed",			"Speed",			"U Coord",				"V Coord" , "Displacement Map" ],"Link To")
e_dist_frame_weight =  emitter.__frame_weight
dbg_slider(ref_create(self,"e_dist_frame_weight"),-1,1,"Weight")
dbg_button("Apply Distribution", function()
{
	var _curve = e_dist_frame_input== undefined ? undefined : [Distribution_Sample,e_dist_frame_input]
	emitter.set_distribution_frame(_curve,e_dist_frame_link,e_dist_frame_weight)
})

dbg_text_separator("Color Mix")

e_dist_color = [ c_white,c_black]
e_dist_color_input = undefined
e_dist_color_link = emitter.__color_mix_link
e_dist_color_type = emitter.distr_color_mix_type
e_dist_color_weight = [1,1,1,0]
dbg_colour(ref_create(self,"e_dist_color",0),"Color 1")
dbg_colour(ref_create(self,"e_dist_color",1),"Color 2")

dbg_drop_down(ref_create(self,"e_dist_color_input"),[undefined,"Linear","EaseInOut","EaseIn","EaseOut"],["None","Linear","Ease In-Out","Ease In","Ease Out"],"Animation Curve")
dbg_drop_down(ref_create(self,"e_dist_color_link"),[PULSE_LINK_TO.NONE,PULSE_LINK_TO.DIRECTION,PULSE_LINK_TO.PATH_SPEED,PULSE_LINK_TO.SPEED,PULSE_LINK_TO.U_COORD,PULSE_LINK_TO.V_COORD, PULSE_LINK_TO.DISPL_MAP , PULSE_LINK_TO.COLOR_MAP],
													["None",			"Direction",			"Path Speed",			"Speed",			"U Coord",				"V Coord" , "Displacement Map" , "Color Map"],"Link To")
dbg_drop_down(ref_create(self,"e_dist_color_type"),[PULSE_COLOR.A_TO_B_RGB,PULSE_COLOR.A_TO_B_HSV,PULSE_COLOR.COLOR_MAP,PULSE_COLOR.NONE],["A to B - RGB","A to B HSV","Color Map","None"],"Distribution Type")

dbg_slider(ref_create(self,"e_dist_color_weight",0),-1,1,"Weight for R")
dbg_slider(ref_create(self,"e_dist_color_weight",1),-1,1,"Weight for G")
dbg_slider(ref_create(self,"e_dist_color_weight",2),-1,1,"Weight for B")
dbg_slider(ref_create(self,"e_dist_color_weight",3),-1,1,"Weight for A")
dbg_button("Apply Distribution", function()
{
	var _curve = e_dist_color_input== undefined ? undefined : [Distribution_Sample,e_dist_color_input]
	emitter.set_distribution_color_mix(e_dist_color[0],e_dist_color[1],_curve,e_dist_color_link,e_dist_color_weight,e_dist_color_type)
})
#endregion


