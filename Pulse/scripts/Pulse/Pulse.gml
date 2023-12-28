/// feather ignore all

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
function pulse_local_emitter(__part_system=__PULSE_DEFAULT_SYS_NAME,__part_type=__PULSE_DEFAULT_PART_NAME,_radius_external=50,anim_curve = undefined) : __pulse_launcher()  constructor
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
	path_res			=	-1
	stencil_profile		= animcurve_really_create({curve_name: "stencil_profile",channels:[
							{name:"a",type: animcurvetype_catmullrom , iterations : 8}, 
							{name:"b",type: animcurvetype_catmullrom , iterations : 8} , 
							{name:"c",type: animcurvetype_catmullrom , iterations : 8}]})
	_channel_01			=	animcurve_get_channel(stencil_profile,0)
	_channel_02			=	animcurve_get_channel(stencil_profile,1)
	_channel_03			=	animcurve_get_channel(stencil_profile,2)
	stencil_tween		=	0
	radius_external		=	abs(_radius_external)	
	radius_internal		=	0
	edge_external		=	radius_external
	edge_internal		=	0
	mask_start			=	0
	mask_end			=	1
	line				=	[0,0]
	
	//emitter properties
	x_focal_point		=	0
	y_focal_point		=	0
	scalex				=	1
	scaley				=	1
	stencil_offset		=	0
	direction_range		=	[0,0]
	
	//Distributions
	distr_along_v_coord	=	__PULSE_DEFAULT_EMITTER_DISTR_ALONG_V_COORD
	distr_along_u_coord	=	__PULSE_DEFAULT_EMITTER_DISTR_ALONG_U_COORD
	distr_speed			=	__PULSE_DEFAULT_DISTR_PROPERTY
	distr_life			=	__PULSE_DEFAULT_DISTR_PROPERTY
	distr_orient		=	PULSE_DISTRIBUTION.NONE
	distr_size			=	PULSE_DISTRIBUTION.NONE
	distr_color_mix		=	PULSE_DISTRIBUTION.NONE
	distr_frame			=	PULSE_DISTRIBUTION.NONE
	divisions_v			=	1
	divisions_u			=	1
	//channels
	v_coord_channel		=	undefined
	u_coord_channel		=	undefined
	speed_channel		=	undefined
	life_channel		=	undefined
	orient_channel		=	undefined
	size_x_channel		=	undefined
	size_y_channel		=	undefined
	color_mix_chanel	=	undefined
	frame_channel		=	undefined
	
	speed_link			=	undefined
	life_link			=	undefined
	orient_link			=	undefined
	size_link			=	undefined
	color_mix_link		=	undefined
	frame_link			=	undefined
	
	color_mix_A			=	[0,0,0]
	color_mix_B			=	[0,0,0]
	
	if animcurve_really_exists(anim_curve)
	{
		interpolations = anim_curve
		
		if animcurve_channel_exists(interpolations,"v_coord")
		{
			distr_along_v_coord	= PULSE_DISTRIBUTION.ANIM_CURVE
			v_coord_channel = animcurve_get_channel(interpolations,"v_coord")
		}
		if animcurve_channel_exists(interpolations,"u_coord")
		{
			distr_along_u_coord	= PULSE_DISTRIBUTION.ANIM_CURVE
			u_coord_channel = animcurve_get_channel(interpolations,"u_coord")
		}
		if animcurve_channel_exists(interpolations,"speed")
		{
			distr_speed	= PULSE_DISTRIBUTION.ANIM_CURVE
			speed_channel = animcurve_get_channel(interpolations,"speed")
		}
		if animcurve_channel_exists(interpolations,"life")
		{
			distr_life	= PULSE_DISTRIBUTION.ANIM_CURVE
			life_channel = animcurve_get_channel(interpolations,"life")
		}
		if animcurve_channel_exists(interpolations,"orient")
		{
			distr_orient	= PULSE_DISTRIBUTION.ANIM_CURVE
			orient_channel = animcurve_get_channel(interpolations,"life")
		}
	}

	force_to_edge		=	__PULSE_DEFAULT_EMITTER_FORCE_TO_EDGE
	alter_direction		=	__PULSE_DEFAULT_EMITTER_ALTER_DIRECTION
	
	//Image maps
	displacement_map	=	undefined
	color_map			=	undefined					

	//Forces, Groups, Colliders
	local_forces		=	[]
		// collisions
	collisions			=	[]
	is_colliding		=	false
	colliding_entities	=	[]
	
	debug_col_rays =[]

	#region EMITTER SETTINGS
	
	static	set_stencil			=	function(__ac_curve,__ac_channel,_channel=0,_mode=PULSE_STENCIL.EXTERNAL)
	{
		animcurve_channel_copy(__ac_curve,__ac_channel,stencil_profile,_channel,false)
		
		if _channel == 0
		{
			animcurve_channel_copy(stencil_profile,_channel,stencil_profile,2,false)
		}
						
		stencil_mode= _mode
			
		return self

	}
	
	static	set_tween_stencil	=	function(__ac_curve_a,_ac_channel_a,__ac_curve_b,_ac_channel_b,_mode=PULSE_STENCIL.A_TO_B)
	{
		set_stencil(__ac_curve_a,_ac_channel_a,0);
		set_stencil(__ac_curve_b,_ac_channel_b,1);

		stencil_tween =	0;	
		
		stencil_mode= _mode
		
		return self
	}
	
	static	set_stencil_offset	=	function(_offset)
	{
		stencil_offset		=	abs(_offset)%1
		return self
	}
	
	static	set_mask			=	function(_mask_start,_mask_end)
	{
		mask_start			=	clamp(_mask_start,0,1);
		mask_end			=	clamp(_mask_end,0,1);
		
		return self
	}

	static	set_radius			=	function(_radius_internal,_radius_external,_edge_internal = _radius_internal,_edge_external = _radius_external)
	{
		radius_internal	=	(_radius_internal != undefined) ? _radius_internal : radius_internal;
		radius_external	=	(_radius_external != undefined) ? _radius_external : radius_external;

		edge_internal	=	(_edge_internal >radius_internal ) ? radius_internal : _edge_internal;
		edge_external	=	(_edge_external <radius_external) ? radius_external : _edge_external;
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
	
	#region NONLINEAR DISTRIBUTIONS
	
	
	static set_distribution_orient	=  function (_mode=PULSE_DISTRIBUTION.RANDOM,_input = undefined,_link_to = undefined)
	{
		switch(_mode)
		{
			case 	PULSE_DISTRIBUTION.ANIM_CURVE:
			case 	PULSE_DISTRIBUTION.LINKED:
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
						distr_orient	=	_mode
						orient_channel	=	animcurve_get_channel(_input[0],_input[1])
						orient_link		=	_link_to
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")
				break
			}
			default:
				distr_orient = PULSE_DISTRIBUTION.RANDOM
		}
		

		return self
	}
	
	static set_distribution_life	=  function (_mode=PULSE_DISTRIBUTION.RANDOM,_input = undefined,_link_to = undefined)
	{
		switch(_mode)
		{
			case 	PULSE_DISTRIBUTION.ANIM_CURVE:
			case 	PULSE_DISTRIBUTION.LINKED:
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
						distr_life	=	_mode
						life_channel	=	animcurve_get_channel(_input[0],_input[1])
						life_link		=	_link_to
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")
				break
			}
			default:
				distr_life = PULSE_DISTRIBUTION.RANDOM
		}
		

		return self
	}
	
	static set_distribution_speed	=  function (_mode=PULSE_DISTRIBUTION.RANDOM,_input = undefined,_link_to = undefined)
	{
		if _link_to == PULSE_LINK_TO.SPEED
		{
			__pulse_show_debug_message("PULSE ERROR: Invalid link property. Speed can't link to Speed")	
			return self
		}

		switch(_mode)
		{
			case 	PULSE_DISTRIBUTION.ANIM_CURVE:
			case 	PULSE_DISTRIBUTION.LINKED:
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
						distr_speed	=	_mode
						speed_channel	=	animcurve_get_channel(_input[0],_input[1])
						speed_link		=	_link_to
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")
				break
			}
			default:
				distr_speed = PULSE_DISTRIBUTION.RANDOM
		}
		return self
	}
	
	static set_distribution_size	=  function (_mode=PULSE_DISTRIBUTION.RANDOM,_input = undefined,_link_to = undefined)
	{
		switch(_mode)
		{
			case 	PULSE_DISTRIBUTION.ANIM_CURVE:
			case 	PULSE_DISTRIBUTION.LINKED:
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
						distr_size		=	_mode
						size_x_channel	=	animcurve_get_channel(_input[0],_input[1])
						if array_length(_input)>1
						{
							size_y_channel	=	animcurve_get_channel(_input[0],_input[2])
						}
						size_link		=	_link_to
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")
				break
			}
			default:
				distr_size = PULSE_DISTRIBUTION.RANDOM
		}
		

		return self
	}
	
	static set_distribution_color_mix=  function ( _color_A, _color_B,_mode=PULSE_DISTRIBUTION.RANDOM,_input = undefined,_link_to = undefined)
	{
		color_mix_A[0] = color_get_blue(_color_A)
		color_mix_A[1] = color_get_green(_color_A)
		color_mix_A[2] = color_get_red(_color_A)
		
		color_mix_B[0] = color_get_blue(_color_B)
		color_mix_B[1] = color_get_green(_color_B)
		color_mix_B[2] = color_get_red(_color_B)
		
		switch(_mode)
		{
			case 	PULSE_DISTRIBUTION.ANIM_CURVE:
			case 	PULSE_DISTRIBUTION.LINKED:
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
						distr_color_mix		=	_mode
						color_mix_channel	=	animcurve_get_channel(_input[0],_input[1])
						color_mix_link		=	_link_to
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")
				break
			}
			default:
				distr_size = PULSE_DISTRIBUTION.RANDOM
		}
		

		return self
	}
	
	static set_distribution_frame	=  function (_mode=PULSE_DISTRIBUTION.RANDOM,_input = undefined,_link_to = undefined)
	{
		if !part_type.set_to_sprite
		{
			__pulse_show_debug_message($"PULSE ERROR: Particle {part_type.name} not set to sprite")	
			return self	
		}
		switch(_mode)
		{
			case 	PULSE_DISTRIBUTION.ANIM_CURVE:
			case 	PULSE_DISTRIBUTION.LINKED:
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
						distr_frame		=	_mode
						frame_channel	=	animcurve_get_channel(_input[0],_input[1])
						frame_link		=	_link_to
						with(part_type)
						{
							set_sprite(sprite[0],sprite[1],sprite[2],false,0)
						}
						__pulse_show_debug_message($"PULSE WARNING: Sprite of particle {part_type.name} : Random set to False")	
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")
				break
			}
			default:
				distr_size = PULSE_DISTRIBUTION.RANDOM
		}
		

		return self
	}
	
	static set_distribution_u		=  function (_mode=PULSE_DISTRIBUTION.RANDOM,_input=undefined)
	{
		switch(_mode)
		{
			case 	PULSE_DISTRIBUTION.RANDOM:
			{
				distr_along_u_coord		= PULSE_DISTRIBUTION.RANDOM
			break
			}
			case 	PULSE_DISTRIBUTION.EVEN:
			{
				distr_along_u_coord		= PULSE_DISTRIBUTION.EVEN
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
			case 	PULSE_DISTRIBUTION.ANIM_CURVE:
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
						distr_along_u_coord	= PULSE_DISTRIBUTION.ANIM_CURVE
						u_coord_channel = animcurve_get_channel(_input[0],_input[1])
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")	
			break
			}
			case 	PULSE_DISTRIBUTION.LINKED:
			{
				__pulse_show_debug_message("PULSE ERROR: Distribution Linked not allowed in U Coordinate")
				break
			}
		}
		
		return self
	}
	
	static set_distribution_v		=  function (_mode=PULSE_DISTRIBUTION.RANDOM,_input=undefined)
	{
		switch(_mode)
		{
			case 	PULSE_DISTRIBUTION.RANDOM:
			{
				distr_along_v_coord		= PULSE_DISTRIBUTION.RANDOM
			break
			}
			case 	PULSE_DISTRIBUTION.EVEN:
			{
				distr_along_v_coord		= PULSE_DISTRIBUTION.EVEN
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
			case 	PULSE_DISTRIBUTION.ANIM_CURVE:
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
						distr_along_v_coord	= PULSE_DISTRIBUTION.ANIM_CURVE
						v_coord_channel = animcurve_get_channel(_input[0],_input[1])
						break
					}
				}
				__pulse_show_debug_message("PULSE ERROR: Distribution Anim Curve or channel not found")	
			break
			}
			case 	PULSE_DISTRIBUTION.LINKED:
			{
				__pulse_show_debug_message("PULSE ERROR: Distribution Linked not allowed in V Coordinate")
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
			displacement_map	=	new __pulse_map(_map,self) 
			return displacement_map
		}
		else
		{		
		__pulse_show_debug_message("PULSE ERROR: Displacement Map is a wrong format")
		}
	}
	
	static	set_color_map			=	function(_map,_blend=1)
	{
		if  is_instanceof(_map, __buffered_sprite) 
		{
			color_map			=	new __pulse_color_map(_map, self) 
			color_map.set_color_map(_blend)
		}
		else
		{
		__pulse_show_debug_message("PULSE ERROR: Color Map is a wrong format")
		}
		return self
	}
	
	#endregion
	
	#region FORCES
	static	add_local_force			=	function(_force)
	{
		if is_instanceof(_force,pulse_force)
		{
			array_push(local_forces,_force)
		}
		return self
	}
	
	static	remove_local_force		=	function(_force)
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
	#endregion
	
	static	draw_debug				=	function(x,y)
	{
		// draw radiuses
		var ext_x =  radius_external*scalex
		var int_x =  radius_internal*scalex
		var ext_y =  radius_external*scaley
		var int_y =  radius_internal*scaley
		
		if form_mode == PULSE_FORM.ELLIPSE
		{
			draw_ellipse(x-ext_x,y-ext_y,x+ext_x,y+ext_y,true)
			draw_ellipse(x-int_x,y-int_y,x+int_x,y+int_y,true)
		}
		else if form_mode == PULSE_FORM.PATH
		{
			draw_path(path_a,x,y,true)
		}
		
		//draw origin
		draw_line_width_color(x-10,y,x+10,y,1,c_green,c_green)
		draw_line_width_color(x,y-10,x,y+10,1,c_green,c_green)
		
		//draw focal point
		if x_focal_point != 0 or y_focal_point!= 0
		{
			draw_line_width_color(x-10+x_focal_point,y+y_focal_point,x+10+x_focal_point,y+y_focal_point,3,c_yellow,c_yellow)
			draw_line_width_color(x+x_focal_point,y-10+y_focal_point,x+x_focal_point,y+10+y_focal_point,3,c_yellow,c_yellow)
		}
		
		if array_length(debug_col_rays) > 0
		{
			if is_colliding
			{
				draw_set_color(c_fuchsia)
			}else
			{
				draw_set_color(c_yellow)
			}
			for( var _i = 0 ; _i<array_length(debug_col_rays); _i++)
			{
				var _x = x+lengthdir_x(debug_col_rays[_i].value*ext_x,(debug_col_rays[_i].posx*360)%360)
				var _y = y+lengthdir_y(debug_col_rays[_i].value*ext_y,(debug_col_rays[_i].posx*360)%360)
				draw_circle(_x,_y,5,false)
			}
			draw_set_color(c_white)
		}

		//draw angle

		var _anstart_x = x+lengthdir_x(ext_x,(mask_start*360)%360)
		var _anstart_y = y+lengthdir_y(ext_y,(mask_start*360)%360)
		var _anend_x = x+lengthdir_x(ext_x,(mask_end*360)%360)
		var _anend_y = y+lengthdir_y(ext_y,(mask_end*360)%360)
		draw_line_width_color(x,y,_anstart_x,_anstart_y,1,c_green,c_green)
		draw_text(_anstart_x,_anstart_y,$"{mask_start}")
		draw_text(_anend_x,_anend_y,$"{mask_end}")
		draw_line_width_color(x,y,_anend_x,_anend_y,1,c_green,c_green)
		
		// draw direction
		var _directionrange_x = x+lengthdir_x(ext_x/2,direction_range[0])
		var _directionrange_y = y+lengthdir_y(ext_y/2,direction_range[0])
		var angle = (direction_range[0]+direction_range[1])/2

		draw_arrow(x,y,_directionrange_x,_directionrange_y,10)
	}
	
	static	add_collisions			=	function(_object)
	{
		array_push(collisions,_object)
		
		return self
	}
	
	#region private methods
	
	static __assign_u_coordinate	=	function(div_u,_p={})
	{
		//Chooses a u coord at random along the form (number between 0 and 1)


		if mask_start==mask_end
		{
			_p.u_coord			??=	mask_end;
		}
		else if distr_along_u_coord	== PULSE_DISTRIBUTION.RANDOM
		{
			//Use random to distribute along 
					
			_p.u_coord			??=	random_range(mask_start,mask_end);
		}
		else if distr_along_u_coord	== PULSE_DISTRIBUTION.ANIM_CURVE
		{
			//use an animation curve to distribute the values
					
			_p.u_coord			??=	lerp(mask_start,mask_end,animcurve_channel_evaluate(u_coord_channel,random(1)))
		}
		else if distr_along_u_coord	== PULSE_DISTRIBUTION.EVEN
		{
			//Distribute the u_coord evenly by particle amount and number of divisions_v
			
			_p.u_coord ??= lerp(mask_start, mask_end,div_u/divisions_u)
		}
		return _p
	}
						
	static __calculate_stencil		=	function(_particle, _emitter={}){
		
		var eval, eval_a, eval_b, eval_c;
			
		// early exit if there are no stencils
		if stencil_mode == PULSE_STENCIL.NONE 
		{
			_emitter.ext		= 1
			_emitter.int		= 1
			_emitter.total		= 1
			_emitter.edge		= 1
			return _emitter
		}
			
		var dir_stencil = (stencil_offset+_particle.u_coord)%1;
			
		eval_c	=	clamp(animcurve_channel_evaluate(_channel_01,dir_stencil),0,1);
		eval_a	=	clamp(animcurve_channel_evaluate(_channel_03,dir_stencil),0,1);
		eval	=	eval_a
		
		eval_b	=	clamp(animcurve_channel_evaluate(_channel_02,dir_stencil),0,1);
		eval	=	lerp(eval_a,eval_b,abs(stencil_tween))
				
		switch (stencil_mode)
		{
			case PULSE_STENCIL.A_TO_B: //SHAPE A IS EXTERNAL, B IS INTERNAL
			{
				_emitter.ext		= eval_a
				_emitter.int		= eval_b
				_emitter.total		= eval
				_emitter.edge		= eval_c
				break;
			}
			case PULSE_STENCIL.EXTERNAL: //BOTH SHAPES ARE EXTERNAL, MODULATED BY TWEEN
			{
				_emitter.ext		= eval
				_emitter.int		= 1
				_emitter.total		= eval
				_emitter.edge		= eval_c
				break;
			}
			case PULSE_STENCIL.INTERNAL: //BOTH SHAPES ARE INTERNAL, MODULATED BY TWEEN
			{
				_emitter.ext		= 1
				_emitter.int		= eval
				_emitter.total		= eval
				_emitter.edge		= 1
				break;
			}
		}
					
		return _emitter
	}
	
	static __assign_v_coordinate	=	function(div_v,_p,_e={}){
		
		if radius_internal==radius_external
		{
			// If the 2 radius are equal, then there is no need to randomize
			_p.v_coord		??=	_e.total				//"total" can be 1 if there is no Stencil, or a number between 0 to 1 depending on the evaluated curve
			_p.length		=	_e.total*radius_external;
		}
		else if distr_along_v_coord == PULSE_DISTRIBUTION.RANDOM
		{
			//Distribute along the v coordinate (across the radius in a circle) by randomizing, then adjusting by shape evaluation
			_p.v_coord		??= random(1)
			_p.length = lerp(_e.int*radius_internal,_e.ext*radius_external,_p.v_coord)
			
		}
		else if distr_along_v_coord == PULSE_DISTRIBUTION.ANIM_CURVE
		{
			//Distribute along the radius by animation curve distribution, then adjusting by shape evaluation
			_p.v_coord		??= random(1)
			_p.length		=	lerp(_e.int*radius_internal,_e.ext*radius_external,animcurve_channel_evaluate(v_coord_channel,_p.v_coord))
		}
		else if distr_along_v_coord == PULSE_DISTRIBUTION.EVEN
		{
			//Distribute evenly
			_p.v_coord		??=(div_v/divisions_v)
			_p.length		=	lerp(_e.int*radius_internal,_e.ext*radius_external,_p.v_coord)
			
		}
					
		return _p
	}
	
	static __assign_properties		=	function(_p){
				
			function get_link_value(_link,_p)
			{
				var _amount
				switch( _link )
				{
					case PULSE_LINK_TO.DIRECTION:
						_amount	=	_p.dir/360
					break
					case PULSE_LINK_TO.PATH_SPEED:
						_amount	=	form_mode == PULSE_FORM.PATH ? path_get_speed(path_a,_p.u_coord)/100 : random(1)
					break
					case PULSE_LINK_TO.SPEED:
						_amount	=	(_p.speed -part_type.speed[0])/(part_type.speed[1] - part_type.speed[0])
					break
					case PULSE_LINK_TO.U_COORD:
						_amount	=	_p.u_coord
					break
					case PULSE_LINK_TO.V_COORD:
						_amount	=	_p.v_coord
					break
				}
				return _amount
			}	
				
			#region SPEED
			if distr_speed == PULSE_DISTRIBUTION.RANDOM
			{
				if part_type.speed[0]==part_type.speed[1]
				{
					_p.speed		=	part_type.speed[0]
				}
				else
				{
					_p.speed		=	random_range(part_type.speed[0],part_type.speed[1])
				}
			}
			else
			{
				var _amount;
				
				if distr_speed == PULSE_DISTRIBUTION.LINKED
				{
					_amount = get_link_value(speed_link,_p)
				}
				else
				{
					_amount = random(1)
				}
				
				_p.speed		=	lerp(part_type.speed[0],part_type.speed[1],animcurve_channel_evaluate(speed_channel,_amount))
			}
			#endregion
			
			#region life
			if distr_life == PULSE_DISTRIBUTION.RANDOM
			{
				if part_type.life[0]==part_type.life[1]
				{
					_p.life		=	part_type.life[0]
				}
				else
				{
					_p.life		=	random_range(part_type.life[0],part_type.life[1])
				}
			}
			else
			{
				var _amount= 0;
				
				if distr_life == PULSE_DISTRIBUTION.LINKED
				{
					_amount = get_link_value(life_link,_p)
				}
				else
				{
					_amount = random(1)
				}
				
				_p.life		=	lerp(part_type.life[0],part_type.life[1],animcurve_channel_evaluate(life_channel,_amount))
			}
			#endregion
		
			#region orient
			if distr_orient != PULSE_DISTRIBUTION.RANDOM && distr_orient != PULSE_DISTRIBUTION.NONE
			{
				var _amount= 0;
				
				if distr_orient == PULSE_DISTRIBUTION.LINKED
				{
					_amount = get_link_value(orient_link,_p)
				}
				else
				{
					_amount = random(1)
				}
				
				_p.orient		=	lerp(part_type.orient[0],part_type.orient[1],animcurve_channel_evaluate(orient_channel,_amount))
			}
			#endregion
			
			#region size

			if distr_size != PULSE_DISTRIBUTION.RANDOM && distr_size != PULSE_DISTRIBUTION.NONE
			{
				var _amount = 0;
				
				if distr_size == PULSE_DISTRIBUTION.LINKED
				{
					_amount = get_link_value(size_link,_p)
				}
				else
				{
					_amount = random(1)
				}
				
				_p.size = array_create(4,0)
				_p.size[0]		=	lerp(part_type.size[0],part_type.size[2],animcurve_channel_evaluate(size_x_channel,_amount))
				_p.size[1]		=	lerp(part_type.size[1],part_type.size[3],animcurve_channel_evaluate(size_y_channel,_amount))
			}
			#endregion
			
			#region frame

			if distr_frame != PULSE_DISTRIBUTION.NONE
			{
				var _amount= 0;
				
				if distr_frame == PULSE_DISTRIBUTION.LINKED
				{
					_amount = get_link_value(frame_link,_p)
				}
				else
				{
					_amount = random(1)
				}
				
				_p.frame		=	lerp(0,sprite_get_number(part_type.sprite),animcurve_channel_evaluate(frame_channel,_amount))
			}
			#endregion
			
			#region color

			if distr_color_mix != PULSE_DISTRIBUTION.NONE
			{
				var _amount= 0;
				
				if distr_color_mix == PULSE_DISTRIBUTION.LINKED
				{
					_amount = get_link_value(color_mix_link,_p)
				}
				else
				{
					_amount = random(1)
				}
					_amount = animcurve_channel_evaluate(color_mix_channel,_amount)
					_p.r_h =  lerp(color_mix_A[2],color_mix_B[2],_amount)
					_p.g_s =  lerp(color_mix_A[1],color_mix_B[1],_amount)
					_p.b_v =  lerp(color_mix_A[0],color_mix_B[0],_amount)
					_p.color_mode = PULSE_COLOR.A_TO_B_RGB
			}
			#endregion

			
			return _p
	}
	
	static __set_normal_origin		=	function(_p,x,y){
				
		switch (form_mode)
		{
			case PULSE_FORM.PATH:
			{
				var j			= 1/path_res
				_p.x_origin	= path_get_x(path_a,_p.u_coord)
				_p.y_origin	= path_get_y(path_a,_p.u_coord)
				var x1			= path_get_x(path_a,_p.u_coord+j)
				var y1			= path_get_y(path_a,_p.u_coord+j)
				_p.transv		= point_direction(_p.x_origin,_p.y_origin,x1,y1)
							
				// Direction Increments do not work with particle types. Leaving this in hopes that some day, they will
				//var x2	= path_get_x(path_a,u_coord+(j*2))
				//var y2	= path_get_y(path_a,u_coord+(j*2))
				//arch		= angle_difference(transv, point_direction(x_origin,y_origin,x2,y2))/point_distance(x_origin,y_origin,x2,y2) 

				_p.normal		= ((_p.transv+90)>=360) ? _p.transv-270 : _p.transv+90;
						
				_p.x_origin	+= (lengthdir_x(_p.length,_p.normal)*scalex);
				_p.y_origin	+= (lengthdir_y(_p.length,_p.normal)*scaley);
						
				if x_focal_point!=0 || y_focal_point !=0 // if focal u_coord is in the center, the normal is equal to the angle from the center
				{
					//then, the direction from the focal point to the origin
					_p.normal		=	point_direction(x+(x_focal_point*scalex),y+(y_focal_point*scaley),_p.x_origin,_p.y_origin)
					_p.transv		=	((_p.normal-90)<0) ? _p.normal+270 : _p.normal-90;
				}
						
				break;
			}
			case PULSE_FORM.ELLIPSE:
			{
				_p.normal		=	(_p.u_coord*360)%360
						
				_p.x_origin	=	x
				_p.y_origin	=	y
						

				_p.x_origin	+= (lengthdir_x(_p.length,_p.normal)*scalex);
				_p.y_origin	+= (lengthdir_y(_p.length,_p.normal)*scaley);
	
							
				if x_focal_point!=0 || y_focal_point !=0 // if focal u_coord is in the center, the normal is equal to the angle from the center
				{
					//then, the direction from the focal point to the origin
					_p.normal		=	point_direction(x+(x_focal_point*scalex),y+(y_focal_point*scaley),_p.x_origin,_p.y_origin)
				}

				_p.transv		=	((_p.normal-90)<0) ? _p.normal+270 : _p.normal-90;
	
			break;
			}
			case PULSE_FORM.LINE:
			{
				_p.transv		= point_direction(x,y,x+line[0],y+line[1])
				_p.normal		= ((_p.transv+90)>=360) ? _p.transv-270 : _p.transv+90;
				_p.x_origin	= lerp(x,x+line[0],_p.u_coord)
				_p.y_origin	= lerp(y,y+line[1],_p.u_coord)
						
				if _p.v_coord != 0
				{
					_p.x_origin	+= (lengthdir_x(_p.length,_p.normal)*scalex);
					_p.y_origin	+= (lengthdir_y(_p.length,_p.normal)*scaley);
				}
							
				if x_focal_point!=0 || y_focal_point !=0 // if focal u_coord is in the center, the normal is equal to the angle from the center
				{
					//then, the direction from the focal point to the origin
					_p.normal		=	point_direction(x+(x_focal_point*scalex),y+(y_focal_point*scaley),_p.x_origin,_p.y_origin)
					_p.transv		=	((_p.normal-90)<0) ? _p.normal+270 : _p.normal-90;
				}
			}
		}
			return _p
		}

	static __assign_direction		=	function(_p){
				
		if alter_direction
		{
			if direction_range[0]!=direction_range[1]
			{
				_p.dir =	(_p.normal + random_range(direction_range[0],direction_range[1]))%360
			}
			else
			{
				_p.dir =	(_p.normal + direction_range[0])%360
			}
				
			if _p.length<0		// Mirror angle if the particle is on the negative side of the emitter
			{
				_p.dir		= (_p.transv+angle_difference(_p.transv,_p.dir))%360
			}
			/*					
			if _p.speed<0		// If Speed is Negative flip the direction and make it positive
			{
				_p.dir		=	_p.dir+180%360
				_p.speed*=-1
				return _p
			}*/
			return _p
		}
		else
		{
			_p.dir = (random_range(part_type.direction[0],part_type.direction[1]))%360
			return _p
		}
	}
	
	static __check_form_collide		=	function(_p,_e,x,y){
				
		//If we wish to cull the particle to the "edge" , proceed
		if force_to_edge == PULSE_TO_EDGE.NONE
		{
			return _p 
		}
		//First we define where the EDGE is, where our particle should stop
		
		var to_transversal = abs(angle_difference(_p.dir,_p.transv))
		
		if to_transversal <=30	or 	 abs(to_transversal-180) <=30//TRANSVERSAL
		{
			// Find half chord of the coordinate to the circle (distance to the edge)
			var _a =power(_e.edge*edge_external,2)-power(_p.length,2)
			var _length_to_edge	= sqrt(abs(_a)) 
						
			//This second formula should work with any angle, but it doesn't work atm
			//var _length_to_edge	= radius_external*sin(degtorad(dir-90))
		}
		else if abs(angle_difference(_p.dir,_p.normal))<=75	//NORMAL AWAY FROM CENTER
		{	
			//Edge is the distance remaining from the spawn point to the radius
			if _p.length>=0
			{
				var _length_to_edge	=	(_e.edge*edge_external)-_p.length
				//var _length_to_radius	=	(_e.ext*radius_external)-_p.length
			}
			else
			{
				var _length_to_edge	=	(_e.edge*edge_internal)+_p.length
			}
		}
		else											//NORMAL TOWARDS CENTER
		{	
			// If particle is going towards a focal point and thats the limit to be followed
			if force_to_edge == PULSE_TO_EDGE.FOCAL_LIFE || force_to_edge == PULSE_TO_EDGE.FOCAL_SPEED
			{
					var _length_to_edge	=	point_distance(x+x_focal_point,y+y_focal_point,_p.x_origin,_p.y_origin)
			}
			else
			{
				if edge_internal >= 0
				{
					var _length_to_edge	=	abs(_p.length)-(edge_internal*_e.int)
				}
				else
				{
					if _p.length>=0
					{
						var _length_to_edge	=	abs(_p.length)
					}
					else
					{
						var _length_to_edge	=	abs(edge_internal*_e.int)
					}
				}	
			}
		}
					
		//Then we calculate the Total Displacement of the particle over its life
		var _accel		=	part_type.speed[2]*_p.life
		var _displacement = (_p.speed*_p.life)+_accel
		
		_p.to_edge	=	false
		// If the particle moves beyond the edge of the radius, change either its speed or life
		if	_displacement > _length_to_edge
		{
			if force_to_edge == PULSE_TO_EDGE.SPEED || force_to_edge == PULSE_TO_EDGE.FOCAL_SPEED
			{
				_p.speed	=	(_length_to_edge-_accel)/_p.life
			} 
			else if force_to_edge == PULSE_TO_EDGE.LIFE || force_to_edge == PULSE_TO_EDGE.FOCAL_LIFE
			{
				_p.life	=	(_length_to_edge-_accel)/_p.speed
			}
			//We save this in a boolean as it could be used to change something in the particle appeareance if we wished to
		//	if	(_length_to_edge - _length_to_radius) < -20
			_p.to_edge	=	true
		}
				
		return _p 		
				
	}
	
	static __check_forces			=	function(_p,x,y){
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
				var _x_relative = _p.x_origin - __force_x
				var _y_relative = _p.y_origin - __force_y
							
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
				_vec2[0] = lengthdir_x(_p.speed,_p.dir);
				_vec2[1] = lengthdir_y(_p.speed,_p.dir);
				// add force's vectors
				_vec2[0] = _vec2[0]+(local_forces[k].vec[0]*_weight)
				_vec2[1] = _vec2[1]+(local_forces[k].vec[1]*_weight)
				// convert back to direction and speed
				_p.dir = point_direction(0,0,_vec2[0],_vec2[1])
				_p.speed = sqrt(sqr(_vec2[0]) + sqr(_vec2[1]))
			}
			else if local_forces[k].type = PULSE_FORCE.POINT
			{
				var dir_force	=	(point_direction( (x+local_forces[k].x),(y+local_forces[k].y),x_origin,y_origin)+local_forces[k].direction)%360
				_p.dir = lerp_angle(_p.dir,dir_force,local_forces[k].weight)
			}
						
		}
		return _p
	}
	
	static __apply_color_map		= function(_p,_e)
				{
					var u = color_map.scale_u * (_p.u_coord+color_map.offset_u);
					u = u>1||u<0 ?  abs(frac(u)): u ;
					var v = color_map.scale_v * (_p.v_coord+color_map.offset_v);
					v = v>1||v<0 ?  abs(frac(v)): v ;
					
					var _color = color_map.buffer.GetNormalised(u,v)
							_p.r_h =  lerp(255,_color[0],color_map.color_blend)
							_p.g_s =  lerp(255,_color[1],color_map.color_blend)
							_p.b_v =  lerp(255,_color[2],color_map.color_blend)
							_p.size = lerp(0,part_type.size[1],(_color[3]/255)) //Uses alpha channel to reduce size of particle , as there is no way to pass individual alpha
					
				}
	
	static __apply_displacement		= function(_p,_e)
		{
			var u = displacement_map.scale_u * (_p.u_coord+displacement_map.offset_u);
			u = u>1||u<0 ?  abs(frac(u)): u ;
			var v = displacement_map.scale_v * (_p.v_coord+displacement_map.offset_v);
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
				_p.length		=	lerp(_p.length,lerp(_e.int*radius_internal+_p.length,_e.ext*radius_external+_p.length,disp_value),displacement_map.position.weight)
			}
			if displacement_map.speed.active		&& displacement_map.speed.weight	!=0
			{
				var _displace = disp_value
				if is_array(pixel)
				{
					var _chan = displacement_map.speed.channels
					_displace = mean( (pixel[0]* _chan[0]) , (pixel[1]*_chan[1]) , (pixel[2]*_chan[2]) , (pixel[3]*_chan[3]) )
				}
				_p.speed		=	lerp(_p.speed,lerp(displacement_map.speed.range[0],displacement_map.speed.range[1],_displace),displacement_map.speed.weight)
			}
			if displacement_map.life.active			&& displacement_map.life.weight		!=0
			{
				var _displace = disp_value
				if is_array(pixel)
				{
					var _chan = displacement_map.life.channels
					_displace = mean( (pixel[0]* _chan[0]) , (pixel[1]*_chan[1]) , (pixel[2]*_chan[2]) , (pixel[3]*_chan[3]) )
				}
				_p.life		=	lerp(_p.life,lerp(displacement_map.life.range[0],displacement_map.life.range[1],_displace),displacement_map.life.weight)
			}
			if displacement_map.orientation.active	&& displacement_map.orient.weight	!=0
			{
				_p.orient		=	lerp(part_type.orient[0],part_type.orient[1],disp_value*displacement_map.orient.weight)
			}
			if displacement_map.color_A_to_B		&& distr_color_mix		!= PULSE_COLOR.COLOR_MAP
			{
				if is_array(pixel)
				{
					// lerping between the user-provided colors A and B , using the normalized pixel value for the coordinate (most usually between black (0) and white (1) )
					//In this case, pixel is an array, so there are individual values for all channels
					_p.r_h =  lerp(displacement_map.color_A[0],displacement_map.color_B[0],pixel[0])
					_p.g_s =  lerp(displacement_map.color_A[1],displacement_map.color_B[1],pixel[1])
					_p.b_v =  lerp(displacement_map.color_A[2],displacement_map.color_B[2],pixel[2])
				}
				else
				{
					//While here, all channels are compressed into a single channel (Probably when generating a texture with Dragonite's Macaw)
					_p.r_h =  lerp(displacement_map.color_A[0],displacement_map.color_B[0],disp_value)
					_p.g_s =  lerp(displacement_map.color_A[1],displacement_map.color_B[1],disp_value)
					_p.b_v =  lerp(displacement_map.color_A[2],displacement_map.color_B[2],disp_value)
				}

				if parent.distr_color_mix == PULSE_COLOR.A_TO_B_RGB
				{
					// "Blend" here is refering to the blending if the particle sprite has colors. If its mixed with pure white it wont change.
					_p.r_h =  lerp(255,r_h,displacement_map.color_blend)
					_p.g_s =  lerp(255,g_s,displacement_map.color_blend)
					_p.b_v =  lerp(255,b_v,displacement_map.color_blend)
				}
				else if displacement_map.color_mode == PULSE_COLOR.A_TO_B_HSV
				{
					//Same but for HSV
					_p.r_h =  lerp(0,r_h,displacement_map.color_blend)
					_p.g_s =  lerp(0,g_s,displacement_map.color_blend)
					_p.b_v =  lerp(255,b_v,displacement_map.color_blend)
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
				_p.size = lerp(displacement_map.size.range[0],displacement_map.size.range[1],_displace)*displacement_map.size.weight
			}
	}
	
	#endregion
	
	 /**
	 * @desc Generates a modified stencil which adapts to colliding objects. Returns an array that contains the IDs of all colliding instances 
	 * @param {any} _collision_obj Any collideable element that can regularly be an argument for collision functions
	 * @param {bool}_prec Whether the collision is precise (true, slow) or not (false, fast)
	 * @param {real} _rays amount of rays emitted to create a stencil collision
	 */
	static	check_collision = function(x,y,_collision_obj=collisions, _occlude = true, _prec = false , _rays = 32 )
	{
		if is_array(_collision_obj){
		if array_length(_collision_obj)==0
			return undefined
		}
		/// Check for collision of emitter by bbox
		switch (form_mode)
		{
			case PULSE_FORM.PATH:
			{
				/// if path, find bounding box of path, then check with collision
				var _bbox = path_get_bbox(path_a,edge_external,mask_start,mask_end)
				var _collision = collision_rectangle(_bbox[0],_bbox[1],_bbox[2],_bbox[3],_collision_obj,_prec,true)

				break;
			}
			case PULSE_FORM.ELLIPSE:
			{
				if scalex != 1 or scaley != 1
				{
					var _collision = collision_ellipse((edge_external-x)*scalex,(edge_external-y)*scaley,(edge_external+x)*scalex,(edge_external+y)*scaley,_collision_obj,_prec, false)
				}
				else
				{
					var _collision = collision_circle(x,y,edge_external,_collision_obj,_prec, false)
				}
			break;
			}
			case PULSE_FORM.LINE:
			{
				var transv		= point_direction(x,y,x+line[0],y+line[1])
				var normal		= ((transv+90)>=360) ? transv-270 : transv+90;
				
				var b	= [x+line[0],y+line[1]]
				var a	= [x,y]
				var c = [0,0]		
				var d = [0,0]	
				
				var dir_x = (lengthdir_x(edge_external,normal)*scalex);
				var dir_y = (lengthdir_y(edge_external,normal)*scaley);
				
				c[0] =	a[0] + dir_x
				c[1] =	a[1] + dir_y
				d[0] =	b[0] + dir_x
				d[1] =	b[1] + dir_y
				
				var left	= min(a[0],b[0],c[0],d[0])
				var right	= max(a[0],b[0],c[0],d[0])
				var top		= min(a[1],b[1],c[1],d[1])
				var bottom	= max(a[1],b[1],c[1],d[1])
				
				var _collision = collision_rectangle(left,top,right,bottom,_collision_obj,_prec,true)

				return;
			}
		}
		if _collision == undefined || _collision == noone
		{
			if is_colliding
			{
				// Reset the Curve to its original state
				animcurve_channel_copy(stencil_profile, "c",stencil_profile, "a")
				is_colliding = false
			}
			return undefined
		}
		
		is_colliding = true
		array_resize(colliding_entities,0)
		
		// Emit 32 rays and check for collisions
		var _source		=	animcurve_get_channel(stencil_profile, 2),
		 _points		=	new animcurve_point_collection( animcurve_points_subdiv(_source,_rays),mask_start,mask_end) ,
		 _ray			= {u_coord : 0 , v_coord : 0 , length : 0} ,
		 _fail			= 0 ,
		 _dir_stencil	= animcurve_points_find_closest(_points.collection, stencil_offset,false),
		 _mod_i			= _dir_stencil,
		 _l				= _points.length,
		 //_rays_changed	= []
		 
		for(var i =	0; i < _l ; i +=1)
		{
			_ray.u_coord	= _points.collection[i].posx
			_mod_i = (i+_dir_stencil)%_l
			
			var _length		=	edge_external*_points.collection[_mod_i].value //_points.collection[dir_stencil].value
			_ray			= __set_normal_origin(_ray,x,y)

			var _ray_collision	= raycast_hit_point_2d(_ray.x_origin,_ray.y_origin,_collision_obj,_ray.normal,_length,_prec,true)
			
			if _ray_collision != noone
			{
				var _value = (point_distance(_ray.x_origin,_ray.y_origin,_ray_collision.x,_ray_collision.y)/edge_external) 
				_points.new_point(_points.collection[_mod_i].posx,_value,true)
				
				// Add colliding entity to an array
				if !array_contains(colliding_entities,_ray_collision.z)
				{
					array_push(colliding_entities,_ray_collision.z)		
				}
			}
			else
			{
				_fail ++
			}
		}
		
		if _fail = _points.length
		{
			if is_colliding
			{
				animcurve_channel_copy(stencil_profile, "c",stencil_profile, "a")
				is_colliding = false
			}
			return undefined
		}
		
		_points = _points.export()

		if stencil_mode == PULSE_STENCIL.NONE
		{
			stencil_mode = PULSE_STENCIL.EXTERNAL
		} 

		debug_col_rays = _points
		
		if _occlude		animcurve_points_set(stencil_profile,"a",_points)
	
		return colliding_entities
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
				__pulse_show_debug_message("PULSE WARNING: System is currently asleep!")
				exit
			}
		}
		if part_system.threshold != 0 && ( time_source_get_state(part_system.count) != time_source_state_active)
		{
			if _amount_request >= part_system.threshold
			{
				part_system.factor *= (part_system.threshold/_amount_request)
			}
				
			time_source_reset(part_system.count)
			time_source_start(part_system.count)
		}
		
		var _amount = floor((_amount_request*part_system.factor)*global.pulse.particle_factor)
		if _amount	== 0 exit
	
		var div_v,div_u,_xx,_yy,i,j,x1,y1,r_h,g_s,b_v;

		if form_mode == PULSE_FORM.PATH && !path_really_exists(path_a)
		{
			form_mode = PULSE_FORM.ELLIPSE
		}

		if stencil_profile ==undefined
		{
			stencil_mode = PULSE_STENCIL.NONE
		}
		
		var system_array = array_length(part_system_array)
		var type_array = array_length(part_type_array)
		
		div_v	=	1
		div_u	=	1
		i		=	0

		var _check_forces = array_length(local_forces)>0 ? true : false
		
		if _cache != false
		{
			var cache = array_create(_amount,0)
		}
		
		repeat(_amount)
		{
			var particle_struct = { u_coord	: undefined , v_coord	: undefined	, size : undefined	, color_mode : distr_color_mix , orient : undefined, frame : undefined }
			var emitter_struct	= { }
			// ----- Assigns where the particle will spawn in normalized space (u_coord)
			//ASSIGN U COORDINATE
				
				__assign_u_coordinate(div_u,particle_struct)
				
			// ----- Stencil alters the V coordinate space, shaping it according to one or two Animation Curves
			// STENCIL (animation curve shapes the length of the emitter along the form)
				
			//If there is an animation curve channel assigned, evaluate it.
					
				__calculate_stencil(particle_struct,emitter_struct)

			// ----- Assigns how far the particle spawns from the origin point both in pixels (length) and normalized space (v_coord)
			// ASSIGN V COORDINATE  and LENGTH (distance from origin)
				
				__assign_v_coordinate(div_v,particle_struct,emitter_struct)
				
			// ----- Determines the angles for the normal and transversal depending on the form (Path, Radius, Line)
			// ----- and then calculates where will the particle will spawn in room space
			// FORM (origin and normal)
								
				__set_normal_origin(particle_struct,x,y)
				
			// ----- Changes particle direction by adding a random range to the normal, or uses the particle's 'natural' range
			// DIRECTION (angle) 
				
				__assign_direction(particle_struct)
			// ----- Alter a whole set of particle properties based on a pre-processed sprite or surface
			
			// ----- Particle speed and life need to be known before launching the particle, so they can be calculated for form culling
			//SPEED AND LIFE SETTINGS
				
				__assign_properties(particle_struct)
			
			#region DISPLACEMENT MAP
				
			if displacement_map != undefined
			{
				__apply_displacement(particle_struct,emitter_struct)
			}
			if color_map != undefined && distr_color_mix == PULSE_COLOR.COLOR_MAP
			{
				__apply_color_map(particle_struct,emitter_struct)
			}
				
			#endregion	
	
			// ----- Form culling changes the life or speed of the particle so it doesn't travel past a certain point
			// FORM COLLIDE (speed/life change) Depending on direction change speed to conform to form

				__check_form_collide(particle_struct,emitter_struct,x,y)

			//APPLY LOCAL AND GLOBAL FORCES
			if _check_forces
			{
				__check_forces(particle_struct,x,y)
			}
			//CHECK FOR OCCLUDERS/COLLISIONS
			
			if particle_struct.life <=1 continue
				
			var _type	=	0
			var _sys	=	0
						
			for (var _repeat =0; _repeat< max(system_array,type_array,1);_repeat++) 
			{
				var _type	= _type+1	==type_array		? 0 : _type+1
				var _sys	= _sys+1	==system_array		? 0 : _type+1
				particle_struct.part_system	=	part_system_array[_sys]
				particle_struct.particle	=	part_type_array[_type]
				if particle_struct.to_edge && ( particle_struct.particle.subparticle != undefined && particle_struct.particle.on_collision)
				{
					particle_struct.particle	= particle_struct.particle.subparticle
				}
				
				if _cache
				{
					cache[i]=particle_struct
					i++
				}
				else
				{
					__launch(particle_struct)
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
		if _cache
		{ 
			if is_instanceof(_cache,__pulse_cache) 
			{
				_cache.add_particles(cache)
			}
			else
			{
				return new __pulse_cache(cache,self)
			}
		}
	}
}

function __pulse_cache(_cache,_emitter) : __pulse_launcher()  constructor
{
	emitter = _emitter
	index	= 0
	shuffle = true
	cache	= _cache
	length	= array_length(_cache)
	flag_stencil = false
	
	static	add_particles = function(array)
	{
		cache = array_concat(cache,array)
		length	= array_length(cache)
	}
	
	static	regen_stencil = function()
	{
		flag_stencil = true
		index = 0
	}
	
	static	__update_stencil	=	function(_index,_amount)
	{
		for(var _i =_index; _i < _amount ; _i++)
		{
			var _p	= cache[_i]
			var _e	= emitter.__calculate_stencil(_p)
				_p	= emitter.__assign_properties(_p)
				_p	= emitter.__check_form_collide(_p,_e)
		}
	}
	
	static	pulse = function(_amount,x,y)
	{
		do{
			if (index + _amount) >length
			{

				if flag_stencil {__update_stencil(index,length-index)}
				
				for(var _i = index ; _i < length-index ; _i++)
				{
					__launch(cache[_i],x,y)
				}
			
				_amount -=  (length - index)
				index = 0
			}
			else
			{
				if flag_stencil {__update_stencil(index,index+_amount)}
				
				for(var _i = index ; _i < index+_amount ; _i++)
				{
					__launch(cache[_i],x,y)
				}
				
				index = (index + _amount) % length
				_amount = 0
			}
			
			if  index == 0
			{
				flag_stencil = false
			
			if shuffle array_shuffle(cache,irandom_range(0,floor(length/2)),length/2)
			}
		} until(_amount = 0)
	
		
	}
}

function __pulse_launcher() constructor
{
	static	__launch		=	function(_struct,x=0,y=0)
	{
		with(_struct)
		{
			part_type_life(particle.index,life,life);
			part_type_speed(particle.index,speed,speed,particle.speed[2],particle.speed[3])
			part_type_direction(particle.index,dir,dir,particle.direction[2],particle.direction[3])
		
			if size !=undefined
			{
				part_type_size_x(particle.index,size[0],size[2],particle.size[4],particle.size[6])	
				part_type_size_y(particle.index,size[1],size[3],particle.size[4],particle.size[6])	
			}
			if orient !=undefined
			{
				part_type_orientation(particle.index,orient,orient,particle.orient[2],particle.orient[3],particle.orient[4])	
			}
			
			if frame != undefined
			{
				part_type_subimage(particle.index,frame)
			}
			
			if color_mode  !=undefined
			{
				if color_mode == PULSE_COLOR.A_TO_B_RGB or color_mode == PULSE_COLOR.COLOR_MAP
				{
					part_type_color_rgb(particle.index,r_h,r_h,g_s,g_s,b_v,b_v)
				} 
				else if color_mode == PULSE_COLOR.A_TO_B_HSV
				{
					part_type_color_hsv(particle.index,r_h,r_h,g_s,g_s,b_v,b_v)
				}
			}
			particle.prelaunch(_struct)
			
			part_particles_create(part_system.index, x_origin+x,y_origin+y,particle.index, 1);
		}		
	}
}