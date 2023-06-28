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
	GAUSSIAN			=	21,
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

function pulse_emitter(__part_system=__PULSE_DEFAULT_SYS_NAME,__part_type=__PULSE_DEFAULT_PART_NAME,_radius_external=50) constructor
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

	part_system_index	=	part_system.index
	particle_index		=	part_type._index
	
	//emitter form
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
	
	//emitter properties
	_x					=	0
	_y					=	0
	scalex				=	1
	scaley				=	1
	rotation			=	270
	stencil_mode		=	__PULSE_DEFAULT_EMITTER_STENCIL_MODE
	form_mode			=	__PULSE_DEFAULT_EMITTER_FORM_MODE
	distr_along_normal	=	__PULSE_DEFAULT_EMITTER_DISTR_ALONG_NORMAL
	distr_along_form	=	__PULSE_DEFAULT_EMITTER_DISTR_ALONG_FORM
	revolutions			=	1
	force_to_edge		=	false	
	alter_direction		=	__PULSE_DEFAULT_EMITTER_ALTER_DIRECTION
	
	displacement_map	=	undefined
	displace			=
						{
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
							color_mode		: PULSE_COLOR.A_TO_B_RGB
						};
	color_map			=	undefined					
	direction_range		=	[0,0]
	_speed_start		=	part_type._speed
	_life				=	part_type._life

	

	//Pulse properties settings
	
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
	
	static	even_distrib		=	function(_angle=true,_length=true,_revolutions=1)
	{
		if _angle
		{
			distr_along_form		= PULSE_RANDOM.EVEN
		}
		if _length
		{
			distr_along_normal		= PULSE_RANDOM.EVEN	
		}
		revolutions = _revolutions
		
		return self
	}

	static	set_transform		=	function(_scalex=scalex,_scaley=scaley,_rotation=rotation)
	{
		scalex			=	_scalex
		scaley			=	_scaley
		rotation		=	_rotation
		
		return self
	}
	
	static	set_path			=	function(_path)
	{
		path_a = _path
		path_res = power(path_get_number(path_a)-1,path_get_precision(path_a))
		form_mode = PULSE_FORM.PATH
		
		return self
	}
	
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
	
	static	set_color_map			=	function(_map)
	{
		if buffer_exists(_map.noise)
		{
			color_map			=	_map
			displace.color_mode	=	PULSE_COLOR.COLOR_MAP
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
	
	static	set_displace_color		=	function(color_A,color_B,color_mode= PULSE_COLOR.A_TO_B_RGB)
	{
		if displacement_map == undefined
		{
			__pulse_show_debug_message("PULSE WARNING: Displacement map undefined")
		}
			
		if color_mode== PULSE_COLOR.A_TO_B_RGB
		{
			displace.color_A= [color_get_red(color_A),color_get_blue(color_A),color_get_green(color_A)]
			displace.color_B= [color_get_red(color_B),color_get_blue(color_B),color_get_green(color_B)]
			displace.color_A_to_B = true
			displace.color_mode=color_mode
			return self
		}
		else if color_mode== PULSE_COLOR.A_TO_B_HSV
		{
			displace.color_A= [color_get_hue(color_A),color_get_saturation(color_A),color_get_value(color_A)]
			displace.color_B= [color_get_hue(color_B),color_get_saturation(color_B),color_get_value(color_B)]
			displace.color_A_to_B = true
			displace.color_mode=color_mode
			return self
		}
		else
		{
			__pulse_show_debug_message("PULSE ERROR: Color mode needs to be A to B for displacement maps")
			return self
		}
		
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
	
	
	//Emit/Burst function 
	static	pulse				=	function(_amount,x,y,_cache=false)
	{
		var rev,rev2,dir,dir_stencil,eval,eval_a,eval_b,length,_xx,_yy,i,j,x_origin,y_origin,x1,y1,normal,point,transv,int,ext,total,r_h,g_s,b_v,_orient;
		if _cache var cache = array_create(_amount,0)
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
		}
		if form_mode == PULSE_FORM.PATH && path_a== undefined
		{
			form_mode = PULSE_FORM.ELLIPSE
		}
		
		var _speed_start	=	part_type._speed
		var _life			=	part_type._life
		
		mask_start			=	clamp_wrap(mask_start,0,1)
		mask_end			=	clamp_wrap(mask_end,0,1)
		rotation			=	clamp_wrap(rotation,0,359.99)
		
		point	=	mask_start
		rev		=	1
		rev2	=	1
		i		=	0

		repeat(_amount)
			{
				r_h			=	-1
				g_s			=	-1
				b_v			=	-1
				_size		=	undefined
				_orient		=	undefined
				var to_edge = false
				
				#region ASSIGN POINT 
				//Chooses a point at random along the form (number between 0 and 1)

				if mask_start==mask_end
				{
					point			=	mask_end;
				}
				else if distr_along_form	== PULSE_RANDOM.RANDOM
				{
					//Use random to distribute along 
					
					point			=	random_range(mask_start,mask_end);
				}
				else if distr_along_form	== PULSE_RANDOM.GAUSSIAN
				{
					//Use gaussian to distribute the pointection along the mean
					//This doesnt work great
					
					var main=	(mask_start+mask_end)/2
					point			=	gauss(main,main/3);
				}
				else if distr_along_form	== PULSE_RANDOM.EVEN
				{
					//Distribute the point evenly by particle amount and number of revolutions
			
					point = lerp(mask_start, mask_end,rev2/revolutions)
				}

				#endregion
				
				#region FORM (origin and normal)
				
				switch (form_mode)
				{
					case PULSE_FORM.PATH:
					{
							j			= 1/path_res
							x_origin	= path_get_x(path_a,point)
							y_origin	= path_get_y(path_a,point)
							x1			= path_get_x(path_a,point+j)
							y1			= path_get_y(path_a,point+j)
							transv		= point_direction(x_origin,y_origin,x1,y1)
							
							// Direction Increments do not work with particle types. Leaving this in hopes that some day, they will
							//var x2	= path_get_x(path_a,point+(j*2))
							//var y2	= path_get_y(path_a,point+(j*2))
							//arch		= angle_difference(transv, point_direction(x_origin,y_origin,x2,y2))/point_distance(x_origin,y_origin,x2,y2) 

							normal		= ((transv+90)>=360) ? transv-270 : transv+90;
						break;
					}
					case PULSE_FORM.ELLIPSE:
					{
						x_origin	=	x
						y_origin	=	y
						normal		=	(point*360)%360
						transv		=	normal-90<0 ? normal+270 : normal-90;
						
					break;
					}
				}
				
				#endregion

				#region DIRECTION (angle)
				//Adds a random range to the normal
				
				if alter_direction
				{
					if direction_range[0]!=direction_range[1]
					{
						dir =	normal + random_range(direction_range[0],direction_range[1])
					}
					else
					{
						dir =	normal + direction_range[0]
					}

					dir =  dir>=360 ? dir-360 : dir;
				}
				else
				{
					dir = random_range(part_type._direction[0],part_type._direction[1])
				}
				#endregion

				#region STENCIL (animation curve shapes the emitter along the form)
				
				//If there is an animation curve channel assigned, evaluate it.
				
				eval		=	1;
				eval_a		=	1;
				eval_b		=	1;
				total		=	1;
				
				if stencil_mode != PULSE_STENCIL.NONE
				{
					if ac_channel_a !=undefined
					{
						dir_stencil = (abs(rotation)/360)+point;
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
				
				#region ASSIGN LENGTH (distance from origin)
		
				if radius_internal==radius_external
				{
					// If the 2 radius are equal, then there is no need to randomize
					var normal_length = total
					length		=	total*radius_external;
				}
				else if distr_along_normal == PULSE_RANDOM.RANDOM
				{
					//Distribute along the radius by randomizing, then adjusting by shape evaluation
					var normal_length = random(1)
					length = lerp(int*radius_internal,ext*radius_external,normal_length)
					//length		=	random_range(int*radius_internal,ext*radius_external);
				}
				else if distr_along_normal == PULSE_RANDOM.GAUSSIAN
				{
					//Distribute along the radius by gaussian random, then adjusting by shape evaluation
					//This doesnt work great
					
					length		=	eval*gauss(radius_internal,radius_external-radius_internal)//,radius_internal,radius_external);
				}
				else if distr_along_normal == PULSE_RANDOM.EVEN
				{
					//Distribute evenly
					var normal_length =(rev/revolutions)
					length		=	lerp(int*radius_internal,ext*radius_external,normal_length)
					
				}
				#endregion
				
				var _speed		=	random_range(_speed_start[0],_speed_start[1])
				var __life		=	random_range(_life[0],_life[1])
								
				#region DISPLACEMENT MAP
				
				if displacement_map != undefined
				{
					var pixel = displacement_map.GetNormalised(normal_length,point)
					if is_array(pixel)
					{
						pixel[0] =pixel[0]/255
						pixel[1] =pixel[1]/255
						pixel[2] =pixel[2]/255
						pixel[3] =pixel[3]/255
						disp_value = (pixel[0]+pixel[1]+pixel[2]+pixel[3])/4
					}else{
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
						_orient = lerp(part_type._orient[0],part_type._orient[1],disp_value*displace.orient_amount)
					}
					if displace.color_A_to_B && displace.color_mode != PULSE_COLOR.COLOR_MAP
					{
						if is_array(pixel)
						{
							 r_h =  lerp(displace.color_A[0],displace.color_B[0],pixel[0])
							 g_s =  lerp(displace.color_A[1],displace.color_B[1],pixel[1])
							 b_v =  lerp(displace.color_A[2],displace.color_B[2],pixel[2])
						}
						else
						{
							
							 r_h =  lerp(displace.color_A[0],displace.color_B[0],disp_value)
							 g_s =  lerp(displace.color_A[1],displace.color_B[1],disp_value)
							 b_v =  lerp(displace.color_A[2],displace.color_B[2],disp_value)
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
					var _color = color_map.GetNormalised(normal_length,point)
						if is_array(_color)
						{
							 r_h =  _color[0]
							 g_s =  _color[1]
							 b_v =  _color[2]
						}
						else
						{
							 r_h = _color
							 g_s = _color
							 b_v = _color
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
				
				var _accel		=	_speed_start[2]*__life
				var displacement = (_speed*__life)+_accel
				// IF COHESION POINT EXISTS, APPLY
				
				
				#region FORM CULLING (speed change) Depending on direction change speed to conform to form
				
				if force_to_edge
				{
					if abs(angle_difference(dir,transv))<=30		//TRANSVERSAL
					{
						var _edge		= sqrt(power(radius_external,2)-power(length,2))
					
						if	displacement > _edge
						{
							_speed	=	(_edge-_accel)/__life
							to_edge	=	true
						}
					}
					else if (displacement > length)
					{
						if abs(angle_difference(dir,normal))<=75			//NORMAL AWAY FROM CENTER
						{		
							_speed	=	(length-_accel)/__life
							to_edge	=	true
						}
						else												//NORMAL TOWARDS CENTER
						{										
							_speed	=	(length-_accel)/__life
							to_edge	=	true
						}
					}
				}
				
				 #endregion

				//APPLY LOCAL AND GLOBAL FORCES
				
				//CHECK FOR OCCLUDERS/COLLISIONS
				
				//DETERMINE DYNAMIC PARTICLES
	
				x_origin	+= (lengthdir_x(length,normal)*scalex);
				y_origin	+= (lengthdir_y(length,normal)*scaley);

						
				var launch_struct ={
					__life				:__life,
					_speed				:_speed,
					_accel				:_accel,
					x_origin			:x_origin,
					y_origin			:y_origin,
					dir					:dir,
					_orient				:_orient,
					_size				:_size,
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
				rev++
				if rev	>	revolutions
				{
					rev	=	1
					rev2 ++
					if rev2 > revolutions rev2=1
				}
			}
			if _cache return cache
	}
	
	static pulse_from_cache = function(_amount,x,y,_cache)
	{
		var _launch_particle = function(_element,_index)
		{
				part_type.launch(_element)
		}
		array_foreach(_cache,_launch_particle,irandom(array_length(_cache)-1-_amount),_amount)
	}
}