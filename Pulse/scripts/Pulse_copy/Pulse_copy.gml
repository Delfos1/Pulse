/// feather ignore all
/*
function	__pulse_lookup_system(_name)
{
	var system_found = pulse_exists_system(_name)
	
	switch(system_found)
	{
		case 2:
				return _name
		break
		case 1:
				return global.pulse.systems[$_name];
		break
		case 0:
				__pulse_show_debug_message($"PULSE WARNING: System {_name} not found, creating system by that name")
				return pulse_make_system(_name);
		break
		case -1:
				__pulse_show_debug_message($"PULSE WARNING: System {_name} not found, creating system with default name")
				return pulse_make_system(__PULSE_DEFAULT_SYS_NAME);
		break
	}
	
}

function	__pulse_lookup_particle(_name)
{
	var particle_found = pulse_exists_particle(_name)
	
	switch(particle_found)
	{
		case 2:
				return _name
		break
		case 1:
				return global.pulse.part_types[$_name];
		break
		case 0:
				__pulse_show_debug_message($"PULSE WARNING: particle {_name} not found, creating particle with that name")
				return pulse_make_particle(_name);
		break
		case -1:
				__pulse_show_debug_message($"PULSE WARNING: particle {_name} not found, creating particle with default name")
				return pulse_make_particle(__PULSE_DEFAULT_PART_NAME);
		break
	}
	
}
function pulse_local_emitter(__part_system=__PULSE_DEFAULT_SYS_NAME,__part_type=__PULSE_DEFAULT_PART_NAME,_radius_external=50,anim_curve = undefined) constructor
{
	part_system_array = []
	part_type_array  = []
	
	if is_array(__part_system)
	{
		part_system_array = array_create(array_length(__part_system))
		for(var i=0; i<array_length(__part_system);i++)
		{
			part_system_array[i] = 	__pulse_lookup_system(__part_system[i])
		}
		part_system = part_system_array[0]
	}
	else
	{
		part_system = 	 __pulse_lookup_system(__part_system)
		part_system_array[0]=part_system
	}
	
	if is_array(__part_type)
	{
		part_type_array = array_create(array_length(__part_type))
		for(var i=0; i<array_length(__part_type);i++)
		{
			part_type_array[i] =  __pulse_lookup_particle(__part_type[i])
		}
		
		part_type	=part_type_array[0]
	}
	else
	{
		part_type	=	 __pulse_lookup_particle(__part_type)
		part_type_array[0]=part_type
	}

	//emitter form
	stencil_mode		=	__PULSE_DEFAULT_EMITTER_STENCIL_MODE
	form_mode			=	__PULSE_DEFAULT_EMITTER_FORM_MODE
	path_a				=	undefined
	path_b				=	undefined
	path_res			=	-1
	ac_channel_a		=	undefined
	ac_channel_b		=	undefined
	stencil_tween		=	undefined
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
	stencil_offset		=	.75
	direction_range		=	[0,0]
	
	//Distributions
	distr_along_v_coord	=	__PULSE_DEFAULT_EMITTER_DISTR_ALONG_V_COORD
	distr_along_u_coord	=	__PULSE_DEFAULT_EMITTER_DISTR_ALONG_U_COORD
	distr_speed			=	__PULSE_DEFAULT_DISTR_PROPERTY
	distr_life			=	__PULSE_DEFAULT_DISTR_PROPERTY
	distr_orient		=	__PULSE_DEFAULT_DISTR_PROPERTY
	divisions_v			=	1
	divisions_u			=	1
	v_coord_channel		=	undefined
	u_coord_channel		=	undefined
	speed_channel		=	undefined
	life_channel		=	undefined
	orient_channel		=	undefined
	if animcurve_really_exists(anim_curve)
	{
		interpolations = anim_curve
		
		if animcurve_channel_exists(interpolations,"v_coord")
		{
			distr_along_v_coord	= PULSE_RANDOM.ANIM_CURVE
			v_coord_channel = animcurve_get_channel(interpolations,"v_coord")
		}
		if animcurve_channel_exists(interpolations,"u_coord")
		{
			distr_along_u_coord	= PULSE_RANDOM.ANIM_CURVE
			u_coord_channel = animcurve_get_channel(interpolations,"u_coord")
		}
		if animcurve_channel_exists(interpolations,"speed")
		{
			distr_speed	= PULSE_RANDOM.ANIM_CURVE
			speed_channel = animcurve_get_channel(interpolations,"speed")
		}
		if animcurve_channel_exists(interpolations,"life")
		{
			distr_life	= PULSE_RANDOM.ANIM_CURVE
			life_channel = animcurve_get_channel(interpolations,"life")
		}
		if animcurve_channel_exists(interpolations,"orient")
		{
			distr_orient	= PULSE_RANDOM.ANIM_CURVE
			orient_channel = animcurve_get_channel(interpolations,"life")
		}
	}
	else
	{
		//interpolations = animcurve_create()
	}
	
	force_to_edge		=	__PULSE_DEFAULT_EMITTER_FORCE_TO_EDGE
	alter_direction		=	__PULSE_DEFAULT_EMITTER_ALTER_DIRECTION
	
	//Image maps
	displacement_map	=	undefined
	color_map			=	undefined					

	//Forces, Groups, Colliders
	local_forces		=	[]
	

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

		stencil_tween =	0;	
		
		stencil_mode= _mode
		
		return self
	}
	
	static	set_stencil_offset	=	function(_offset)
	{
		stencil_offset		=	_offset
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
	
	static	set_direction_range	=	function(_direction_min,_direction_max=_direction_min)
	{
		direction_range	=	[_direction_min,_direction_max]
		
		return self
	}
	
	static	set_transform		=	function(_scalex=scalex,_scaley=scaley)
	{
		scalex			=	_scalex
		scaley			=	_scaley
		
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
	
	static set_distribution_speed	=  function (_mode=PULSE_RANDOM.RANDOM,anim_curve=undefined,channel=undefined)
	{
		switch(_mode)
		{
			case 	PULSE_RANDOM.ANIM_CURVE:
			{
				if animcurve_exists(anim_curve)
				{
					if animcurve_channel_exists(anim_curve,channel)
					{
						distr_speed = PULSE_RANDOM.ANIM_CURVE
						speed_channel = animcurve_get_channel(anim_curve,channel)
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")
				break
			}
			default:
				distr_speed = PULSE_RANDOM.RANDOM
		}
		

		return self
	}
	
	static set_distribution_life	=  function (_mode=PULSE_RANDOM.RANDOM,anim_curve=undefined,channel=undefined)
		{
			switch(_mode)
			{
				case 	PULSE_RANDOM.ANIM_CURVE:
				{
					if animcurve_exists(anim_curve)
					{
						if animcurve_channel_exists(anim_curve,channel)
						{
							distr_life = PULSE_RANDOM.ANIM_CURVE
							life_channel = animcurve_get_channel(anim_curve,channel)
							break
						}
					}
					__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")
					break
				}
				default:
					distr_life = PULSE_RANDOM.RANDOM
			}
		

			return self
		}
	
	static set_distribution_orient	=  function (_mode=PULSE_RANDOM.RANDOM,anim_curve=undefined,channel=undefined)
	{
		switch(_mode)
		{
			case 	PULSE_RANDOM.ANIM_CURVE:
			{
				if animcurve_exists(anim_curve)
				{
					if animcurve_channel_exists(anim_curve,channel)
					{
						distr_orient = PULSE_RANDOM.ANIM_CURVE
						orient_channel = animcurve_get_channel(anim_curve,channel)
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")
				break
			}
			default:
				distr_orient = PULSE_RANDOM.RANDOM
		}
		

		return self
	}
	
	static set_distribution_u		=  function (_mode=PULSE_RANDOM.RANDOM,_input=undefined)
	{
		switch(_mode)
		{
			case 	PULSE_RANDOM.RANDOM:
			{
				distr_along_u_coord		= PULSE_RANDOM.RANDOM
			break
			}
			case 	PULSE_RANDOM.EVEN:
			{
				distr_along_u_coord		= PULSE_RANDOM.EVEN
				if is_real(_input)
				{
					divisions_u	= _input
				}
				else
				{
					divisions_u	= 1
					__pulse_show_debug_message("PULSE ERROR: Distribution Even argument must be an real, Defaulted to 1")
				}
			break
			}
			case 	PULSE_RANDOM.ANIM_CURVE:
			{
				if !is_array(_input)
				{
					__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve argument must be an array [curve,channel]")	
					break;
				}
				if animcurve_really_exists(_input[0])
				{
					if animcurve_channel_exists(_input[0],_input[1])
					{
						distr_along_u_coord	= PULSE_RANDOM.ANIM_CURVE
						u_coord_channel = animcurve_get_channel(_input[0],_input[1])
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")	
			break
			}
		}
		
		return self
	}
	
	static set_distribution_v		=  function (_mode=PULSE_RANDOM.RANDOM,_input=undefined)
	{
		switch(_mode)
		{
			case 	PULSE_RANDOM.RANDOM:
			{
				distr_along_v_coord		= PULSE_RANDOM.RANDOM
			break
			}
			case 	PULSE_RANDOM.EVEN:
			{
				distr_along_v_coord		= PULSE_RANDOM.EVEN
				if is_real(_input)
				{
					divisions_v	= _input
				}
				else
				{
					divisions_v	= 1
					__pulse_show_debug_message("PULSE ERROR: Distribution Even argument must be an real, Defaulted to 1")
				}
			break
			}
			case 	PULSE_RANDOM.ANIM_CURVE:
			{
				if !is_array(_input)
				{
					__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve argument must be an array [curve,channel]")	
					break;
				}
				if animcurve_really_exists(_input[0])
				{
					if animcurve_channel_exists(_input[0],_input[1])
					{
						distr_along_v_coord	= PULSE_RANDOM.ANIM_CURVE
						v_coord_channel = animcurve_get_channel(_input[0],_input[1])
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")	
			break
			}
		}
		return self
	}
	
	#endregion
	
	#region DISPLACEMENT MAP SETTERS
	
	static	set_displacement_map	=	function(_map)
	{
		if buffer_exists(_map.noise)
		{
			displacement_map	=	new __pulse_map(_map) 
			return displacement_map
			//displacement_map	=	
		}
		else
		{		
		__pulse_show_debug_message("PULSE ERROR: Displacement Map is a wrong format")
		}
		

	}
	
	static	set_color_map			=	function(_map,_blend=1)
	{
		if buffer_exists(_map.noise)
		{
			color_map			=	new __pulse_map(_map) 
			color_map.color_mode=	PULSE_COLOR.COLOR_MAP
			color_map.color_blend=	_blend
		}
		else
		{
		__pulse_show_debug_message("PULSE ERROR: Color Map is a wrong format")
		}
		return self
	}
	
	#endregion
	
	static	add_local_force		=	function(_force)
	{
		if is_instanceof(_force,pulse_force)
		{
			array_push(local_forces,_force)
		}
		return self
	}
	
	static	remove_local_force	=	function(_force)
	{
		if is_instanceof(_force,pulse_force)
		{
			var _i = array_get_index(local_forces,_force)
			if _i != -1
			{
				array_delete(local_forces,_i,1)
			}
		}
		return self
	
	
	}
	
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
/*
	}
	

	//Emit\Burst function 
	static	pulse				=	function(_amount_request,x,y,_cache=false)
	{
		
		if part_system.index = -1
		{
			if part_system.wake_on_emit
			{
				part_system.make_awake()
			}
			else
			{
				__pulse_show_debug_message("PULSE ERROR: System is currently asleep!")
				exit
			}
		}
		if !_cache
		{
			if part_system.threshold != 0 && ( time_source_get_state(part_system.count) != time_source_state_active)
			{
				/* this method reduces the amount of particles too much, essentially killing the system
				
				var _current_particles =  part_particles_count(part_system.index)+(_request*part_system.factor*global.pulse.particle_factor)
				if _current_particles > part_system.threshold
				{
					part_system.factor *= (part_system.threshold/_current_particles)
				} else
				{
					part_system.factor = (_current_particles/part_system.threshold)
				}
				*/
		/*		
				//This method seems to be good only 
				
				if _amount_request >= part_system.threshold
				{
					part_system.factor *= (part_system.threshold/_amount_request)
				}
				
				time_source_reset(part_system.count)
				time_source_start(part_system.count)
			}
			var _amount = floor(_amount_request*part_system.factor*global.pulse.particle_factor)
			if _amount == 0 exit
		}
		else
		{
			var cache = array_create(_amount,0)
		}
		var div_v,div_u,dir,dir_stencil,eval,eval_a,eval_b,length,_xx,_yy,i,j,x_origin,y_origin,x1,y1,normal,u_coord,transv,int,ext,total,r_h,g_s,b_v,_orient;

		
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
/*		
		if form_mode == PULSE_FORM.PATH && !path_really_exists(path_a)
		{
			form_mode = PULSE_FORM.ELLIPSE
		}
		var map_color_mode	=	PULSE_COLOR.NONE
		var _speed_start	=	part_type.speed
		var _life			=	part_type.life
		var _orient_base	=	part_type.orient
		mask_start			=	clamp_wrap(mask_start,0,1)
		mask_end			=	clamp_wrap(mask_end,0,1)
		
		var system_array = array_length(part_system_array)
		var type_array = array_length(part_type_array)
		
		u_coord	=	mask_start
		div_v	=	1
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
				var to_edge =	false
				
				// ----- Assigns where the particle will spawn in normalized space (u_coord)
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
					//use an animation curve to distribute the values
					
					u_coord			=	lerp(mask_start,mask_end,animcurve_channel_evaluate(u_coord_channel,random(1)))
				}
				else if distr_along_u_coord	== PULSE_RANDOM.EVEN
				{
					//Distribute the u_coord evenly by particle amount and number of divisions_v
			
					u_coord = lerp(mask_start, mask_end,div_u/divisions_u)
				}

				#endregion
				
				// ----- Stencil alters the V coordinate space, shaping it according to one or two Animation Curves
				#region STENCIL (animation curve shapes the length of the emitter along the form)
				
				//If there is an animation curve channel assigned, evaluate it.
					
				if stencil_mode != PULSE_STENCIL.NONE
				{
					dir_stencil = (abs(stencil_offset))+u_coord;
					dir_stencil=  dir_stencil>=1 ? dir_stencil-1 : dir_stencil
					
					if ac_channel_a !=undefined
					{
					
						eval_a	=	clamp(animcurve_channel_evaluate(ac_channel_a,dir_stencil),0,1);
						eval	=	eval_a
					
						if ac_channel_b !=undefined
						{
							eval_b	=	clamp(animcurve_channel_evaluate(ac_channel_b,dir_stencil),0,1);
							eval	=	lerp(eval_a,eval_b,abs(stencil_tween))
						}
					}
					else if	ac_channel_b !=undefined
					{
						__pulse_show_debug_message("PULSE WARNING: Missing Shape A. Using Shape B instead")
						eval_a	=	clamp(animcurve_channel_evaluate(ac_channel_b,dir_stencil),0,1);
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
				
				// ----- Assigns how far the particle spawns from the origin point both in pixels (length) and normalized space (v_coord)
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
					//Distribute along the radius by animation curve distribution, then adjusting by shape evaluation

					var v_coord = random(1)
					length		=	lerp(int*radius_internal,ext*radius_external,animcurve_channel_evaluate(v_coord_channel,v_coord))
				}
				else if distr_along_v_coord == PULSE_RANDOM.EVEN
				{
					//Distribute evenly
					var v_coord =(div_v/divisions_v)
					length		=	lerp(int*radius_internal,ext*radius_external,v_coord)
					
				}
				
				#endregion

				// ----- Particle speed and life need to be known before launching the particle, so they can be calculated for form culling
				#region SPEED AND LIFE SETTINGS
				
				var _speed, __life

				if _speed_start[0]==_speed_start[1]
				{
					_speed		=	_speed_start[0]
				}
				else if distr_speed == PULSE_RANDOM.RANDOM
				{
					_speed		=	random_range(_speed_start[0],_speed_start[1])
				}
				else if distr_speed == PULSE_RANDOM.ANIM_CURVE
				{
					_speed		=	lerp(_speed_start[0],_speed_start[1],animcurve_channel_evaluate(speed_channel,random(1)))
				}
				
				if _life[0]==_life[1]
				{
					__life		=	_life[0]
				}
				else if distr_life == PULSE_RANDOM.RANDOM
				{
					__life		=	random_range(_life[0],_life[1])
				}
				else if distr_life == PULSE_RANDOM.ANIM_CURVE
				{
					__life		=	lerp(_life[0],_life[1],animcurve_channel_evaluate(life_channel,random(1)))
				}
				
				if distr_orient == PULSE_RANDOM.ANIM_CURVE
				{
					_orient		=	lerp(_orient_base[0],_orient_base[1],animcurve_channel_evaluate(orient_channel,random(1)))
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
						
						if x_focal_point!=0 || y_focal_point !=0 // if focal u_coord is in the center, the normal is equal to the angle from the center
						{
							//then, the direction from the focal point to the origin
							normal		=	point_direction(x+(x_focal_point*scalex),y+(y_focal_point*scaley),x_origin,y_origin)
							transv		=	((normal-90)<0) ? normal+270 : normal-90;
						}
						
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
							normal		=	point_direction(x+(x_focal_point*scalex),y+(y_focal_point*scaley),x_origin,y_origin)
						}

						transv		=	((normal-90)<0) ? normal+270 : normal-90;
	
					break;
					}
					case PULSE_FORM.LINE:
					{
						transv		= point_direction(x,y,x+line[0],y+line[1])
						normal		= ((transv+90)>=360) ? transv-270 : transv+90;
						x_origin	= lerp(x,x+line[0],u_coord)
						y_origin	= lerp(y,y+line[1],u_coord)
						
						if v_coord != 0
						{
							x_origin	+= (lengthdir_x(length,normal)*scalex);
							y_origin	+= (lengthdir_y(length,normal)*scaley);
						}
							
						if x_focal_point!=0 || y_focal_point !=0 // if focal u_coord is in the center, the normal is equal to the angle from the center
						{
							//then, the direction from the focal point to the origin
							normal		=	point_direction(x+(x_focal_point*scalex),y+(y_focal_point*scaley),x_origin,y_origin)
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
					dir = (random_range(part_type.direction[0],part_type.direction[1]))%360
				}
				
	
				#endregion
	
				// ----- Alter a whole set of particle properties based on a pre-processed sprite or surface
				#region DISPLACEMENT MAP
				
				if displacement_map != undefined
				{
					var u = displacement_map.scale_u * (u_coord+displacement_map.offset_u);
					u = u>1||u<0 ?  abs(frac(u)): u ;
					var v = displacement_map.scale_v * (v_coord+displacement_map.offset_v);
					v = v>1||v<0 ?  abs(frac(v)): v ;
					
					var pixel = displacement_map.buffer.GetNormalised(u,v)
					
					if is_array(pixel)
					{
						// if the returned value is an array we can use individual channels
						pixel[0] =pixel[0]/255  //RED
						pixel[1] =pixel[1]/255  //GREEN
						pixel[2] =pixel[2]/255  //BLUE
						pixel[3] =pixel[3]/255  //ALPHA
						disp_value = mean(pixel[0],pixel[1],pixel[2])
						
					}
					else
					{
						//else you are probably using Dragonite's noise generator Macaw
						var disp_value= pixel/255
					}
					
					if displacement_map.position.active		&& displacement_map.position.weight	!=0
					{
						length		=	lerp(length,lerp(int*radius_internal+length,ext*radius_external+length,disp_value),displacement_map.position.weight)
					}
					if displacement_map.speed.active		&& displacement_map.speed.weight	!=0
					{
						var _displace = disp_value
						if is_array(pixel)
						{
							var _chan = displacement_map.speed.channels
							_displace = mean( (pixel[0]* _chan[0]) , (pixel[1]*_chan[1]) , (pixel[2]*_chan[2]) , (pixel[3]*_chan[3]) )
						}
						_speed		=	lerp(_speed,lerp(displacement_map.speed.range[0],displacement_map.speed.range[1],_displace),displacement_map.speed.weight)
					}
					if displacement_map.life.active			&& displacement_map.life.weight		!=0
					{
						var _displace = disp_value
						if is_array(pixel)
						{
							var _chan = displacement_map.life.channels
							_displace = mean( (pixel[0]* _chan[0]) , (pixel[1]*_chan[1]) , (pixel[2]*_chan[2]) , (pixel[3]*_chan[3]) )
						}
						__life		=	lerp(__life,lerp(displacement_map.life.range[0],displacement_map.life.range[1],_displace),displacement_map.life.weight)
					}
					if displacement_map.orientation.active	&& displacement_map.orient.weight	!=0
					{
						_orient		=	lerp(part_type.orient[0],part_type.orient[1],disp_value*displacement_map.orient.weight)
					}
					if displacement_map.color_A_to_B		&& displacement_map.color_mode		!= PULSE_COLOR.COLOR_MAP
					{
						if is_array(pixel)
						{
							// lerping between the user-provided colors A and B , using the normalized pixel value for the coordinate (most usually between black (0) and white (1) )
							//In this case, pixel is an array, so there are individual values for all channels
							 r_h =  lerp(displacement_map.color_A[0],displacement_map.color_B[0],pixel[0])
							 g_s =  lerp(displacement_map.color_A[1],displacement_map.color_B[1],pixel[1])
							 b_v =  lerp(displacement_map.color_A[2],displacement_map.color_B[2],pixel[2])
						}
						else
						{
							//While here, all channels are compressed into a single channel (Probably when generating a texture with Dragonite's Macaw)
							 r_h =  lerp(displacement_map.color_A[0],displacement_map.color_B[0],disp_value)
							 g_s =  lerp(displacement_map.color_A[1],displacement_map.color_B[1],disp_value)
							 b_v =  lerp(displacement_map.color_A[2],displacement_map.color_B[2],disp_value)
						}
						var map_color_mode = displacement_map.color_mode
						if displacement_map.color_mode == PULSE_COLOR.A_TO_B_RGB
						{
							// "Blend" here is refering to the blending if the particle sprite has colors. If its mixed with pure white it wont change.
							r_h =  lerp(255,r_h,displacement_map.color_blend)
							g_s =  lerp(255,g_s,displacement_map.color_blend)
							b_v =  lerp(255,b_v,displacement_map.color_blend)
						}
						else if displacement_map.color_mode == PULSE_COLOR.A_TO_B_HSV
						{
							//Same but for HSV
							r_h =  lerp(0,r_h,displacement_map.color_blend)
							g_s =  lerp(0,g_s,displacement_map.color_blend)
							b_v =  lerp(255,b_v,displacement_map.color_blend)
						}
					}
					if displacement_map.size.active			&& displacement_map.size.weight		!=0
					{
						var _displace = disp_value
						
						if is_array(pixel)
						{
							var _chan = displacement_map.size.channels
							_displace = mean( (pixel[0]* _chan[0]) , (pixel[1]*_chan[1]) , (pixel[2]*_chan[2]) , (pixel[3]*_chan[3]) )
						}
						
						var _size = lerp(displacement_map.size.range[0],displacement_map.size.range[1],_displace)*displacement_map.size.weight
					}
				}
				
				if color_map != undefined
				{
					var u = color_map.scale_u * (u_coord+color_map.offset_u);
					u = u>1||u<0 ?  abs(frac(u)): u ;
					var v = color_map.scale_v * (v_coord+color_map.offset_v);
					v = v>1||v<0 ?  abs(frac(v)): v ;
					
					var _color = color_map.buffer.GetNormalised(u,v)
						if is_array(_color)
						{
							r_h =  lerp(255,_color[0],color_map.color_blend)
							g_s =  lerp(255,_color[1],color_map.color_blend)
							b_v =  lerp(255,_color[2],color_map.color_blend)
							var _size = lerp(0,part_type.size[1],(_color[3]/255)) //Uses alpha channel to reduce size of particle , as there is no way to pass individual alpha
						}
					var map_color_mode = PULSE_COLOR.COLOR_MAP
				}
				
				#endregion	
	
				// ----- Form culling changes the life or speed of the particle so it doesn't travel past a certain point
				#region FORM CULLING (speed/life change) Depending on direction change speed to conform to form
				
				//If we wish to cull the particle to the "edge" , proceed
				if force_to_edge != PULSE_TO_EDGE.NONE
				{
					//First we define where the EDGE is, where our particle should stop
					
					if abs(angle_difference(dir,transv))<=30	or 	 abs(angle_difference(dir,transv-180))<=30//TRANSVERSAL
					{
						// Find half chord of the coordinate to the circle (distance to the edge)
						var _length_to_edge	= sqrt(power(radius_external,2)-power(length,2)) 
						
						//This second formula should work with any angle, but it doesn't work atm
						//var _length_to_edge	= radius_external*sin(degtorad(dir-90))
					}
					else if abs(angle_difference(dir,normal))<=75	//NORMAL AWAY FROM CENTER
					{	
						//Edge is the distance remaining from the spawn point to the radius
						if length>=0
						{
							var _length_to_edge	=	ext*radius_external-abs(length)
						}
						else
						{
							var _length_to_edge	=	int*radius_internal-abs(length)
						}
					}
					else											//NORMAL TOWARDS CENTER
					{	
						// If particle is going towards a focal point and thats the limit to be followed
						if force_to_edge == PULSE_TO_EDGE.FOCAL_LIFE || force_to_edge == PULSE_TO_EDGE.FOCAL_SPEED
						{
								var _length_to_edge	=	point_distance(x+x_focal_point,y+y_focal_point,x_origin,y_origin)
						}
						else
						{
							if radius_internal >= 0
							{
								var _length_to_edge	=	abs(length)-(radius_internal*int)
							}
							else
							{
								if length>=0
								{
									var _length_to_edge	=	abs(length)
								}
								else
								{
									var _length_to_edge	=	abs(radius_internal*int)
								}
							}	
						}
					}
					
					//Then we calculate the Total Displacement of the particle over its life
					var _accel		=	_speed_start[2]*__life
					var _displacement = (_speed*__life)+_accel
					
					// If the particle moves beyond the edge of the radius, change either its speed or life
					if	_displacement > _length_to_edge
					{
						if force_to_edge == PULSE_TO_EDGE.SPEED || force_to_edge == PULSE_TO_EDGE.FOCAL_SPEED
						{
							_speed	=	(_length_to_edge-_accel)/__life
						} 
						else if force_to_edge == PULSE_TO_EDGE.LIFE || force_to_edge == PULSE_TO_EDGE.FOCAL_LIFE
						{
							__life	=	(_length_to_edge-_accel)/_speed
						}
						//We save this in a boolean as it could be used to change something in the particle appeareance if we wished to
						to_edge	=	true
					}
				
				}
				
				 #endregion

				//APPLY LOCAL AND GLOBAL FORCES
				if array_length(local_forces)>0
				{
					// For each local force, analyze reach and influence over particle
					for (var k=0;k<array_length(local_forces);k++)
					{
						var _weight = 0;
						
						if local_forces[k].weight <= 0 continue //no weight, nothing to do here!
						
						if local_forces[k].range == PULSE_FORCE.RANGE_INFINITE
						{
							_weight = local_forces[k].weight //then weight is the force's full strength
						}
						else if local_forces[k].range == PULSE_FORCE.RANGE_DIRECTIONAL
						{
							var __force_x,__force_y

								__force_x = local_forces[k].local ? (x+local_forces[k].x) : local_forces[k].x
								__force_y = local_forces[k].local ? (y+local_forces[k].y) : local_forces[k].y
							// relative position of the particle to the force
							var _x_relative = x_origin - __force_x
							var _y_relative = y_origin - __force_y
							
							//If the particle is to the left/right, up/down of the force, retrieve appropriate limit							
							var _coordx = _x_relative<0 ? local_forces[k].east : local_forces[k].west
							var _coordy = _y_relative<0 ? local_forces[k].north : local_forces[k].south
							
							// if particle origin is within the area of influence OR the influence is infinite (==-1)
							if (abs(_x_relative)< _coordx || _coordx==-1) 
								&& (abs(_y_relative)< _coordy || _coordy==-1)
							{
								//within influence, calculate weight!
								// If the influence is infinite, apply weight as defined
								// Otherwise, the weight is a linear proportion between 0 (furthest point) and weight (center point of force)								
								var _weightx = _coordx==-1? local_forces[k].weight : lerp(0,local_forces[k].weight,abs(_x_relative)/_coordx )
								var _weighty = _coordy==-1? local_forces[k].weight : lerp(0,local_forces[k].weight,abs(_y_relative)/_coordy )
								
								//Average of vertical and horizontal influences
								_weight= (_weightx+_weighty)/2
							}
							else continue //not within influence. Byebye!
						}
						else if local_forces[k].range == PULSE_FORCE.RANGE_RADIAL
						{
							var __force_x,__force_y

								__force_x = local_forces[k].local ? (x+local_forces[k].x) : local_forces[k].x
								__force_y = local_forces[k].local ? (y+local_forces[k].y) : local_forces[k].y
							
							var _dist = point_distance(x_origin,y_origin,__force_x,__force_y) 
							if _dist < local_forces[k].radius
							{
								_weight= lerp(0,local_forces[k].weight,_dist/local_forces[k].radius )
							}
							else continue //not within influence. 
						}
						
						if (_weight==0) continue; //no weight, nothing to do here!
						
						if local_forces[k].type == PULSE_FORCE.DIRECTION
						{
							// convert to vectors
							var _vec2 =[0,0];
							_vec2[0] = lengthdir_x(_speed,dir);
							_vec2[1] = lengthdir_y(_speed,dir);
							// add force's vectors
							_vec2[0] = _vec2[0]+(local_forces[k].vec[0]*_weight)
							_vec2[1] = _vec2[1]+(local_forces[k].vec[1]*_weight)
							// convert back to direction and speed
							dir = point_direction(0,0,_vec2[0],_vec2[1])
							_speed = sqrt(sqr(_vec2[0]) + sqr(_vec2[1]))
						}
						else if local_forces[k].type = PULSE_FORCE.POINT
						{
							var dir_force	=	(point_direction( (x+local_forces[k].x),(y+local_forces[k].y),x_origin,y_origin)+local_forces[k].direction)%360
							dir = lerp_angle(dir,dir_force,local_forces[k].weight)
						}
						
					}
				}				
				//CHECK FOR OCCLUDERS/COLLISIONS
				
				var _type	=	0
				var _sys	=	0
						
				for (var _repeat =0; _repeat< max(system_array,type_array,1);_repeat++) 
				{
					var _type	= _type+1	=type_array		? 0 : _type+1
					var _sys	= _sys+1	=system_array	? 0 : _type+1
					
					var launch_struct ={
						u_coord				:u_coord,	//Gets passed to the struct but not to the particle, for cache use
						v_coord				:v_coord,	//Gets passed to the struct but not to the particle, for cache use
						life				:__life,
						speed				:_speed,
						x_origin			:x_origin,
						y_origin			:y_origin,
						dir					:dir,
						orient				:_orient,
						size				:_size,
						part_system_index	:part_system_array[_sys].index,
						particle_index		:part_type_array[_type].index,
						// exclussive Map variables :
						r_h	: r_h,
						g_s	: g_s,
						b_v	: b_v,
						color_mode			: map_color_mode,
					}
				
					if _cache
					{
						cache[i]=launch_struct
						i++
					}
					else
					{
						part_type_array[_type].launch(launch_struct)
					}
				}
				
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
	
	static	pulse_from_cache = function(_amount,x,y,_cache,_cache_index = -1 )
	{
		var _cache_length = array_length(_cache)
		var _launch_particle = function(_element,_index)
		{
				part_type.launch(_element)
		}
		if _cache_index == -1 // if -1, assign a random starting point that still fits the required amount of particles
		{
			array_foreach(_cache,_launch_particle,irandom(_cache_length-1-_amount),_amount)
		}
		else
		{
			// if the index is greater than the cache, substract the cache length
			
			while (_cache_index >= _cache_length)
			{
				_cache_index = _cache_index%_cache_length
			}
	
			array_foreach(_cache,_launch_particle,_cache_index,_amount)
		}
	}
}