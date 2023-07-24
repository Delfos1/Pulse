enum PULSE_FORM
{
	PATH,
	ELLIPSE,
	LINE,
}
enum PULSE_STENCIL
{
	INTERNAL			=	10,
	EXTERNAL			=	11,
	A_TO_B				=	12,
	NONE				=	13,
}
enum PULSE_RANDOM
{
	RANDOM				=	20,
	ANIM_CURVE			=	21,
	EVEN				=	22,
}
enum PULSE_COLOR
{
	A_TO_B_RGB			=30,
	A_TO_B_HSV			=31,
	COLOR_MAP			=32,
	RGB					=33,
	NONE				=34,
}
enum PULSE_TO_EDGE
{
	NONE=40,
	SPEED=41,
	LIFE=42,
	FOCAL_SPEED = 43,
	FOCAL_LIFE	= 44,
}
enum PULSE_PROPERTY
{
	U_COORD,
	V_COORD,
	PATH_SPEED,
	ORDER_OF_CREATION,
	TO_EDGE,
}


function pulse_emitter(__part_system=__PULSE_DEFAULT_SYS_NAME,__part_type=__PULSE_DEFAULT_PART_NAME,_radius_external=50,anim_curve = undefined) constructor
{
	
	if  struct_exists(global.pulse.systems,__part_system)
	{
		part_system = global.pulse.systems[$__part_system];
	}
	else
	{
		part_system = pulse_make_system(__part_system);
	}

	if  struct_exists(global.pulse.part_types,__part_type)
	{
		part_type = global.pulse.part_types[$__part_type];
	}
	else
	{
		part_type = pulse_make_particle(__part_type);
	}

	if anim_curve == undefined
	{
		interpolations = animcurve_create()
	}
	else
	{
		interpolations = anim_curve
	}

	part_system_index	=	part_system.index
	particle_index		=	part_type._index
	
	//emitter form
	stencil_mode		=	__PULSE_DEFAULT_EMITTER_STENCIL_MODE
	form_mode			=	__PULSE_DEFAULT_EMITTER_FORM_MODE
	path_a				=	undefined
	path_b				=	undefined
	path_res			=	-1
	ac_channel_a		=	undefined
	ac_channel_b		=	undefined
	ac_tween			=	undefined
	radius_external		=	abs(_radius_external)	
	radius_internal		=	0
	mask_start			=	0
	mask_end			=	1
	line				=	[0,0]
	
	//emitter properties
	x_focal_point		=	0
	y_focal_point		=	0
	scalex				=	1
	scaley				=	1
	rotation			=	270
	direction_range		=	[0,0]
	
	//Distributions
	distr_along_v_coord	=	__PULSE_DEFAULT_EMITTER_DISTR_ALONG_V_COORD
	distr_along_u_coord	=	__PULSE_DEFAULT_EMITTER_DISTR_ALONG_U_COORD
	distr_speed			=	__PULSE_DEFAULT_DISTR_PROPERTY
	distr_life			=	__PULSE_DEFAULT_DISTR_PROPERTY
	divisions_v			=	1
	divisions_u			=	1
	
	force_to_edge		=	__PULSE_DEFAULT_EMITTER_FORCE_TO_EDGE
	alter_direction		=	__PULSE_DEFAULT_EMITTER_ALTER_DIRECTION
	
	//Image maps
	displacement_map	=	undefined
	displace			=
						{
							u_scale			:	1,
							v_scale			:	1,
							offset_u		:	0,
							offset_v		:	0,
							position		:false,
							position_amount	:1,
							speed			:false,
							speed_amount	:1,
							life			:false,
							life_amount		:1,
							size			:false,
							size_amount		:1,
							orientation		:false,
							orient_amount	:1,
							color_A_to_B	:false,
							color_A			:-1,
							color_B			:-1,
							color_mode		: PULSE_COLOR.NONE,
							color_blend		:1,

						};
	color_map			=	undefined					



	#region EMITTER SETTINGS
	
	static	set_stencil			=	function(__ac_curve,__ac_channel,_channel=-1,_mode=PULSE_STENCIL.EXTERNAL)
	{

			if !is_string(_channel)
			{
				if ac_channel_a == undefined or ac_channel_b != undefined
				{
					_channel = "a"
				}
				else
				{
					_channel = "b"
				}
			}

			switch (_channel)
			{
				case "a":
					ac_channel_a		=	animcurve_get_channel(__ac_curve,__ac_channel)
					break;
				case "b":
					ac_channel_b		=	animcurve_get_channel(__ac_curve,__ac_channel)
					break;
			}
			
			stencil_mode= _mode
			
			return self
	}
	
	static	set_tween_stencil	=	function(__ac_curve_a,_ac_channel_a,__ac_curve_b,_ac_channel_b,_mode=PULSE_STENCIL.A_TO_B)
	{
		set_stencil(__ac_curve_a,_ac_channel_a,"a");
		set_stencil(__ac_curve_b,_ac_channel_b,"b");

		ac_tween =	0;	
		
		stencil_mode= _mode
		
		return self
	}
	
	static	set_mask			=	function(_mask_start,_mask_end)
	{
		mask_start			=	clamp(_mask_start,0,1);
		mask_end			=	clamp(_mask_end,0,1);
		
		return self
	}

	static	set_radius			=	function(_radius_internal,_radius_external)
	{
		radius_internal	=	_radius_internal;
		radius_external	=	_radius_external;
		
		return self
	}
	
	static	set_direction_range	=	function(_direction_min,_direction_max)
	{
		direction_range	=	[_direction_min,_direction_max]
		
		return self
	}
	
	static	even_distrib		=	function(_along_u=true,_divisions_u=1,_along_v=true,_divisions_v=1)
	{
		if _along_u
		{
			distr_along_u_coord		= PULSE_RANDOM.EVEN
			
		}
		if _along_v
		{
			distr_along_v_coord		= PULSE_RANDOM.EVEN	
		}
		divisions_v = _divisions_v
		divisions_u	= _divisions_u
		
		return self 
	}

	static	set_transform		=	function(_scalex=scalex,_scaley=scaley,_rotation=rotation)
	{
		scalex			=	_scalex
		scaley			=	_scaley
		rotation		=	_rotation
		
		return self
	}
	
	//Focal Point's position is relative to the emitter's position
	static	set_focal_point		=	function(_x,_y)
	{
		x_focal_point		=	_x
		y_focal_point		=	_y
		
		return self
	}
	
	#endregion
	
	#region FORMS
	static	form_path			=	function(_path)
	{
		path_a = _path
		path_res = power(path_get_number(path_a)-1,path_get_precision(path_a))
		form_mode = PULSE_FORM.PATH
		
		return self
	}
	
	static	form_line			=	function(x_point_b,y_point_b)
	{
		line	=	[x_point_b,y_point_b]
		form_mode = PULSE_FORM.LINE
		
		return self
	}
	
	#endregion
	
	#region NONLINEAR INTERPOLATIONS
	
	// 
	
	#endregion
	
	#region DISPLACEMENT MAP PROPERTIES
	
	static	set_displacement_map	=	function(_map)
	{
		if buffer_exists(_map.noise)
		{
			displacement_map	=	_map
		}
		else
		{		
		__pulse_show_debug_message("PULSE ERROR: Displacement Map is a wrong format")
		}
		
		return self
	}
	
	static	set_color_map			=	function(_map,_blend=1)
	{
		if buffer_exists(_map.noise)
		{
			color_map			=	_map
			displace.color_mode	=	PULSE_COLOR.COLOR_MAP
			displace.color_blend=	_blend
		}
		else
		{
		__pulse_show_debug_message("PULSE ERROR: Color Map is a wrong format")
		}
		return self
	}
	
	static	set_displace_position	=	function(amount)
	{
		if displacement_map == undefined
		{
			__pulse_show_debug_message("PULSE WARNING: Displacement map undefined")
		}
		displace.position = true;
		displace.position_amount = amount;
		
		return self
	}
	
	static	set_displace_size		=	function(amount)
	{
		if displacement_map == undefined
		{
			__pulse_show_debug_message("PULSE WARNING: Displacement map undefined")
		}
		displace.size = true;
		displace.size_amount = amount;
		
		return self
	}
	
	static	set_displace_speed		=	function(amount)
	{
		if displacement_map == undefined
		{
			__pulse_show_debug_message("PULSE WARNING: Displacement map undefined")
		}
		displace.speed = true;
		displace.speed_amount = amount;
		
		return self
	}
	
	static	set_displace_orientation=	function(amount)
	{
		if displacement_map == undefined
		{
			__pulse_show_debug_message("PULSE WARNING: Displacement map undefined")
		}
		displace.orientation = true;
		displace.orient_amount = amount;
		
		return self
	}
	
	static	set_displace_life		=	function(amount)
	{
		if displacement_map == undefined
		{
			__pulse_show_debug_message("PULSE WARNING: Displacement map undefined")
		}
		displace.life = true;
		displace.life_amount = amount;
		
		return self
	}
	
	static	set_displace_color		=	function(color_A,color_B,color_mode= PULSE_COLOR.A_TO_B_RGB,_blend=1)
	{
		if displacement_map == undefined
		{
			__pulse_show_debug_message("PULSE WARNING: Displacement map undefined")
		}
			
		if color_mode== PULSE_COLOR.A_TO_B_RGB
		{
			displace.color_A		= [color_get_red(color_A),color_get_blue(color_A),color_get_green(color_A)]
			displace.color_B		= [color_get_red(color_B),color_get_blue(color_B),color_get_green(color_B)]
			displace.color_A_to_B	= true
			displace.color_mode		= color_mode
			displace.color_blend	= _blend
			return self
		}
		else if color_mode== PULSE_COLOR.A_TO_B_HSV
		{
			
			displace.color_A		= [color_get_hue(color_A),color_get_saturation(color_A),color_get_value(color_A)]
			displace.color_B		= [color_get_hue(color_B),color_get_saturation(color_B),color_get_value(color_B)]
			displace.color_A_to_B	= true
			displace.color_mode		= color_mode
			displace.color_blend	= _blend
			return self
		}
		else
		{
			__pulse_show_debug_message("PULSE ERROR: Color mode needs to be A to B for displacement maps")
			return self
		}
		
	}
	
	static	set_displace_uv_scale	=	function(u,v)
	{
		displace.u_scale = abs(u)
		displace.v_scale = abs(v)
		return self
	}
	
	#endregion
	
	static	draw_debug			=	function(x,y)
	{
		// draw radiuses
		var ext_x =  radius_external*scalex
		var int_x =  radius_internal*scalex
		var ext_y =  radius_external*scaley
		var int_y =  radius_internal*scaley
		draw_ellipse(x-ext_x,y-ext_y,x+ext_x,y+ext_y,true)
		draw_ellipse(x-int_x,y-int_y,x+int_x,y+int_y,true)
		
		//draw origin
		draw_line_width_color(x-10,y,x+10,y,1,c_green,c_green)
		draw_line_width_color(x,y-10,x,y+10,1,c_green,c_green)
		
		//draw focal point
		if x_focal_point != 0 or y_focal_point!= 0
		{
			draw_line_width_color(x-10+x_focal_point,y+y_focal_point,x+10+x_focal_point,y+y_focal_point,3,c_yellow,c_yellow)
			draw_line_width_color(x+x_focal_point,y-10+y_focal_point,x+x_focal_point,y+10+y_focal_point,3,c_yellow,c_yellow)
		}
		
		//draw angle
		/*
		
		var _anstart_x = x+lengthdir_x(ext_x,mask_start)
		var _anstart_y = y+lengthdir_y(ext_y,mask_start)
		var _anend_x = x+lengthdir_x(ext_x,mask_end)
		var _anend_y = y+lengthdir_y(ext_y,mask_end)
		draw_line_width_color(x,y,_anstart_x,_anstart_y,1,c_green,c_green)
		draw_line_width_color(x,y,_anend_x,_anend_y,1,c_green,c_green)
		*/
		// draw direction
/*
		var angle = (direction_range[0]+direction_range[1])/2
			draw_arrow(x+(ext_x/2),y,x,y,10)
*/

	}
	
	
	//Emit\Burst function 
	static	pulse				=	function(_amount,x,y,_cache=false)
	{
		var div_v,div_u,dir,dir_stencil,eval,eval_a,eval_b,length,_xx,_yy,i,j,x_origin,y_origin,x1,y1,normal,u_coord,transv,int,ext,total,r_h,g_s,b_v,_orient;
		if _cache var cache = array_create(_amount,0)
		
		/*  Right now this isnt doing anything, but it would differentiate between smooth and straight paths
		if path_res ==-1 && path_a!= undefined && form_mode == PULSE_FORM.PATH
		{
			path_res = power(path_get_number(path_a)-1,path_get_precision(path_a))
			
			if path_get_kind(path_a) //SMOOTH
			{
				// 
			}
			else
			{
				//path_res = 1
			}
		}*/
		if form_mode == PULSE_FORM.PATH && path_a== undefined
		{
			form_mode = PULSE_FORM.ELLIPSE
		}
		
		// EVALUATE FOR NON-LINEAR INTERPOLATIONS
		
		
		var _speed_start	=	part_type._speed
		var _life			=	part_type._life
		
		mask_start			=	clamp_wrap(mask_start,0,1)
		mask_end			=	clamp_wrap(mask_end,0,1)
		rotation			=	rotation%360
		
		u_coord	=	mask_start
		div_v		=	1
		div_u	=	1
		i		=	0

		repeat(_amount)
			{
				r_h			=	-1
				g_s			=	-1
				b_v			=	-1
				eval		=	1;
				eval_a		=	1;
				eval_b		=	1;
				total		=	1;
				_size		=	undefined
				_orient		=	undefined
				var to_edge = false
				
				//Assigns where the particle will spawn in normalized space (u_coord)
				#region ASSIGN U COORDINATE
				//Chooses a u coord at random along the form (number between 0 and 1)

				if mask_start==mask_end
				{
					u_coord			=	mask_end;
				}
				else if distr_along_u_coord	== PULSE_RANDOM.RANDOM
				{
					//Use random to distribute along 
					
					u_coord			=	random_range(mask_start,mask_end);
				}
				else if distr_along_u_coord	== PULSE_RANDOM.ANIM_CURVE
				{
					//Use gaussian to distribute the pointection along the mean
					//This doesnt work great
					
					u_coord			=	lerp(mask_start,mask_end,animcurve_channel_evaluate(animcurve_get_channel(AnimationCurve2,"curve1"),random(1)))
				}
				else if distr_along_u_coord	== PULSE_RANDOM.EVEN
				{
					//Distribute the u_coord evenly by particle amount and number of divisions_v
			
					u_coord = lerp(mask_start, mask_end,div_u/divisions_u)
				}

				#endregion
				
				//Stencil alters the V coordinate space, shaping it according to one or two Animation Curves
				#region STENCIL (animation curve shapes the length of the emitter along the form)
				
				//If there is an animation curve channel assigned, evaluate it.
					
				if stencil_mode != PULSE_STENCIL.NONE
				{
					if ac_channel_a !=undefined
					{
						dir_stencil = (abs(rotation)/360)+u_coord;
						dir_stencil=  dir_stencil>=1 ? dir_stencil-1 : dir_stencil
					
						eval_a	=	animcurve_channel_evaluate(ac_channel_a,dir_stencil);
						eval	=	eval_a
					
						if ac_channel_b !=undefined
						{
							eval_b	=	animcurve_channel_evaluate(ac_channel_b,dir_stencil);
							eval	=	lerp(eval_a,eval_b,abs(ac_tween))
						}
					}
					else if	ac_channel_b !=undefined
					{
						__pulse_show_debug_message("PULSE WARNING: Missing Shape A. Using Shape B instead")
						eval_a	=	animcurve_channel_evaluate(ac_channel_b,dir_stencil);
						eval	=	eval_a
					}
				
					switch (stencil_mode)
				{
					case PULSE_STENCIL.A_TO_B: //SHAPE A IS EXTERNAL, B IS INTERNAL
					{
						ext		= eval_a
						int		= eval_b
						total	= eval
						break;
					}
					case PULSE_STENCIL.EXTERNAL: //BOTH SHAPES ARE EXTERNAL, MODULATED BY TWEEN
					{
						ext		= eval
						int		= 1
						total	= eval
						break;
					}
					case PULSE_STENCIL.INTERNAL: //BOTH SHAPES ARE INTERNAL, MODULATED BY TWEEN
					{
						ext		= 1
						int		= eval
						total	= eval
						break;
					}
				}
				}
				
				#endregion
				
				// Assigns how far the particle spawns from the origin point both in pixels (length) and normalized space (v_coord)
				#region ASSIGN V COORDINATE  and LENGTH (distance from origin)
		
				if radius_internal==radius_external
				{
					// If the 2 radius are equal, then there is no need to randomize
					var v_coord = total				//"total" can be 1 if there is no Stencil, or a number between 0 to 1 depending on the evaluated curve
					length		=	total*radius_external;
				}
				else if distr_along_v_coord == PULSE_RANDOM.RANDOM
				{
					//Distribute along the v coordinate (across the radius in a circle) by randomizing, then adjusting by shape evaluation
					var v_coord = random(1)
					length = lerp(int*radius_internal,ext*radius_external,v_coord)
				}
				else if distr_along_v_coord == PULSE_RANDOM.ANIM_CURVE
				{
					//Distribute along the radius by gaussian random, then adjusting by shape evaluation

					var v_coord = random(1)
					length		=	lerp(int*radius_internal,ext*radius_external,animcurve_channel_evaluate(animcurve_get_channel(AnimationCurve2,"curve1"),v_coord))
				}
				else if distr_along_v_coord == PULSE_RANDOM.EVEN
				{
					//Distribute evenly
					var v_coord =(div_v/divisions_v)
					length		=	lerp(int*radius_internal,ext*radius_external,v_coord)
					
				}
				
				#endregion

				var _speed		=	random_range(_speed_start[0],_speed_start[1])
				var __life		=	random_range(_life[0],_life[1])
								
				#region DISPLACEMENT MAP
				
				if displacement_map != undefined
				{
					var u = (displace.u_scale * u_coord)+(displace.offset_u);
					u = u>=1 ?  frac(u): u ;
					var v = (displace.v_scale * v_coord)+(displace.offset_v);
					v = v>=1 ?  frac(v): v;
					
					var pixel = displacement_map.GetNormalised(u,v)
					
					
					if is_array(pixel)
					{
						// if the returned value is an array we can use individual channels
						pixel[0] =pixel[0]/255
						pixel[1] =pixel[1]/255
						pixel[2] =pixel[2]/255
						pixel[3] =pixel[3]/255
						disp_value = (pixel[0]+pixel[1]+pixel[2]+pixel[3])/4
					}
					else
					{
						//else you are probably using Dragonite's noise generator Macaw
						var disp_value= pixel/255
					}
					
					if displace.position && displace.position_amount!=0
					{
						length		=	lerp(int*radius_internal+length,ext*radius_external+length,disp_value*displace.position_amount)
					}
					if displace.speed && displace.speed_amount!=0
					{
						_speed		=	lerp(_speed_start[0],_speed_start[1],disp_value*displace.speed_amount)
					}
					if displace.life && displace.life_amount!=0
					{
						__life		=	lerp(_life[0],_life[1],disp_value*displace.life_amount)
					}
					if displace.orientation && displace.orient_amount!=0
					{
						_orient		=	lerp(part_type._orient[0],part_type._orient[1],disp_value*displace.orient_amount)
					}
					if displace.color_A_to_B && displace.color_mode != PULSE_COLOR.COLOR_MAP
					{
						if is_array(pixel)
						{
							 r_h =  lerp(displace.color_A[0],displace.color_B[0],pixel[0])
							 g_s =  lerp(displace.color_A[1],displace.color_B[1],pixel[1])
							 b_v =  lerp(displace.color_A[2],displace.color_B[2],pixel[2])
							 
							 r_h =  lerp(255,r_h,displace.color_blend)
							 g_s =  lerp(255,g_s,displace.color_blend)
							 b_v =  lerp(255,b_v,displace.color_blend)
						}
						else
						{
							 r_h =  lerp(displace.color_A[0],displace.color_B[0],disp_value)
							 g_s =  lerp(displace.color_A[1],displace.color_B[1],disp_value)
							 b_v =  lerp(displace.color_A[2],displace.color_B[2],disp_value)
							 
							 r_h =  lerp(255,r_h,displace.color_blend)
							 g_s =  lerp(255,g_s,displace.color_blend)
							 b_v =  lerp(255,b_v,displace.color_blend)
						}
					}
				
					if displace.size && displace.size_amount!=0
					{
						if is_array(pixel)
						{
						var _size = lerp(part_type._size[0],part_type._size[1],pixel[3]*displace.size_amount)
						}else{
						var _size = lerp(part_type._size[0],part_type._size[1],disp_value*displace.size_amount)
						}
					}
				}
				
				if color_map != undefined && displace.color_mode==PULSE_COLOR.COLOR_MAP
				{
					var u = (displace.u_scale * u_coord)+(displace.offset_u);
					u = u>=1 ?  frac(u): u ;
					var v = (displace.v_scale * v_coord)+(displace.offset_v);
					v = v>=1 ?  frac(v): v;
					
					var _color = color_map.GetNormalised(u,v)
						if is_array(_color)
						{
							 r_h =  lerp(255,_color[0],displace.color_blend)
							 g_s =  lerp(255,_color[1],displace.color_blend)
							 b_v =  lerp(255,_color[2],displace.color_blend)
						}
						else
						{
							 r_h = lerp(255,_color,displace.color_blend)
							 g_s = lerp(255,_color,displace.color_blend)
							 b_v = lerp(255,_color,displace.color_blend)
						}
					if displace.size && displace.size_amount!=0
					{
						if is_array(_color)
						{
						var _size = lerp(0,part_type._size[1],(_color[3]/255)*displace.size_amount)
						}else{
						var _size = lerp(0,part_type._size[1],(_color/255)*displace.size_amount)
						}
					}
				}
				
				#endregion
				
				// ----- Determines the angles for the normal and transversal depending on the form (Path, Radius, Line)
				// ----- and then calculates where will the particle will spawn in room space
				#region FORM (origin and normal)
				
				switch (form_mode)
				{
					case PULSE_FORM.PATH:
					{
						j			= 1/path_res
						x_origin	= path_get_x(path_a,u_coord)
						y_origin	= path_get_y(path_a,u_coord)
						x1			= path_get_x(path_a,u_coord+j)
						y1			= path_get_y(path_a,u_coord+j)
						transv		= point_direction(x_origin,y_origin,x1,y1)
							
						// Direction Increments do not work with particle types. Leaving this in hopes that some day, they will
						//var x2	= path_get_x(path_a,u_coord+(j*2))
						//var y2	= path_get_y(path_a,u_coord+(j*2))
						//arch		= angle_difference(transv, point_direction(x_origin,y_origin,x2,y2))/point_distance(x_origin,y_origin,x2,y2) 

						normal		= ((transv+90)>=360) ? transv-270 : transv+90;
						
						x_origin	+= (lengthdir_x(length,normal)*scalex);
						y_origin	+= (lengthdir_y(length,normal)*scaley);
						
						break;
					}
					case PULSE_FORM.ELLIPSE:
					{
						normal		=	(u_coord*360)%360
						
						x_origin	=	x
						y_origin	=	y
						
						if v_coord != 0
						{
							x_origin	+= (lengthdir_x(length,normal)*scalex);
							y_origin	+= (lengthdir_y(length,normal)*scaley);
						}
							
						if x_focal_point!=0 || y_focal_point !=0 // if focal u_coord is in the center, the normal is equal to the angle from the center
						{
							//then, the direction from the focal point to the origin
							normal		=	point_direction(x+x_focal_point,y+y_focal_point,x_origin,y_origin)
						}

						transv		=	((normal-90)<0) ? normal+270 : normal-90;
	
					break;
					}
					case PULSE_FORM.LINE:
					{
						transv		= point_direction(x,y,line[0],line[1])
						normal		= ((transv+90)>=360) ? transv-270 : transv+90;
						x_origin	= lerp(x,line[0],u_coord)
						y_origin	= lerp(y,line[1],u_coord)
						
						if v_coord != 0
						{
							x_origin	+= (lengthdir_x(length,normal)*scalex);
							y_origin	+= (lengthdir_y(length,normal)*scaley);
						}
							
						if x_focal_point!=0 || y_focal_point !=0 // if focal u_coord is in the center, the normal is equal to the angle from the center
						{
							//then, the direction from the focal point to the origin
							normal		=	point_direction(x+x_focal_point,y+y_focal_point,x_origin,y_origin)
							transv		=	((normal-90)<0) ? normal+270 : normal-90;
						}
					}
				}
				
				#endregion
				
				// ----- Changes particle direction by adding a random range to the normal, or uses the particle's 'natural' range
				#region DIRECTION (angle) 
				
				if alter_direction
				{
					if direction_range[0]!=direction_range[1]
					{
						dir =	(normal + random_range(direction_range[0],direction_range[1]))%360
					}
					else
					{
						dir =	(normal + direction_range[0])%360
					}
				
					if length<0		// Mirror angle if the particle is on the negative side of the emitter
					{
						dir		= (transv+angle_difference(transv,dir))%360
					}
								
					if _speed<0		// If Speed is Negative flip the direction and make it positive
					{
						dir		=	dir+180%360
						_speed*=-1
					}
				}
				else
				{
					dir = (random_range(part_type._direction[0],part_type._direction[1]))%360
				}
				
	
				#endregion
				
				#region FORM CULLING (speed change) Depending on direction change speed to conform to form
				
				if force_to_edge != PULSE_TO_EDGE.NONE
				{
					//First we define where the EDGE is, where our particle should stop
					
					if abs(angle_difference(dir,transv))<=30	or 	 abs(angle_difference(dir,transv-180))<=30//TRANSVERSAL
					{
						// Find half chord of the coordinate to the circle (distance to the edge)
						var _edge	= sqrt(power(radius_external,2)-power(length,2)) 
						
						//This second formula should work with any angle, but it doesn't work atm
						//var _edge	= radius_external*sin(degtorad(dir-90))
					}
					else if abs(angle_difference(dir,normal))<=75	//NORMAL AWAY FROM CENTER
					{	
						//Edge is the distance remaining from the spawn point to the radius
						if length>=0
						{
							var _edge	=	radius_external-abs(length)
						}
						else
						{
							var _edge	=	radius_internal-abs(length)
						}
					}
					else											//NORMAL TOWARDS CENTER
					{	
						// If particle is going towards a focal point and thats the limit to be followed
						if force_to_edge == PULSE_TO_EDGE.FOCAL_LIFE || force_to_edge == PULSE_TO_EDGE.FOCAL_SPEED
						{
								var _edge	=	point_distance(x+x_focal_point,y+y_focal_point,x_origin,y_origin)
						}
						else
						{
							if radius_internal >= 0
							{
								var _edge	=	abs(length)-radius_internal
							}
							else
							{
								if length>=0
								{
									var _edge	=	abs(length)
								}
								else
								{
									var _edge	=	abs(radius_internal)
								}
							}	
						}
					}
					
					//Then we calculate the Total Displacement of the particle over its life
					var _accel		=	_speed_start[2]*__life
					var _displacement = (_speed*__life)+_accel
					
					// If the particle moves beyond the edge of the radius, change either its speed or life
					if	_displacement > _edge
					{
						if force_to_edge == PULSE_TO_EDGE.SPEED || force_to_edge == PULSE_TO_EDGE.FOCAL_SPEED
						{
							_speed	=	(_edge-_accel)/__life
						} 
						else if force_to_edge == PULSE_TO_EDGE.LIFE || force_to_edge == PULSE_TO_EDGE.FOCAL_LIFE
						{
							__life	=	(_edge-_accel)/_speed
						}
						//We save this in a boolean as it could be used to change something in the particle appeareance if we wished to
						to_edge	=	true
					}
				
				}
				
				 #endregion

				//APPLY LOCAL AND GLOBAL FORCES
				
				//CHECK FOR OCCLUDERS/COLLISIONS
				
				//DETERMINE DYNAMIC PARTICLES
	
						
				var launch_struct ={
					u_coord				:u_coord,	//Gets passed to the struct but not to the particle, for cache use
					v_coord				:v_coord,	//Gets passed to the struct but not to the particle, for cache use
					__life				:__life,
					_speed				:_speed,
					x_origin			:x_origin,
					y_origin			:y_origin,
					dir					:dir,
					_orient				:_orient,
					_size				:_size,
					part_system			:part_system,
					part_system_index	:part_system_index,
					particle_index		:particle_index,
					r_h	: r_h,
					g_s	: g_s,
					b_v	: b_v,
					color_mode			: displace.color_mode,
				}
				
				if _cache
				{
					cache[i]=launch_struct
				}
				else
				{
					part_type.launch(launch_struct)
				}
				i++
				div_v++
				if div_v	>	divisions_v
				{
					div_v	=	1
					div_u ++
					if div_u > divisions_u div_u=1
				}
			}
			if _cache return cache
	}
	
	static	pulse_from_cache = function(_amount,x,y,_cache)
	{
		var _launch_particle = function(_element,_index)
		{
				part_type.launch(_element)
		}
		array_foreach(_cache,_launch_particle,irandom(array_length(_cache)-1-_amount),_amount)
	}
}