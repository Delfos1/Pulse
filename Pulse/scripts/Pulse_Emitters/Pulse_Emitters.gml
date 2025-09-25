//⁂
	/// @description	Creates a Pulse emitter, which is stored in a variable.
	/// @param {String , Struct.pulse_system}			__part_system : A pulse System, or the name as a string if the system has been stored. By default it creates a new system with the default name.
	/// @param {String , Struct.__pulse_particle_class}	__part_type : A pulse Particle, or the name as a string if the particle has been stored. By default it creates a new particle with the default name.
	/// @param {Asset.GMAniCurve}						anim_curve : An animation curve that contains one of the following channels: "v_coord" , "u_coord" , "speed", "life" , "orient", "size_x", "size_y" and "frame" . Setting this will make the property's distribution set to the animation curve.
function	pulse_emitter(__part_system=__PULSE_DEFAULT_SYS_NAME,__part_type=__PULSE_DEFAULT_PART_NAME,anim_curve = undefined)  constructor
{
	
	name = undefined
	part_system = 	 __pulse_lookup_system(__part_system)
	part_type =  __pulse_lookup_particle(__part_type)
	imported = false

	#region Emitter Form
	stencil_mode		=	__PULSE_DEFAULT_EMITTER_STENCIL_MODE
	form_mode			=	__PULSE_DEFAULT_EMITTER_FORM_MODE
	path				=	undefined
	path_res			=	-1
	path_local			=	false
	stencil_profile		= animcurve_really_create({curve_name: "stencil_profile",channels:[
							{name:"a",type: animcurvetype_catmullrom , iterations : 8}, 
							{name:"b",type: animcurvetype_catmullrom , iterations : 8} , 
							{name:"c",type: animcurvetype_catmullrom , iterations : 8}]})
	_channel_01			=	animcurve_get_channel(stencil_profile,0)
	_channel_02			=	animcurve_get_channel(stencil_profile,1)
	_channel_03			=	animcurve_get_channel(stencil_profile,2)
	stencil_tween		=	0
	radius_external		=	__PULSE_DEFAULT_EMITTER_RADIUS
	radius_internal		=	0
	edge_external		=	radius_external
	edge_internal		=	0
	mask_start			=	0
	mask_end			=	1
	mask_v_start		=	0
	mask_v_end			=	1
	line				=	[0,0]
	boundary		=	__PULSE_DEFAULT_EMITTER_BOUNDARY
	alter_direction		=	__PULSE_DEFAULT_EMITTER_ALTER_DIRECTION
	
	#endregion
	
	#region Emitter properties
	x_focal_point		=	0
	y_focal_point		=	0
	x_scale				=	1
	y_scale				=	1
	stencil_offset		=	0
	direction_range		=	[0,0]
	#endregion
	
	#region Distributions
	distr_along_v_coord	=	__PULSE_DEFAULT_EMITTER_DISTR_ALONG_V_COORD
	distr_along_u_coord	=	__PULSE_DEFAULT_EMITTER_DISTR_ALONG_U_COORD
	distr_speed			=	__PULSE_DEFAULT_DISTR_PROPERTY
	distr_life			=	__PULSE_DEFAULT_DISTR_PROPERTY
	distr_orient		=	PULSE_DISTRIBUTION.NONE
	distr_size			=	PULSE_DISTRIBUTION.NONE
	distr_color_mix		=	PULSE_DISTRIBUTION.NONE
	distr_color_mix_type=	PULSE_COLOR.NONE
	distr_frame			=	PULSE_DISTRIBUTION.NONE
	divisions_v			=	1
	divisions_u			=	1
	divisions_v_offset	=	0
	divisions_u_offset	=	0
	#endregion
	
	#region Channels
	__v_coord_channel		=	undefined
	__u_coord_channel		=	undefined
	__speed_channel			=	undefined
	__life_channel			=	undefined
	__orient_channel		=	undefined
	__size_x_channel		=	undefined
	__size_y_channel		=	undefined
	__color_mix_channel		=	undefined
	__frame_channel			=	undefined
	
	__speed_link			=	undefined
	__life_link				=	undefined
	__orient_link			=	undefined
	__size_link				=	undefined
	__color_mix_link		=	undefined
	__frame_link			=	undefined
	
	__speed_weight			=	undefined
	__life_weight			=	undefined
	__orient_weight			=	undefined
	__size_weight			=	undefined
	__color_mix_weight		=	undefined
	__frame_weight			=	undefined
	
	__color_mix_A			=	[0,0,0]
	__color_mix_B			=	[0,0,0]
	
	if animcurve_really_exists(anim_curve)
	{

		distributions = anim_curve
		
		if animcurve_channel_exists(distributions,"v_coord")
		{
			distr_along_v_coord	= PULSE_DISTRIBUTION.ANIM_CURVE
			__v_coord_channel = animcurve_get_channel(distributions,"v_coord")
		}
		if animcurve_channel_exists(distributions,"u_coord")
		{
			distr_along_u_coord	= PULSE_DISTRIBUTION.ANIM_CURVE
			__u_coord_channel = animcurve_get_channel(distributions,"u_coord")
		}
		if animcurve_channel_exists(distributions,"speed")
		{
			distr_speed	= PULSE_DISTRIBUTION.ANIM_CURVE
			__speed_channel = animcurve_get_channel(distributions,"speed")
		}
		if animcurve_channel_exists(distributions,"life")
		{
			distr_life	= PULSE_DISTRIBUTION.ANIM_CURVE
			__life_channel = animcurve_get_channel(distributions,"life")
		}
		if animcurve_channel_exists(distributions,"orient")
		{
			distr_orient	= PULSE_DISTRIBUTION.ANIM_CURVE
			__orient_channel = animcurve_get_channel(distributions,"orient")
		}
		if animcurve_channel_exists(distributions,"size_x")
		{
			distr_size	= PULSE_DISTRIBUTION.ANIM_CURVE
			__size_x_channel = animcurve_get_channel(distributions,"size_x")
		}
		if animcurve_channel_exists(distributions,"size_y")
		{
			distr_size	= PULSE_DISTRIBUTION.ANIM_CURVE
			__size_y_channel = animcurve_get_channel(distributions,"size_y")
		}
		if animcurve_channel_exists(distributions,"frame")
		{
			distr_color_mix	= PULSE_DISTRIBUTION.ANIM_CURVE
			__frame_channel = animcurve_get_channel(distributions,"frame")
		}
	}

	#endregion
	
	//Image maps
	displacement_map	=	undefined
	color_map			=	undefined					

	//Forces, Groups, Colliders
	forces		=	[]
		// collisions
	collisions			=	[]
	is_colliding		=	false
	colliding_entities	=	[]
	

	#region COMPONENTS
	
	static set_particle_type		=	function(_particle)
	{
		part_type =  __pulse_lookup_particle(_particle)
		return		
	}
	
	static set_system				=	function(_system)
	{
		system =  __pulse_lookup_particle(_system)
		return		
	}
	
	#endregion

	#region EMITTER SETTINGS
	
	/// @description	Sets an animation curves as a stencil
	/// @param {Asset.GMAnimCurve}	__ac_curve : Animation curve
	/// @param {Real, String}		_ac_channel : Channel's string name or number
	/// @param {Real.Enum_PULSE_STENCIL}	[_mode] : The mode in which the curves will tween. It must be an enum of PULSE_STENCIL:
	/// 	INTERNAL, EXTERNAL, A_TO_B	, or NONE	. DEFAULT : A_TO_B
	/// @param {Bool}			_to_channel : There are two channels, A (false) or B (true). A is the default
	static	set_stencil			=	function(__ac_curve,__ac_channel,_mode=PULSE_STENCIL.EXTERNAL,_to_channel=false)
	{
		_to_channel = _to_channel== true ? 1 : 0 ;
		animcurve_channel_copy(__ac_curve,__ac_channel,stencil_profile,_to_channel,false)

		stencil_mode= _mode
			
		return self

	}
	/// @description	Sets the tween to be applied between Stencils A and B
	/// @param {Real}	_tween : A value between 0 and 1. Any lower or higher values will be automatically wrapped around
	static	set_stencil_tween	=	function(_tween)
	{
		stencil_tween =	clamp(_tween,0,1);	

		return self
	}
	
	/// @description	Sets the offset of the stencil.
	/// @param {Real}	__offset : A value from 0 to 1.
	static	set_stencil_offset	=	function(_offset)
	{
		if _offset < 0
		{
			_offset = 1- (abs(_offset)%1 )
		}
		
		stencil_offset		=	abs(_offset)%1
		return self
	}
	
	/// @description	Sets the mask on the U axis. A mask defines a range in which particles can spawn
	/// @param {Real}	_mask_start : A value from 0 to 1
	/// @param {Real}	_mask_end : A value from 0 to 1
	static	set_u_mask			=	function(_mask_start,_mask_end)
	{
		mask_start			=	clamp(_mask_start,0,1);
		mask_end			=	clamp(_mask_end,0,1);
		
		return self
	}
	
	/// @description	Sets the mask on the V axis. A mask defines a range in which particles can spawn
	/// @param {Real}	_mask_start : Closer to the internal radius. A value from 0 to 1
	/// @param {Real}	_mask_end : Closer to the external radius. A value from 0 to 1
	/// @context pulse_emitter
	static	set_v_mask			=	function(_mask_start,_mask_end)
	{
		mask_v_start			=	clamp(_mask_start,0,1);
		mask_v_end				=	clamp(_mask_end,0,1);
		
		return self
	}
	
		/// @description	Sets the mask on the U axis as an even spread from a central axis in an elliptic emitter. 
	/// @param {Real.Degree}	_direction : Central axis from which to measure the spread. In degrees.
	/// @param {Real.Degree}	_spread_angle : Spread from the central direction, to either sides of it. In degrees.
	static	set_mask_spread			=	function(_direction, _spread_angle)
	{
		_direction			= (_direction%360)/360
		_spread_angle		= ((_spread_angle%360)/360)/2
		mask_end			= _direction - _spread_angle
		mask_start			= _direction + _spread_angle
		return self
	}
	
	/// @description			Sets the radius of the emitter. 0 equals the center of the emitter.
	/// @param {Real}	_radius_internal : The internal radius in absolute terms, in pixels. All particles are created within internal and external radius
	/// @param {Real}	_radius_external : The external radius in absolute terms, in pixels. All particles are created within internal and external radius
	/// @param {Real}	[_edge_internal] : The internal edge of the emitter. Allows to feather particles going towards the center while still limiting them . DEFAULT : Equal to the internal radius (no feathering)
	/// @param {Real}	[_edge_external] : The external edge of the emitter. Allows to feather particles going away of the center while still limiting them . DEFAULT : Equal to the external radius (no feathering)
	static	set_radius			=	function(_radius_internal,_radius_external,_edge_internal = _radius_internal,_edge_external = _radius_external)
	{
		radius_internal	=	_radius_internal ?? radius_internal;
		radius_external	=	_radius_external ?? radius_external;

		edge_internal	=	(_edge_internal >radius_internal ) ? radius_internal : _edge_internal;
		edge_external	=	(_edge_external <radius_external) ? radius_external : _edge_external;
		return self
	}
	
	/// @description			Sets the direction range of the emitter.
	///							The emitter's direction determines whether the particles travel away from the center ( 0 ), transversal to the U axis (90) or towards the center (180)
	/// @param {Real.Degree}	_direction_min : The minimum direction a particle will take. In degrees.
	/// @param {Real.Degree}	[_direction_max] : The maximum direction a particle will take. In degrees. DEFAULT : Equal to the minimum, (no variation between particles)
	static	set_direction_range	=	function(_direction_min,_direction_max=_direction_min)
	{
		direction_range	=	[_direction_min,_direction_max]
		
		return self
	}
	

	
	/// @description	Sets the scale of the emitter. 1 == Normal scale
	/// @param {Real}	[_x_scale] : Scale for the X axis. If left empty, the scale in this axis remains unchanged
	/// @param {Real}	[_y_scale] : Scale for the Y axis. If left empty, the scale in this axis remains unchanged

	static	set_scale			=	function(_x_scale=x_scale,_y_scale=y_scale)
	{
		if is_real(_x_scale) && is_real(_y_scale)
		{
			x_scale			=	_x_scale
			y_scale			=	_y_scale
		}
		else
		{
			__pulse_show_debug_message("Argument must be a Real. Scale was not changed",2)	
		}
		
		return self
	}
	
	/// @description	Sets the Focal point of the emitter. The focal point's position is relative to the emitter's position.
	///					By default the focal point is [0,0] , equivalent to the emitter's position.
	/// @param {Real}	_x : X coordinate relative to the emitter's position
	/// @param {Real}	_y : Y coordinate relative to the emitter's position
	/// @context pulse_emitter
	static	set_focal_point		=	function(_x,_y)
	{
		x_focal_point		=	_x
		y_focal_point		=	_y
		
		return self
	}
	
	static set_boundaries		=	function(_mode = PULSE_BOUNDARY.LIFE )
	{
		boundary = _mode
		
		return self
	}
	
	#endregion
	
	#region FORMS
	
	/// @description	Sets the form of the emitter as a Path. It can be a path asset or a PathPlus.
	/// @param {Asset.GMPath ,  Struct.PathPlus}	_path : Path asset or a PathPlus. 
	/// @context pulse_emitter
	static	form_path			=	function(_path,_local = true)
	{
		if is_instanceof(_path,PathPlus)
		{
			path = _path
			path_res = -100
			form_mode = PULSE_FORM.PATH
			path_local = _local
			__pulse_show_debug_message("PathPlus applied as form",3)
		}
		if path_exists(_path)
		{
			path = _path
			path_res = power(path_get_number(path)-1,path_get_precision(path))
			form_mode = PULSE_FORM.PATH
			path_local =_local
			__pulse_show_debug_message("Path applied as form",3)
		}
		else
		{
			__pulse_show_debug_message("No Path was provided",2)
		}
		
		return self
	}
	/// @description	Sets the form of the emitter as a line. Point A is the emitter's position.
	///					Point B is determined in the arguments, and it is a coordinate RELATIVE to the position of the emitter
	/// @param {Real}	x_point_b : X coordinate of the Point B of the line, RELATIVE to the position of the emitter
	/// @param {Real}	y_point_b : Y coordinate of the Point B of the line, RELATIVE to the position of the emitter
	/// @context pulse_emitter
	static	form_line			=	function(x_point_b,y_point_b)
	{
		line	=	[x_point_b,y_point_b]
		form_mode = PULSE_FORM.LINE
		
		return self
	}
	
	/// @description	Sets the form of the emitter as an ellipse. It is the default shape of an emitter
	/// @context pulse_emitter
	static	form_ellipse			= function()
	{
		form_mode = PULSE_FORM.ELLIPSE
		
		return self
	}
	#endregion

	#region NONLINEAR DISTRIBUTIONS
	
	/// @description	Sets the type of distribution for the orientation of the particles. 
	/// @param {Array}		_curve : Supply an array containing [curve,channel], with the channel as a real or a string, or leave undefined to not assign a curve.
	/// @param {Real.Enum.PULSE_LINK_TO}	_link_to : Requires one of the following: PULSE_LINK_TO.NONE,	PULSE_LINK_TO.DIRECTION ,	PULSE_LINK_TO.PATH_SPEED, 	PULSE_LINK_TO.SPEED,	PULSE_LINK_TO.U_COORD,	PULSE_LINK_TO.V_COORD
	/// @context pulse_emitter
	static set_distribution_orient	=  function (_curve = undefined, _link_to = PULSE_LINK_TO.NONE,_weight = 1 )
	{
		var _mode = PULSE_DISTRIBUTION.RANDOM
		if (_link_to == PULSE_LINK_TO.COLOR_MAP)
		{
			__pulse_show_debug_message("Invalid link property. Color Map is only usable in Color",2)	
			_link_to = PULSE_LINK_TO.NONE
		};
		if _link_to != PULSE_LINK_TO.NONE
		{
			_mode = PULSE_DISTRIBUTION.LINKED
			__orient_link		=	_link_to
				if _link_to == PULSE_LINK_TO.DISPL_MAP 
				{
					if is_array(_weight)
					{
						__orient_weight		=	_weight
						while (array_length(__orient_weight) < 3)
						{
							array_push(__orient_weight,1)
						};
					}
					else
					{
						__orient_weight		= array_create(4,_weight)
					}
				}
				else
				{
					if is_array(_weight)
					{
						_weight = _weight[0]
					}
					__orient_weight		=	_weight
				}
		}
		
		if _curve != undefined
		{
			if is_array(_curve)
			{
				if animcurve_really_exists(_curve[0]) && animcurve_channel_exists(_curve[0],_curve[1])
				{
						distr_orient		=	_mode;
						//animcurve_channel_copy(_curve[0],_curve[1],distributions)
						__orient_channel	=	animcurve_get_channel(_curve[0],_curve[1]);
						_mode = _mode== PULSE_DISTRIBUTION.LINKED ? PULSE_DISTRIBUTION.LINKED_CURVE : PULSE_DISTRIBUTION.ANIM_CURVE
				}
					else{		__pulse_show_debug_message("Distribution Anim Curve or channel not found",2) }
			}else{				__pulse_show_debug_message("Distribution Anim Curve argument must be an array [curve,channel]",2)	}
			
		}
		
		distr_orient = _mode

		return self
	}	
	/// @description	Sets the type of distribution for the life of the particles. 
	/// @param {Array}		_curve : Supply an array containing [curve,channel], with the channel as a real or a string, or leave undefined to not assign a curve.
	/// @param {Real.Enum.PULSE_LINK_TO}	_link_to : If mode is Linked, supply one of the following: 	PULSE_LINK_TO.DIRECTION ,	PULSE_LINK_TO.PATH_SPEED, 	PULSE_LINK_TO.SPEED,	PULSE_LINK_TO.U_COORD,	PULSE_LINK_TO.V_COORD
	/// @context pulse_emitter
	static set_distribution_life	=  function (_curve = undefined,_link_to = PULSE_LINK_TO.NONE,_weight = 1 )
	{
		var _mode = PULSE_DISTRIBUTION.RANDOM
		
		if (_link_to == PULSE_LINK_TO.COLOR_MAP)
		{
			__pulse_show_debug_message("Invalid link property. Color Map is only usable in Color",2)	
			_link_to = PULSE_LINK_TO.NONE
		};
		
		if _link_to != PULSE_LINK_TO.NONE
		{
			_mode = PULSE_DISTRIBUTION.LINKED
			__life_link		=	_link_to
				if _link_to == PULSE_LINK_TO.DISPL_MAP || _link_to == PULSE_LINK_TO.COLOR_MAP
				{
					if is_array(_weight)
					{
						__life_weight		=	_weight
						while (array_length(__life_weight) < 3)
						{
							array_push(__life_weight,1)
						};
					}
					else
					{					
						if is_array(_weight)
					{
						_weight = _weight[0]
					}
						__life_weight		= array_create(4,_weight)
					}
				}
				else
				{
					__life_weight		=_weight
				}
		}
		
		if _curve != undefined
		{
			if is_array(_curve)
			{
					if animcurve_really_exists(_curve[0]) && animcurve_channel_exists(_curve[0],_curve[1])
				{
						distr_life		=	_mode;
						__life_channel	=	animcurve_get_channel(_curve[0],_curve[1]);
						_mode = _mode== PULSE_DISTRIBUTION.LINKED ? PULSE_DISTRIBUTION.LINKED_CURVE : PULSE_DISTRIBUTION.ANIM_CURVE
				}
					else{		__pulse_show_debug_message("Distribution Anim Curve or channel not found",2) }
			}else{				__pulse_show_debug_message("Distribution Anim Curve argument must be an array [curve,channel]",2)	}
			
		}
		
		distr_life = _mode

		return self
	}
	
	/// @description	Sets the type of distribution for the speed of the particles. 
	/// @param {Real.Enum.PULSE_DISTRIBUTION}	_mode : Distribution mode. It can be PULSE_DISTRIBUTION.ANIM_CURVE or PULSE_DISTRIBUTION.LINKED .PULSE_DISTRIBUTION.RANDOM by default
	/// @param {Real.Enum.PULSE_LINK_TO}	_link_to : If mode is Linked, supply one of the following: 	PULSE_LINK_TO.DIRECTION ,	PULSE_LINK_TO.PATH_SPEED, 	PULSE_LINK_TO.U_COORD,	PULSE_LINK_TO.V_COORD
	/// @context pulse_emitter
	static set_distribution_speed	=  function (_curve = undefined,_link_to = PULSE_LINK_TO.NONE,_weight = 1 )
	{
		if (_link_to == PULSE_LINK_TO.SPEED)
		{
			__pulse_show_debug_message("Invalid link property. Speed can't link to Speed",2)	
			_link_to = PULSE_LINK_TO.NONE
		};
		if (_link_to == PULSE_LINK_TO.COLOR_MAP)
		{
			__pulse_show_debug_message("Invalid link property. Color Map is only usable in Color",2)	
			_link_to = PULSE_LINK_TO.NONE
		};

		var _mode = PULSE_DISTRIBUTION.RANDOM
		
		if _link_to != PULSE_LINK_TO.NONE
		{
			_mode = PULSE_DISTRIBUTION.LINKED
			__speed_link		=	_link_to
				if _link_to == PULSE_LINK_TO.DISPL_MAP ||  _link_to == PULSE_LINK_TO.COLOR_MAP
				{
					if is_array(_weight)
					{
						__speed_weight		=	_weight
						while (array_length(__speed_weight) < 3)
						{
							array_push(__speed_weight,1)
						};
					}
					else
					{
						__speed_weight		= array_create(4,_weight)
					}
				}
					else
				{
										if is_array(_weight)
					{
						_weight = _weight[0]
					}
					__speed_weight		=_weight
				}
		}
		
		if _curve != undefined
		{
			if is_array(_curve)
			{
					if animcurve_really_exists(_curve[0]) && animcurve_channel_exists(_curve[0],_curve[1])
				{
						distr_speed		=	_mode;
						__speed_channel	=	animcurve_get_channel(_curve[0],_curve[1]);
						_mode = _mode== PULSE_DISTRIBUTION.LINKED ? PULSE_DISTRIBUTION.LINKED_CURVE : PULSE_DISTRIBUTION.ANIM_CURVE
				}
					else{		__pulse_show_debug_message("Distribution Anim Curve or channel not found",2) }
			}else{				__pulse_show_debug_message("Distribution Anim Curve argument must be an array [curve,channel]",2)	}
		}
	
		
		distr_speed = _mode
		return self
	}
	
	/// @description	Sets the type of distribution for the size of the particles. 
	/// @param {Array}		_curve : Supply an array containing [curve,channel], with the channel as a real or a string, or leave undefined to not assign a curve.
	/// @param {Real.Enum.PULSE_LINK_TO}	_link_to : If mode is Linked, supply one of the following: 	PULSE_LINK_TO.DIRECTION ,	PULSE_LINK_TO.PATH_SPEED, 	PULSE_LINK_TO.SPEED,	PULSE_LINK_TO.U_COORD,	PULSE_LINK_TO.V_COORD
	/// @context pulse_emitter
	static set_distribution_size	=  function (_curve = undefined,_link_to = PULSE_LINK_TO.NONE,_weight = 1 )
	{
		var _mode = PULSE_DISTRIBUTION.RANDOM
		if (_link_to == PULSE_LINK_TO.COLOR_MAP)
		{
			__pulse_show_debug_message("Invalid link property. Color Map is only usable in Color",2)	
			_link_to = PULSE_LINK_TO.NONE
		};
		
		if _link_to != PULSE_LINK_TO.NONE
		{
			_mode = PULSE_DISTRIBUTION.LINKED
			__size_link		=	_link_to
				if _link_to == PULSE_LINK_TO.DISPL_MAP || _link_to == PULSE_LINK_TO.COLOR_MAP
				{
					if is_array(_weight)
					{
						__size_weight		=	_weight
						while (array_length(__size_weight) < 4)
						{
							array_push(__size_weight,1)
						};
					}
					else
					{
						__size_weight		= array_create(4,_weight)
					}
				}
					else
				{
					if is_array(_weight)
					{
						_weight = _weight[0]
					}
					__size_weight		=_weight
				}
		}
		
		if _curve != undefined
		{
			if is_array(_curve)
			{
					if animcurve_really_exists(_curve[0]) && animcurve_channel_exists(_curve[0],_curve[1])
				{
						__size_x_channel	=	animcurve_get_channel(_curve[0],_curve[1])
						if array_length(_curve)>3
						{
							if animcurve_really_exists(_curve[2]) && animcurve_channel_exists(_curve[2],_curve[3])
							{
								__size_y_channel	=	animcurve_get_channel(_curve[2],_curve[3])
							}
							else
							{
								__size_y_channel	=	__size_x_channel
							}
						}
						else
						{
							__size_y_channel	=	__size_x_channel
						}
						_mode = _mode== PULSE_DISTRIBUTION.LINKED ? PULSE_DISTRIBUTION.LINKED_CURVE : PULSE_DISTRIBUTION.ANIM_CURVE
				}
					else{		__pulse_show_debug_message("Distribution Anim Curve or channel not found",2) }
			}else{				__pulse_show_debug_message("Distribution Anim Curve argument must be an array [curve,channel]",2)	}
		}
	
		
		distr_size = _mode

		return self
	}
	
	/// @description	Sets the type of distribution for the color of the particles. Uses the mode Color Mix, in which the particles can have a color interpolated between A and B. This overrides the color mode of the particle itself.
	/// @param {Constant.Colour, Real}	_color_A : Color A
	/// @param {Constant.Colour, Real}	_color_B : Color B
	/// @param {Array}		_curve : Supply an array containing [curve,channel], with the channel as a real or a string, or leave undefined to not assign a curve.
	/// @param {Real.Enum.PULSE_LINK_TO}	_link_to : If mode is Linked, supply one of the following: 	PULSE_LINK_TO.DIRECTION ,	PULSE_LINK_TO.PATH_SPEED, 	PULSE_LINK_TO.SPEED,	PULSE_LINK_TO.U_COORD,	PULSE_LINK_TO.V_COORD
	/// @param {Real.Enum.PULSE_COLOR}	_color_mode : Color mode. It can be PULSE_COLOR.A_TO_B_HSV , PULSE_COLOR.A_TO_B_RGB or PULSE_COLOR.COLOR_MAP. PULSE_COLOR.NONE by default
	/// @context pulse_emitter
	static set_distribution_color_mix=  function ( _color_A, _color_B,_curve,_link_to = PULSE_LINK_TO.NONE,_weight = 1,_color_mode = PULSE_COLOR.NONE )
	{
		if _color_mode ==  PULSE_COLOR.A_TO_B_RGB
		{
			__color_mix_A[0] = color_get_blue(_color_A)
			__color_mix_A[1] = color_get_green(_color_A)
			__color_mix_A[2] = color_get_red(_color_A)
		
			__color_mix_B[0] = color_get_blue(_color_B)
			__color_mix_B[1] = color_get_green(_color_B)
			__color_mix_B[2] = color_get_red(_color_B)
		}
		else if  _color_mode ==  PULSE_COLOR.A_TO_B_HSV
		{
			__color_mix_A[2] = color_get_hue(_color_A)
			__color_mix_A[1] = color_get_saturation(_color_A)
			__color_mix_A[0] = color_get_value(_color_A)
		
			__color_mix_B[2] = color_get_hue(_color_B)
			__color_mix_B[1] = color_get_saturation(_color_B)
			__color_mix_B[0] = color_get_value(_color_B)
		}
		distr_color_mix_type = _color_mode
		var _mode = PULSE_DISTRIBUTION.RANDOM
		_weight = clamp(_weight,0,1)
		
		if _link_to != PULSE_LINK_TO.NONE
		{
			_mode = PULSE_DISTRIBUTION.LINKED
			__color_mix_link		=	_link_to
				if _link_to == PULSE_LINK_TO.DISPL_MAP || PULSE_LINK_TO.COLOR_MAP 
				{
					if is_array(_weight)
					{
						__color_mix_weight		=	_weight
						while (array_length(__color_mix_weight) < 3)
						{
							array_push(__color_mix_weight,1)
						};
					}
					else
					{
						__color_mix_weight		= array_create(4,_weight)
					}
				}
		}

		if _curve != undefined
		{
			if is_array(_curve)
			{
					if animcurve_really_exists(_curve[0]) && animcurve_channel_exists(_curve[0],_curve[1])
				{
						distr_color_mix		=	_mode;
						__color_mix_channel	=	animcurve_get_channel(_curve[0],_curve[1]);
						_mode = _mode== PULSE_DISTRIBUTION.LINKED ? PULSE_DISTRIBUTION.LINKED_CURVE : PULSE_DISTRIBUTION.ANIM_CURVE
				}
					else{		__pulse_show_debug_message("Distribution Anim Curve or channel not found",2) }
			}else{				__pulse_show_debug_message("Distribution Anim Curve argument must be an array [curve,channel]",2)	}
		}
	
		distr_color_mix = _mode

		return self
	}
	
	/// @description	Sets the type of distribution for the frames of the particle's sprite.
	/// @param {Array}		_curve : Supply an array containing [curve,channel], with the channel as a real or a string, or leave undefined to not assign a curve.
	/// @param {Real.Enum.PULSE_LINK_TO}	_link_to : If mode is Linked, supply one of the following: 	PULSE_LINK_TO.DIRECTION ,	PULSE_LINK_TO.PATH_SPEED, 	PULSE_LINK_TO.SPEED,	PULSE_LINK_TO.U_COORD,	PULSE_LINK_TO.V_COORD
	/// @context pulse_emitter
	static set_distribution_frame	=  function (_curve = undefined,_link_to = PULSE_LINK_TO.NONE,_weight = 1 )
	{
		
		if !part_type.set_to_sprite
		{
			__pulse_show_debug_message($"Particle {part_type.name} not set to sprite" ,2)	
			return self	
		}
		
		if (_link_to == PULSE_LINK_TO.COLOR_MAP)
		{
			__pulse_show_debug_message("Invalid link property. Color Map is only usable in Color",2)	
			_link_to = PULSE_LINK_TO.NONE
		};
		var _mode = PULSE_DISTRIBUTION.RANDOM
		
		if _link_to != PULSE_LINK_TO.NONE
		{
			_mode = PULSE_DISTRIBUTION.LINKED
			__frame_link		=	_link_to
				if _link_to == PULSE_LINK_TO.DISPL_MAP || _link_to == PULSE_LINK_TO.COLOR_MAP
				{
					if is_array(_weight)
					{
						__frame_weight		=	_weight
						while (array_length(__frame_weight) < 3)
						{
							array_push(__frame_weight,1)
						};
					}
					else
					{
						if is_array(_weight)
						{
						_weight = _weight[0]
						}
						__frame_weight		= array_create(4,_weight)
					}
				}
				else
				{
					__frame_weight		=_weight
				}
		}
		
		if _curve != undefined
		{
			if is_array(_curve)
			{
				if animcurve_really_exists(_curve[0]) && animcurve_channel_exists(_curve[0],_curve[1])
				{
						distr_frame		=	_mode;
						__frame_channel	=	animcurve_get_channel(_curve[0],_curve[1]);
						_mode = _mode== PULSE_DISTRIBUTION.LINKED ? PULSE_DISTRIBUTION.LINKED_CURVE : PULSE_DISTRIBUTION.ANIM_CURVE
						
				}
					else{		__pulse_show_debug_message("Distribution Anim Curve or channel not found",2) }
			}else{				__pulse_show_debug_message("Distribution Anim Curve argument must be an array [curve,channel]",2)	}
			
		}

	
			part_type.set_sprite(part_type.sprite[0],part_type.sprite[1],part_type.sprite[2],false,0)
			__pulse_show_debug_message($"Sprite of particle {part_type.name} : Random set to False",1)	

		distr_frame = _mode

		return self
	}
	
	/// @description	Sets the type of distribution for the spawn point of the particle in the U axis in the emitter.
	/// @param {Real.Enum.PULSE_DISTRIBUTION}	_mode : Distribution mode. It can be PULSE_DISTRIBUTION.ANIM_CURVE or PULSE_DISTRIBUTION.EVEN .PULSE_DISTRIBUTION.RANDOM by default
	/// @param {Real, Array}					_input : If mode is Anim_curve, supply an array containing [curve,channel], with the channel as a real or a string. If mode is Even, supply an integer.
	/// @context pulse_emitter
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
					__pulse_show_debug_message("Distribution Even argument must be an real, Defaulted to 1" ,1)
				}
			break
			}
			case 	PULSE_DISTRIBUTION.ANIM_CURVE:
			{
				if !is_array(_input)
				{
					__pulse_show_debug_message("Distribution Anim Curve argument must be an array [curve,channel]",2)	
					break;
				}
				if animcurve_really_exists(_input[0])
				{
					if animcurve_channel_exists(_input[0],_input[1])
					{
						distr_along_u_coord	= PULSE_DISTRIBUTION.ANIM_CURVE
						__u_coord_channel = animcurve_get_channel(_input[0],_input[1])
						break
					}
				}
				__pulse_show_debug_message("Distribution Anim Curve or channel not found",2)	
			break
			}
			default:
			{
				__pulse_show_debug_message("Mode is not allowed in U Coordinate",2)
			}
		}
		
		return self
	}
	
	/// @description	Sets the type of distribution for the spawn point of the particle in the V axis in the emitter.
	/// @param {Real.Enum.PULSE_DISTRIBUTION}	_mode : Distribution mode. It can be PULSE_DISTRIBUTION.ANIM_CURVE or PULSE_DISTRIBUTION.EVEN .PULSE_DISTRIBUTION.RANDOM by default
	/// @param {Real, Array}					_input : If mode is Anim_curve, supply an array containing [curve,channel], with the channel as a real or a string. If mode is Even, supply an integer.
	/// @context pulse_emitter
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
					__pulse_show_debug_message("Distribution Even argument must be an real, Defaulted to 1",1)
				}
			break
			}
			case 	PULSE_DISTRIBUTION.ANIM_CURVE:
			{
				if !is_array(_input)
				{
					__pulse_show_debug_message("Distribution Anim Curve argument must be an array [curve,channel]",2)	
					break;
				}
				if animcurve_really_exists(_input[0])
				{
					if animcurve_channel_exists(_input[0],_input[1])
					{
						distr_along_v_coord	= PULSE_DISTRIBUTION.ANIM_CURVE
						__v_coord_channel = animcurve_get_channel(_input[0],_input[1])
						break
					}
				}
				__pulse_show_debug_message("Distribution Anim Curve or channel not found",2)	
			break
			}
			case 	PULSE_DISTRIBUTION.LINKED:
			{
				__pulse_show_debug_message("Distribution Linked not allowed in V Coordinate",2)
				break
			}
		}
		return self
	}
	
	/// @description	Sets the offset for the U axis
	/// @param {Real}	_offset :  Amount of offset
	static set_distribution_u_offset=  function (_offset)
	{
		divisions_u_offset = _offset
	}
	/// @description	Sets the offset for the V axis
	/// @param {Real}	_offset :  Amount of offset
	static set_distribution_v_offset=  function (_offset)
	{
		divisions_v_offset = _offset
	}
	
	#endregion
	
	#region DISPLACEMENT MAP SETTERS
	
	/// @description	Sets a sprite to be used as a displacement map.
	/// @param {Struct.__buffered_sprite}	_map : Buffered sprite created using buffer_from_sprite() or buffer_from_surface() or Dragonite's Macaw
	/// @context pulse_emitter
	static	set_displacement_map	=	function(_map)
	{
		if buffer_exists(_map.noise)
		{
			displacement_map	=	new __pulse_map(_map,self) 
		}
		else
		{		
		__pulse_show_debug_message("Displacement Map is of the wrong format",2)
		}
		return self
	}
	
	/// @description	Sets a sprite to be used as a displacement map.
	/// @param {Struct.__buffered_sprite}	_map : Buffered sprite created using buffer_from_sprite() or buffer_from_surface()
	/// @context pulse_emitter
	static	set_color_map			=	function(_map)
	{
		if  is_instanceof(_map, __buffered_sprite) 
		{
			color_map			=	new __pulse_map(_map, self) 
		}
		else
		{
		__pulse_show_debug_message("Color Map is a wrong format",2)
		}
		return self
	}
	
	#endregion
	
	#region FORCES
	
	/// @description	Adds a force to the current emitter. Force must be a Pulse Force
	/// @param {Struct.pulse_force}	_force : Pulse force to be added to the emitter
	/// @context pulse_emitter
	static	add_force			=	function(_force)
	{
		if is_instanceof(_force,pulse_force)
		{
			array_push(forces,_force)
		}
		return self
	}
	/// @description	Removes a force already applied to the current emitter. Force must be a Pulse Force
	/// @param {Struct.pulse_force}	_force : Pulse force to be removed from the emitter
	/// @context pulse_emitter
	static	remove_force		=	function(_force)
	{
		if is_instanceof(_force,pulse_force)
		{
			var _i = array_get_index(forces,_force)
			if _i != -1
			{
				array_delete(forces,_i,1)
			}
		}
		return self
	}
	#endregion
	
	static	draw_debug				=	function(x,y)
	{
		// draw radiuses
		var ext_x =  radius_external*x_scale ,
			int_x =  radius_internal*x_scale ,
			ext_y =  radius_external*y_scale ,
			int_y =  radius_internal*y_scale ,
			ed_x = edge_external*x_scale ,
			ed_y = edge_external*y_scale ,
			edint_x = edge_internal*x_scale ,
			edint_y = edge_internal*y_scale 
		
		if is_colliding
			{
				draw_set_color(c_fuchsia)
			}else
			{
				draw_set_color(c_yellow)
			}
		if form_mode == PULSE_FORM.ELLIPSE
		{
			draw_ellipse(x-ext_x,y-ext_y,x+ext_x,y+ext_y,true)
			draw_ellipse(x-int_x,y-int_y,x+int_x,y+int_y,true)
			
			if edge_external > radius_external
			{
				draw_set_color(c_red)
				draw_ellipse(x-ed_x,y -ed_y,x+ed_x,y+ed_y,true)
			}
			if edge_internal < radius_internal
			{
				draw_set_color(c_red)
				draw_ellipse(x-edint_x,y-edint_y,x+edint_x,y+edint_y,true)
			}
		}
		else if form_mode == PULSE_FORM.PATH
		{
			if path_res	== -100
			{
				path.DebugDraw(x,y,!path_local)
			}
			else
			{
				draw_path(path,x,y,!path_local)
			}
		}
		draw_set_color(c_white)
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

		var _anstart_x = x+lengthdir_x(ext_x,(mask_start*360)%360)
		var _anstart_y = y+lengthdir_y(ext_y,(mask_start*360)%360)
		var _anend_x = x+lengthdir_x(ext_x,(mask_end*360)%360)
		var _anend_y = y+lengthdir_y(ext_y,(mask_end*360)%360)
		draw_line_width_color(x,y,_anstart_x,_anstart_y,1,c_green,c_green)
		draw_text(_anstart_x,_anstart_y,$"{mask_start}")
		draw_text(_anend_x,_anend_y,$"{mask_end}")
		draw_line_width_color(x,y,_anend_x,_anend_y,1,c_green,c_green)
		
		// draw direction
		var angle = (direction_range[0]+direction_range[1])/2
		var _directionrange_x = x+ (ext_x + int_x )/2 + lengthdir_x(20,angle)
		var _directionrange_y = y +lengthdir_y(20,angle)
		
		draw_set_color(c_red)
		draw_arrow(x+((ext_x + int_x )/2),y,_directionrange_x,_directionrange_y,10)
		draw_set_color(c_white)
	}
	
	/// @description	Adds a collision element to be checked by the collision function.
	/// @param {Any}	_object : Can be an object, instance, tile or anything admitable 
	/// @context pulse_emitter
	static	add_collisions			=	function(_object)
	{
		array_push(collisions,_object)
		
		return self
	}
	
	static remove_collisions =	function(_object)
	{
		var ind = array_find_index(collisions,function(_element, _index){return _element == _object})
		if ind > -1
		{
			array_delete(collisions,ind,1)
		}
		
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
					
			_p.u_coord			??=	lerp(mask_start,mask_end,animcurve_channel_evaluate(__u_coord_channel,random(1)))
		}
		else if distr_along_u_coord	== PULSE_DISTRIBUTION.EVEN
		{
			//Distribute the u_coord evenly by particle amount and number of divisions_u
			
			_p.u_coord ??= lerp(mask_start, mask_end,div_u/divisions_u)
		}
		return _p
	}
						
	static __calculate_stencil		=	function(_p, _e={})
	{
		var eval, eval_a, eval_b, eval_c;
		
		_p.to_edge	=	0
		
		var dir_stencil = (stencil_offset+_p.u_coord)%1;
		// early exit if there are no stencils
		if stencil_mode == PULSE_STENCIL.NONE 
		{			
			_e.ext		= 1
			_e.int		= 1
			if is_colliding
			{
				var eval_c	=	clamp(animcurve_channel_evaluate(_channel_03,dir_stencil),0,1);
				_e.edge		= eval_c
				if eval_c < 1
				{
					_p.to_edge	=	1
				}
			}
			else
			{
				_e.edge		= 1
			}

			return _e
		}
		
		switch (stencil_mode)
		{
			case PULSE_STENCIL.A_TO_B: //SHAPE A IS EXTERNAL, B IS INTERNAL
			{
				eval_a	=	clamp(animcurve_channel_evaluate(_channel_01,dir_stencil),0,1);
				eval_b	=	clamp(animcurve_channel_evaluate(_channel_02,dir_stencil),0,1);
				eval_c	=	clamp(animcurve_channel_evaluate(_channel_03,dir_stencil),0,1);
				eval	=	lerp(eval_a,eval_b,stencil_tween)
				
				_e.ext		= min(eval_a,(eval_c*(edge_external/radius_external)))
				_e.int		= eval_b
				_e.total	= eval
				_e.edge		= min(eval_a,eval_c)
				
				var _dif = (_e.ext - eval_a) + (_e.edge - eval_a )
				if _dif < -.1
				{
					_p.to_edge	=	1
				}

				break;
			}
			case PULSE_STENCIL.EXTERNAL: //BOTH SHAPES ARE EXTERNAL, MODULATED BY TWEEN
			{
				eval_a	=	stencil_tween== 1 ? 0 : clamp(animcurve_channel_evaluate(_channel_01,dir_stencil),0,1);
				eval_b	=	stencil_tween== 0 ? 0 : clamp(animcurve_channel_evaluate(_channel_02,dir_stencil),0,1);
				eval_c	=	clamp(animcurve_channel_evaluate(_channel_03,_p.u_coord),0,1);
				eval	=	lerp(eval_a,eval_b,stencil_tween)
				
				_e.ext		= eval
				_e.int		= 1
				_e.edge		= min(eval,eval_c)
				
				var _dif = (_e.ext - eval) + (_e.edge - eval )
				if _dif < -.1
				{
					_p.to_edge	=	1
				}
				break;
			}
			case PULSE_STENCIL.INTERNAL: //BOTH SHAPES ARE INTERNAL, MODULATED BY TWEEN
			{
				eval_a	=	stencil_tween== 1 ? 0 : clamp(animcurve_channel_evaluate(_channel_01,dir_stencil),0,1);
				eval_b	=	stencil_tween== 0 ? 0 : clamp(animcurve_channel_evaluate(_channel_02,dir_stencil),0,1);
				eval_c	=	clamp(animcurve_channel_evaluate(_channel_03,dir_stencil),0,1);
				eval	=	lerp(eval_a,eval_b,stencil_tween)
				
				_e.ext		= 1
				_e.int		= eval
				_e.edge		= min(1,eval_c)
				
				if _e.edge != 1
				{
					_p.to_edge	=	1
				}
				
				break;
			}
		}
					
		return _e
	}
	
	static __assign_v_coordinate	=	function(div_v,_p,_e={})
	{
		if radius_internal==radius_external
		{
			// If the 2 radius are equal, then there is no need to randomize
			_p.v_coord		??=	_e.ext			
			_p.length		=	_e.ext*radius_external;
		}
		else if distr_along_v_coord == PULSE_DISTRIBUTION.RANDOM
		{
			//Distribute along the v coordinate (across the radius in a circle) by randomizing, then adjusting by shape evaluation
			_p.v_coord		??= random_range(mask_v_start,mask_v_end)
			_p.length = lerp(_e.int*radius_internal,_e.ext*radius_external,_p.v_coord)
			
		}
		else if distr_along_v_coord == PULSE_DISTRIBUTION.ANIM_CURVE
		{
			//Distribute along the radius by animation curve distribution, then adjusting by shape evaluation
			_p.v_coord		??= random_range(mask_v_start,mask_v_end)
			_p.length		=	lerp(_e.int*radius_internal,_e.ext*radius_external,animcurve_channel_evaluate(__v_coord_channel,_p.v_coord))
		}
		else if distr_along_v_coord == PULSE_DISTRIBUTION.EVEN
		{
			//Distribute evenly
			_p.v_coord		??=	lerp(mask_v_start,mask_v_end,(div_v/divisions_v))//_pulse_clamp_wrap((div_v/divisions_v),mask_v_start,mask_v_end)
			_p.length		=	lerp(_e.int*radius_internal,_e.ext*radius_external,_p.v_coord)
			
		}
					
		return _p
	}
	
	static __assign_properties		=	function(_p)
	{				
		function get_link_value(_link,_p,_weight,_save)
		{
			var _amount
			switch( _link )
			{
				case PULSE_LINK_TO.DIRECTION:
					_amount	=	_p.dir/360
				break
				case PULSE_LINK_TO.PATH_SPEED:
					_amount	=	form_mode == PULSE_FORM.PATH ? path_get_speed(path,_p.u_coord)/100 : random(1)
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
				case PULSE_LINK_TO.DISPL_MAP:
				if _save[$ "displ"] == undefined
				{
					var u = displacement_map.scale_u * (_p.u_coord+displacement_map.offset_u);
					u = u>1||u<0 ?  abs(frac(u)): u ;
					var v = displacement_map.scale_v * (_p.v_coord+displacement_map.offset_v);
					v = v>1||v<0 ?  abs(frac(v)): v ;
					
					_amount = displacement_map.buffer.GetNormalised(u,v)
					
					if is_array(_amount)
					{
						// if the returned value is an array we can use individual channels
						_amount[0] =_amount[0]/255  //RED
						_amount[1] =_amount[1]/255  //GREEN
						_amount[2] =_amount[2]/255  //BLUE
						_amount[3] =_amount[3]/255  //ALPHA
						_amount[4] = mean(_amount[0],_amount[1],_amount[2])
					}
					else
					{
						//else you are probably using Dragonite's noise generator Macaw
						_amount= _amount/255
					}
					_save.displ = _amount
				}
				else
				{
					_amount = _save.displ
				}
				break
				case PULSE_LINK_TO.COLOR_MAP:
				if _save[$ "color"] == undefined
				{
					var u = color_map.scale_u * (_p.u_coord+color_map.offset_u);
					u = u>1||u<0 ?  abs(frac(u)): u ;
					var v = color_map.scale_v * (_p.v_coord+color_map.offset_v);
					v = v>1||v<0 ?  abs(frac(v)): v ;
					
					 _amount = color_map.buffer.GetNormalised(u,v)
					 _save.color = _amount
				}
				else
				{
					_amount = _save.color
				}
				break
			}
			
			if is_array(_amount)
			{
				if is_array(_weight)
				{
					_amount[0]= _weight[0] <0 ?  1+ (_amount[0]*_weight[0]) : _amount[0] *_weight[0]
					_amount[1]= _weight[1] <0 ?  1+ (_amount[1]*_weight[1]) : _amount[1] *_weight[1]
					_amount[2]= _weight[2] <0 ?  1+ (_amount[2]*_weight[2]) : _amount[2] *_weight[2]
					_amount[3]= _weight[3] <0 ?  1+ (_amount[3]*_weight[3]) : _amount[3] *_weight[3]

				}
					else
				{
					_amount[0]= _weight <0 ?  1+ (_amount[0]*_weight) : _amount[0] *_weight
					_amount[1]= _weight <0 ?  1+ (_amount[1]*_weight) : _amount[1] *_weight
					_amount[2]= _weight <0 ?  1+ (_amount[2]*_weight) : _amount[2] *_weight
					_amount[3]= _weight <0 ?  1+ (_amount[3]*_weight) : _amount[3] *_weight
				}
					if _link != PULSE_LINK_TO.COLOR_MAP 
					{
						_amount=  median(_amount[0],_amount[1],_amount[2],_amount[3])
					}

			}
				else
			{
				if is_array(_weight)
				{
					_weight = _weight[0]
				}
						_amount= _weight <0 ?  1+( _amount*_weight) : _amount *_weight
			}
			
			return _amount
		}	
		
		#region SPEED
		
		var _amount = 0,
			_save = {}
		// early exit if there is no range to interpret the property

		if _p.speed == undefined
		{
			if distr_speed == PULSE_DISTRIBUTION.RANDOM
			{
				_p.speed	=	random_range(part_type.speed[0],part_type.speed[1]);
			}
			else
			{
				if distr_speed == PULSE_DISTRIBUTION.LINKED_CURVE || distr_speed == PULSE_DISTRIBUTION.LINKED
				{
					_amount = get_link_value(__speed_link,_p,__speed_weight,_save)
				}
				else
				{
					_amount = random(1)
				}
				
				if distr_speed == PULSE_DISTRIBUTION.ANIM_CURVE  || distr_speed == PULSE_DISTRIBUTION.LINKED_CURVE 
				{
					_amount		=	animcurve_channel_evaluate(__speed_channel,_amount);
				}
				_p.speed		=lerp(part_type.speed[0],part_type.speed[1],_amount);
			}
		}
		#endregion
			
		#region life
		
		if _p.life		== undefined
		{
			if distr_life == PULSE_DISTRIBUTION.RANDOM
			{
				_p.life	=	irandom_range(part_type.life[0],part_type.life[1]);
			}
			else
			{
				if distr_life == PULSE_DISTRIBUTION.LINKED_CURVE || distr_life == PULSE_DISTRIBUTION.LINKED
				{
					_amount = get_link_value(__life_link,_p,__life_weight,_save)
					
				}
				else
				{
					_amount = random(1)
				}
				
				if distr_life == PULSE_DISTRIBUTION.ANIM_CURVE  || distr_life == PULSE_DISTRIBUTION.LINKED_CURVE 
				{
					_amount		=	animcurve_channel_evaluate(__life_channel,_amount);
				}
				_p.life		= round(lerp(part_type.life[0],part_type.life[1],_amount));
			}
		}

		#endregion
		
		#region orient
		
		// early exit if there is no range to interpret the property
		if part_type.orient[0]!=part_type.orient[1] || distr_life != PULSE_DISTRIBUTION.RANDOM
		{
				if distr_orient == PULSE_DISTRIBUTION.LINKED_CURVE || distr_orient == PULSE_DISTRIBUTION.LINKED
				{
					_amount = get_link_value(__orient_link,_p,__orient_weight,_save)
				}
				else
				{
					_amount = random(1)
				}
				
				if distr_orient == PULSE_DISTRIBUTION.ANIM_CURVE  || distr_orient == PULSE_DISTRIBUTION.LINKED_CURVE 
				{
					_amount		=	animcurve_channel_evaluate(__orient_channel,_amount);
				}
				_p.orient		= lerp(part_type.orient[0],part_type.orient[1],_amount);
			
		}
		#endregion
			
		#region size
		// early exit if there is no range to interpret the property
		if (part_type.size[0]!=part_type.size[2] && part_type.size[1]!=part_type.size[3]) || distr_size != PULSE_DISTRIBUTION.RANDOM
		{
			var split_dimensions = part_type.size[0] != part_type.size[1] || part_type.size[2] != part_type.size[3] 
				
				if distr_size == PULSE_DISTRIBUTION.LINKED_CURVE || distr_size == PULSE_DISTRIBUTION.LINKED
				{
					var _amount_x = get_link_value(__size_link,_p,__size_weight,_save)
					var _amount_y =	_amount_x
				}
				else
				{
					var _amount_x =	random(1);
					var _amount_y =	split_dimensions == true ? random(1) : _amount_x;
				}
				
				if distr_size == PULSE_DISTRIBUTION.ANIM_CURVE  || distr_size == PULSE_DISTRIBUTION.LINKED_CURVE 
				{
					_amount_x =		animcurve_channel_evaluate(__size_x_channel,_amount_x)
					_amount_y =		split_dimensions  == true ? animcurve_channel_evaluate(__size_y_channel,_amount_y) : _amount_x
				}
				
			_p.size = array_create(4,0)
			_p.size[0]		=	lerp(part_type.size[0],part_type.size[2],_amount_x);
			_p.size[2]		= _p.size[0];
			_p.size[1]		=	split_dimensions == true ? lerp(part_type.size[1],part_type.size[3],_amount_y) : _p.size[0] ;
			_p.size[3]		=  _p.size[1];
		}

		#endregion
			
		#region frame
		// Unless changed, it is not calculated, as it is not necessary for other processes.
		if (distr_frame != PULSE_DISTRIBUTION.RANDOM || distr_frame != PULSE_DISTRIBUTION.NONE) &&  _p.particle.set_to_sprite
		{
				if distr_frame == PULSE_DISTRIBUTION.LINKED_CURVE || distr_frame == PULSE_DISTRIBUTION.LINKED
				{
					_amount = get_link_value(__frame_link,_p,__frame_weight,_save)
				}
				else
				{
					_amount = random(1)
				}
				
				if distr_frame == PULSE_DISTRIBUTION.ANIM_CURVE  || distr_frame == PULSE_DISTRIBUTION.LINKED_CURVE 
				{
					_amount		=	animcurve_channel_evaluate(__frame_channel,_amount);
				}
				
				var _f = sprite_get_number(_p.particle.sprite[0])
				_p.frame		= round(_amount*_f)
		}
		#endregion
			
		#region color
		// Unless changed, it is not calculated, as it is not necessary for other processes.
		
		if distr_color_mix != PULSE_DISTRIBUTION.NONE
		{
			if distr_color_mix == PULSE_DISTRIBUTION.LINKED  || distr_color_mix == PULSE_DISTRIBUTION.LINKED_CURVE
			{
				_amount = get_link_value(__color_mix_link,_p,__color_mix_weight,_save)
			}
			else
			{
				_amount = random(1)
			}
			
			if distr_color_mix == PULSE_DISTRIBUTION.ANIM_CURVE || distr_color_mix == PULSE_DISTRIBUTION.LINKED_CURVE
			{
				if __color_mix_link == PULSE_LINK_TO.COLOR_MAP
				{
					_amount[0] = animcurve_channel_evaluate(__color_mix_channel,_amount[0])
					_amount[1] = animcurve_channel_evaluate(__color_mix_channel,_amount[1])
					_amount[2] = animcurve_channel_evaluate(__color_mix_channel,_amount[2])
				}
				else
				{
					_amount = animcurve_channel_evaluate(__color_mix_channel,_amount)
				}
			}
			
			if __color_mix_link == PULSE_LINK_TO.COLOR_MAP
			{
					_p.color_mode =PULSE_COLOR.COLOR_MAP
					_p.r_h =  lerp(__color_mix_A[2],_amount[0],__color_mix_weight[0])
					_p.g_s =  lerp(__color_mix_A[1],_amount[1],__color_mix_weight[1])
					_p.b_v =  lerp(__color_mix_A[0],_amount[2],__color_mix_weight[2])
					var _alpha = lerp(1,_amount[3]/255,__color_mix_weight[3])
					//Uses alpha channel to reduce size of particle , as there is no way to pass individual alpha
				if _p[$ "size"] != undefined && _alpha != 1
				{
					_p.size[0] =  lerp(0,_p.size[0],_alpha)
					_p.size[2] =  _p.size[0]
					_p.size[1] =  lerp(0,_p.size[1],_alpha)
					_p.size[3] =  _p.size[1]
				}
				else if _alpha != 1
				{
					_p.size = array_create(4,lerp(0,part_type.size[1],_alpha))
				}
			}
			else
			{				
				_p.r_h =  lerp(__color_mix_A[2],__color_mix_B[2],_amount)
				_p.g_s =  lerp(__color_mix_A[1],__color_mix_B[1],_amount)
				_p.b_v =  lerp(__color_mix_A[0],__color_mix_B[0],_amount)
				_p.color_mode = distr_color_mix_type
			}
					
		}
	
		#endregion

		return _p
	}
	
	static __set_normal_origin		=	function(_p,x,y)
	{
		switch (form_mode)
		{
			case PULSE_FORM.PATH:
			{
				// path_res -100 is a PathPlus
				if path_res != -100
				{
					var j			= 1/path_res
					_p.x_origin	= path_get_x(path,_p.u_coord)
					_p.y_origin	= path_get_y(path,_p.u_coord)
					var x1			= path_get_x(path,_p.u_coord+j)
					var y1			= path_get_y(path,_p.u_coord+j)
					_p.transv		= point_direction(_p.x_origin,_p.y_origin,x1,y1)
					
					var _pathx=0,_pathy=0
					if path_local 
					{
						_p.x_origin	=_p.x_origin-path_get_point_x(path,0)+x
						_p.y_origin= _p.y_origin-path_get_point_y(path,0)+y
					}
					
					/*// Direction Increments only work with non-GM Particles
					var x2	= path_get_x(path,u_coord+(j*2))
					var y2	= path_get_y(path,u_coord+(j*2))
					_p.arch		= angle_difference(transv, point_direction(x_origin,y_origin,x2,y2))/point_distance(x_origin,y_origin,x2,y2) 
					*/
					_p.normal		= ((_p.transv+90)>=360) ? _p.transv-270 : _p.transv+90;
				}
				else
				{
					var _path = path.SampleFromCache(_p.u_coord)
					_p.x_origin	= _path.x
					_p.y_origin	= _path.y
					_p.transv	= _path.transversal
					_p.normal	= _path.normal
				}
				_p.x_origin	+= (lengthdir_x(_p.length,_p.normal)*x_scale);
				_p.y_origin	+= (lengthdir_y(_p.length,_p.normal)*y_scale);
						
				if x_focal_point!=0 || y_focal_point !=0 // if focal u_coord is in the center, the normal is equal to the angle from the center
				{
					//then, the direction from the focal point to the origin
					_p.normal		=	point_direction(x+(x_focal_point*x_scale),y+(y_focal_point*y_scale),_p.x_origin,_p.y_origin)
					_p.transv		=	((_p.normal-90)<0) ? _p.normal+270 : _p.normal-90;
				}
						
				break;
			}
			case PULSE_FORM.ELLIPSE:
			{
				_p.normal		=	(_p.u_coord*360)%360
						
				_p.x_origin	=	x
				_p.y_origin	=	y
						

				_p.x_origin	+= (lengthdir_x(_p.length,_p.normal)*x_scale);
				_p.y_origin	+= (lengthdir_y(_p.length,_p.normal)*y_scale);
	
							
				if x_focal_point!=0 || y_focal_point !=0 // if focal u_coord is in the center, the normal is equal to the angle from the center
				{
					//then, the direction from the focal point to the origin
					_p.normal		=	point_direction(x+(x_focal_point*x_scale),y+(y_focal_point*y_scale),_p.x_origin,_p.y_origin)
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
					_p.x_origin	+= (lengthdir_x(_p.length,_p.normal)*x_scale);
					_p.y_origin	+= (lengthdir_y(_p.length,_p.normal)*y_scale);
				}
							
				if x_focal_point!=0 || y_focal_point !=0 // if focal u_coord is in the center, the normal is equal to the angle from the center
				{
					//then, the direction from the focal point to the origin
					_p.normal		=	point_direction(x+(x_focal_point*x_scale),y+(y_focal_point*y_scale),_p.x_origin,_p.y_origin)
					_p.transv		=	((_p.normal-90)<0) ? _p.normal+270 : _p.normal-90;
				}
			}
		}
			return _p
		}

	static __assign_direction		=	function(_p)
	{
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
	
	static __check_form_collide		=	function(_p,_e,x,y)
	{
		//If we wish to cull the particle to the "edge" , proceed
		if boundary == PULSE_BOUNDARY.NONE
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
						
		}
		else if abs(angle_difference(_p.dir,_p.normal))<=75	//NORMAL AWAY FROM CENTER
		{	
			//Edge is the distance remaining from the spawn point to the radius
			if _p.length>=0
			{
				var _length_to_edge	=	(_e.edge*edge_external)-_p.length
			}
			else
			{
				var _length_to_edge	=	(_e.edge*edge_internal)+_p.length
			}
		}
		else											//NORMAL TOWARDS CENTER
		{	
			// If particle is going towards a focal point and thats the limit to be followed
			if boundary == PULSE_BOUNDARY.FOCAL_LIFE || boundary == PULSE_BOUNDARY.FOCAL_SPEED
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
						var _length_to_edge	=	_p.length
					}
					else
					{
						var _length_to_edge	=	abs(edge_internal*_e.int)
					}
				}	
			}
		}
					
		//Then we calculate the Total Displacement of the particle over its life
		_p.accel ??=  part_type.speed[2]*(_p.life*_p.life)*.5
		var _displacement = (_p.speed*_p.life)+_p.accel
		_p.disp = _displacement
		// If the particle moves beyond the edge of the radius, change either its speed or life
		if	_displacement > _length_to_edge
		{
			if boundary == PULSE_BOUNDARY.SPEED || boundary == PULSE_BOUNDARY.FOCAL_SPEED
			{
				_p.speed	=	(_length_to_edge-_p.accel)/_p.life
			} 
			else if boundary == PULSE_BOUNDARY.LIFE || boundary == PULSE_BOUNDARY.FOCAL_LIFE
			{
				_p.life	=	(_length_to_edge-_p.accel)/_p.speed
			}
			//We save this in a boolean as it could be used to change something in the particle appeareance if we wished to
			_p.to_edge	+=	1
		}
				

		return _p 		
				
	}
	
	static __check_forces			=	function(_p,x,y)
	{
		// For each local force, analyze reach and influence over particle
		var _forces_length  = array_length(forces)
		var _vec2f =[0,0];	
		for (var k=0;k<_forces_length;k++)
		{
			var _weight = 0;
						
			if forces[k].weight <= 0 continue //no weight, nothing to do here!
						
			var __force_x,__force_y

			__force_x = forces[k].local ? (x+forces[k].x) : forces[k].x
			__force_y = forces[k].local ? (y+forces[k].y) : forces[k].y
						
			if forces[k].range == PULSE_FORCE.RANGE_INFINITE
			{
				_weight = forces[k].weight //then weight is the force's full strength
			}
			else if forces[k].range == PULSE_FORCE.RANGE_DIRECTIONAL
			{

				// relative position of the particle to the force
				var _x_relative = _p.x_origin - __force_x
				var _y_relative = _p.y_origin - __force_y
							
				//If the particle is to the left/right, up/down of the force, retrieve appropriate limit							
				var _coordx = _x_relative<0 ? forces[k].east : forces[k].west
				var _coordy = _y_relative<0 ? forces[k].north : forces[k].south
							
				// if particle origin is within the area of influence OR the influence is infinite (==-1)
				if (abs(_x_relative)< _coordx || _coordx==-1) 
					&& (abs(_y_relative)< _coordy || _coordy==-1)
				{
					//within influence, calculate weight!
					// If the influence is infinite, apply weight as defined
					// Otherwise, the weight is a linear proportion between 0 (furthest point) and weight (center point of force)								
					var _weightx = _coordx==-1? forces[k].weight : lerp(forces[k].weight,0,abs(_x_relative)/_coordx )
					var _weighty = _coordy==-1? forces[k].weight : lerp(forces[k].weight,0,abs(_y_relative)/_coordy )
								
					//Average of vertical and horizontal influences
					_weight= (_weightx+_weighty)/2
				}
				else continue //not within influence. Byebye!
			}
			else if forces[k].range == PULSE_FORCE.RANGE_RADIAL
			{
							
				var _dist = point_distance(_p.x_origin,_p.y_origin,__force_x,__force_y) 
				if _dist < forces[k].radius
				{
					_weight= lerp(forces[k].weight,0,_dist/forces[k].radius )
				}
				else continue //not within influence. 
			}
						
			if (_weight==0) continue; //no weight, nothing to do here!
					
				
			if forces[k].type = PULSE_FORCE.POINT
			{
				var dir_force	=	(point_direction( __force_x,__force_y,_p.x_origin,_p.y_origin)+forces[k].direction)%360
				
				_vec2f[0] += lengthdir_x(forces[k].force*_weight,dir_force);
				_vec2f[1] += lengthdir_y(forces[k].force*_weight,dir_force);
			}else
			{
				_vec2f[0] +=(forces[k].vec[0]*_weight)
				_vec2f[1] +=(forces[k].vec[1]*_weight)
			}
		}// ⮤
		
		if _vec2f[0] != 0 || _vec2f[1] != 0
		{				
			// convert to vectors
			var _vec2 =[0,0];
			_vec2[0] = lengthdir_x(_p.speed,_p.dir);
			_vec2[1] = lengthdir_y(_p.speed,_p.dir);
			// add force's vectors
			_vec2[0] = _vec2[0]+_vec2f[0] 
			_vec2[1] = _vec2[1]+_vec2f[1]
			// convert back to direction and speed
			_p.dir = point_direction(0,0,_vec2[0],_vec2[1])
			_p.speed = sqrt(sqr(_vec2[0]) + sqr(_vec2[1]))
		}				
		
		return _p
	}
	
	#endregion
	
	 /**
	 * @desc Generates a modified stencil which adapts to colliding objects. Returns an array that contains the IDs of all colliding instances 
	 * @param {Real} _x X coordinate
	 * @param {Real} _y Y coordinate
	 * @param {any} [_collision_obj] Any collideable element that can regularly be an argument for collision functions
	 * @param {bool}[_prec] Whether the collision is precise (true, slow) or not (false, fast)
	 * @param {real} [_rays] amount of rays emitted to create a stencil collision
	 */
	static	check_collision = function(x,y,_collision_obj=collisions, _occlude = true, _prec = false , _rays = 32 )
	{
		if is_array(_collision_obj){
		if array_length(_collision_obj)==0
			return undefined
		}
		/// Check for collision of emitter by bbox
		var _collision
		switch (form_mode)
		{
			case PULSE_FORM.PATH:
			{
				var _bbox 
				/// if path, find bounding box of path, then check with collision
				if path_res ==-100
				{
					_bbox = path.GetBbox(edge_external,mask_start,mask_end)
				}
				else
				{
					_bbox = path_get_bbox(path,edge_external,mask_start,mask_end)
				}
				var _collision = collision_rectangle(_bbox[0],_bbox[1],_bbox[2],_bbox[3],_collision_obj,_prec,true)

				break;
			}
			case PULSE_FORM.ELLIPSE:
			{
				if x_scale != 1 or y_scale != 1
				{
					var _collision = collision_ellipse((edge_external-x)*x_scale,(edge_external-y)*y_scale,(edge_external+x)*x_scale,(edge_external+y)*y_scale,_collision_obj,_prec, false)
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
				
				var dir_x = (lengthdir_x(edge_external,normal)*x_scale);
				var dir_y = (lengthdir_y(edge_external,normal)*y_scale);
				
				c[0] =	a[0] + dir_x
				c[1] =	a[1] + dir_y
				d[0] =	b[0] + dir_x
				d[1] =	b[1] + dir_y
				
				var left	= min(a[0],b[0],c[0],d[0])
				var right	= max(a[0],b[0],c[0],d[0])
				var top		= min(a[1],b[1],c[1],d[1])
				var bottom	= max(a[1],b[1],c[1],d[1])
				
				var _collision = collision_rectangle(left,top,right,bottom,_collision_obj,_prec,true)

				break;
			}
		}
		if _collision == undefined || _collision == noone
		{
			if is_colliding
			{
				// Reset the Curve to its original state
				var _array = []
				animcurve_point_add(_array,0,1)
				animcurve_point_add(_array,1,1)
				animcurve_points_set(stencil_profile, "c",_array)
				is_colliding = false
			}
			return undefined
		}
		
		is_colliding = true
		array_resize(colliding_entities,0)
		
		// Emit 32 rays and check for collisions
		var _points		= [] ,
		 _ray			= {u_coord : 0 , length : 0} ,
		 _fail			= 0 ,
		 _l				= (mask_end - mask_start )/_rays
		 
		 for(var i =mask_start; i <= mask_end ; i +=_l)
		{
			_ray.u_coord	= i ;
			var _length		=	edge_external ;
			_ray			= __set_normal_origin(_ray,x,y) ;
			animcurve_point_add(_points,i,1)
			var _ray_collision	= __pulse_raycast(_ray.x_origin,_ray.y_origin,_collision_obj,_ray.normal,_length,_prec,true)
			
			if _ray_collision != noone
			{
				var _value = point_distance(_ray.x_origin,_ray.y_origin,_ray_collision.x,_ray_collision.y)/edge_external
				
				animcurve_point_add(_points,i,_value,true)
				
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
		if _fail = _rays //array_length(_points)
		{
			if is_colliding
			{
				// Reset the Curve to its original state
				var _array = []
				animcurve_point_add(_array,0,1)
				animcurve_point_add(_array,1,1)
				animcurve_points_set(stencil_profile, "c",_array)
				is_colliding = false
			}
			return undefined
		}
		
		if _occlude		
		{
			animcurve_point_add(_points,0,1,false)
			animcurve_point_add(_points,1,1,false)
			animcurve_points_set(stencil_profile,"c",_points)
		}
	
		return colliding_entities
	}
	
	/// @description	Emits the particles from the emitter. Result can be cached instead
	/// @param {Real}	_amount_request : Amount of particles requested for creation. Actual amount might vary if the system has a limit.
	/// @param {Real}	x : X coordinate in System space.
	/// @param {Real}	y : Y coordinate in System space.
	/// @param {Bool}	[_cache] : Whether to save the results of the burst to a cache or not. If true, returns an array instead of emitting particles.
	/// @context pulse_emitter
	static	pulse				=	function(_amount_request,x,y,_cache=false)
	{
		if !_cache
		{
			var _awaken = false
			if part_system.index == -1
			{
				if part_system.wake_on_emit
				{
					_awaken = true
				}
				else
				{
					__pulse_show_debug_message($"System \"{part_system.name}\" is currently asleep!", 1)
					exit
				}
			}
			if part_system.limit > 0 
			{
				if time_source_exists( part_system.count)
				{
					if time_source_get_state(part_system.count) != time_source_state_active
					{
						time_source_start(part_system.count)
					}
				}
				if _amount_request >= part_system.limit
				{
					part_system.factor *= (part_system.limit/_amount_request)
				}
			}
		
			var _amount = floor((_amount_request*part_system.factor)*global.pulse.particle_factor)
			if _amount	== 0
			{
				exit
			}
			if 	_awaken
			{
				part_system.make_awake()
			}
			
		}
		else
		{
			var _amount = _amount_request
			var cache = array_create(_amount,0)
		}
		var div_v,div_u,_xx,_yy,i,j,x1,y1,r_h,g_s,b_v;

		if stencil_profile ==undefined
		{
			stencil_mode = PULSE_STENCIL.NONE
		}
	
		div_v	=	1 +  divisions_v_offset
		if div_v>2 div_v -= 1
		
		div_u	=	1 + divisions_u_offset
		if div_u>2 div_u -= 1
		
		i		=	0

		var _check_forces = array_length(forces)>0 ? true : false ,
			_life = undefined ,
			_accel = part_type.speed[2] == 0 ? 0 : undefined ,
			_speed =  undefined
			
		if part_type.life[0]==part_type.life[1]
		{
			_life		=	part_type.life[0]
			_accel		=	part_type.speed[2]*(_life*_life)*.5
		}
		
		if part_type.speed[0]==part_type.speed[1]
		{
			_speed		=	part_type.speed[0]
		}

		repeat(_amount)
		{
			var particle_struct = { u_coord	: undefined , v_coord	: undefined	, size : undefined	, color_mode : distr_color_mix , orient : undefined, frame : undefined, speed: _speed , life: _life , accel: _accel, part_system:	part_system	, particle:	part_type }
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
			div_v++
			if div_v	>	divisions_v+divisions_v_offset
			{
				div_v	=	1 + divisions_v_offset
				if div_v>2 div_v -= 1
		
				div_u ++
				if div_u > divisions_u + divisions_u_offset
				{
				 	div_u	=	1 + divisions_u_offset
					if div_u>2 div_u -= 1
				}
			}
			// ----- Particle speed and life need to be known before launching the particle, so they can be calculated for form culling
			//SPEED AND LIFE SETTINGS
				
				__assign_properties(particle_struct)
			
			// ----- Form culling changes the life or speed of the particle so it doesn't travel past a certain point
			// FORM COLLIDE (speed/life change) Depending on direction change speed to conform to form

				__check_form_collide(particle_struct,emitter_struct,x,y)

			//APPLY LOCAL AND GLOBAL FORCES
			if _check_forces
			{
				__check_forces(particle_struct,x,y)
			}
			
			if particle_struct.life <=1 continue
			
			if (boundary == PULSE_BOUNDARY.SPEED || boundary == PULSE_BOUNDARY.FOCAL_SPEED) && particle_struct.speed<=.01
			{	continue }

			if particle_struct.to_edge == 2 && ( particle_struct.particle.subparticle != undefined && particle_struct.particle.on_collision)
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
				part_type.launch(particle_struct)
			}

		}
		if _cache
		{ 
			cache= _array_clean(cache)
				return cache
		}
	}
}
