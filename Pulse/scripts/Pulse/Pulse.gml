enum PULSE_MODE
{
	OUTWARD,
	INWARD,
	SHAPE_FROM_POINT,
	SHAPE_FROM_SHAPE,
	NONE
}

enum PULSE_RANDOM
{
	RANDOM,
	GAUSSIAN,
	TWEEN,
	NONE
}


global.pulse =
{
	systems		: [],
	part_types	: [],
}

function pulse_system(__name) constructor
{
	_name	=	string(__name);
	_system	=	part_system_create();
	show_debug_message("PULSE SUCCESS: Created system by the name {0}",__name);
}

function pulse_particle(__name) constructor
{
	
	_name			=	string(__name);
	_part_type		=	part_type_create();
	_size			=	__PULSE_DEFAULT_PART_SIZE
	_life			=	__PULSE_DEFAULT_PART_LIFE
	_color			=	__PULSE_DEFAULT_PART_COLOR
	_alpha			=	__PULSE_DEFAULT_PART_ALPHA
	_blend			=	__PULSE_DEFAULT_PART_BLEND
	_speed			=	__PULSE_DEFAULT_PART_SPEED
	_shape			=	__PULSE_DEFAULT_PART_SHAPE
	_sprite			=	undefined
	_orient			=	__PULSE_DEFAULT_PART_ORIENT
	_gravity		=	__PULSE_DEFAULT_PART_GRAVITY
	_direction		=	__PULSE_DEFAULT_PART_DIRECTION
	
	static reset	=	function()
	{
		part_type_size(_part_type,_size[0],_size[1],_size[2],_size[3])
		part_type_life(_part_type,_life[0],_life[1])
		part_type_color3(_part_type,_color[0],_color[1],_color[2])
		part_type_alpha3(_part_type,_alpha[0],_alpha[1],_alpha[2])
		part_type_blend(_part_type,_blend)
		part_type_speed(_part_type,_speed[0],_speed[1],_speed[2],_speed[3])
		if _sprite == undefined 
		{
			part_type_shape(_part_type,_shape)
		}
		else
		{
			part_type_sprite(_part_type,_sprite[0],_sprite[1],_sprite[2],_sprite[3])
		}
		part_type_orientation(_part_type,_orient[0],_orient[1],_orient[2],_orient[3],_orient[4])
		part_type_gravity(_part_type,_gravity[0],_gravity[1])
		part_type_direction(_part_type,_direction[0],_direction[1],_direction[2],_direction[3])
	
	}
	reset()
	show_debug_message("PULSE SUCCESS: Created particle by the name {0}",__name);
}

function part_pulse_emitter(__part_system=__PULSE_DEFAULT_SYS_NAME,__part_type=__PULSE_DEFAULT_PART_NAME,__radius_external=0) constructor
{
	#region Error catching
	if !is_string(__part_system){
	if !part_system_exists(__part_system)						{	show_debug_message("PULSE ERROR: Provided invalid particle system") ;exit}
	}
	if !is_string(__part_type){
	if !part_type_exists(__part_type)  							{	show_debug_message("PULSE ERROR: Provided invalid particle type") ;exit}
	}
	if !is_real(__radius_external) && __radius_external!=0		{	show_debug_message("PULSE ERROR: Provided invalid input type (not a number)") ;exit}
	#endregion
	
	if is_string(__part_system)
	{
		if __part_system==__PULSE_DEFAULT_SYS_NAME
		{
			var l= array_length(global.pulse.systems)
			__part_system	=	string_concat(__part_system,"_",l)
			array_push(global.pulse.systems,new pulse_system(__part_system))
			__part_system = global.pulse.systems[l]._system
		}
		else
		{
			var get = pulse_system_get_ID(__part_system)
			if get == -1
			{
				array_push(global.pulse.systems,new pulse_system(__part_system))
				var _struct = array_last(global.pulse.systems)
				__part_system = _struct._system
			}
			else
			{
				__part_system = get
			}
		}
	}
	
	if is_string(__part_type)
	{
		if __part_type		==__PULSE_DEFAULT_PART_NAME
		{
			var l= array_length(global.pulse.part_types)
			__part_type		=	string_concat(__part_type,"_",l)
			array_push(global.pulse.part_types,new pulse_particle(__part_type))
			__part_type = global.pulse.part_types[l]._part_type
		}
		else
		{
			var get = pulse_system_get_ID(__part_type)
			if get == -1
			{
				array_push(global.pulse.part_types,new pulse_particle(__part_type))
				var _struct = array_last(global.pulse.part_types)
				__part_type = _struct._part_type
			}
			else
			{
				__part_type = get
			}
		}
	}
	
	x					=	0
	y					=	0
	_part_system		=	__part_system
	_part_type			=	__part_type
	_ac_channel_a		=	undefined
	_ac_channel_b		=	undefined
	_ac_tween			=	undefined
	_radius_external	=	abs(__radius_external)	
	_radius_internal	=	0
	_angle_start		=	0
	_angle_end			=	360
	_speed_start		=	undefined
	_life				=	undefined
	_mode				=	__PULSE_DEFAULT_EMITTER_MODE
	_distribution_mode	=	__PULSE_DEFAULT_EMITTER_DISTRIBUTION
	_direction_mode		=	__PULSE_DEFAULT_EMITTER_DIRECTION_DIST
	_force_to_center	=	false
	_force_to_edge		=	false
	_add_to_shape		=	270
	
		
	static  speed_start	=	function(__speed_min,__speed_max)
	{
		if !is_real(__speed_min)	or !is_real(__speed_max){		show_debug_message("PULSE ERROR: Provided invalid input type (not a number)"); exit}

		_speed_start	=	[__speed_min,__speed_max];
		part_type_speed(_part_type,__speed_min,__speed_max,0,0)
	}
	
	//Pulse properties settings
	
	static	shape		=	function(__ac_curve,__ac_channel)
	{
		if animcurve_exists(__ac_curve)
		{
			_ac_channel_a		=	animcurve_get_channel(__ac_curve,__ac_channel)
		}
		else
		{
			show_debug_message("PULSE ERROR: Provided invalid Animation Curve")
		}
	}
	
	static	tween_shape	=	function(__ac_curve_a,__ac_channel_a,__ac_curve_b,__ac_channel_b)
	{
		if animcurve_exists(__ac_curve_a)
		{
			_ac_channel_a		=	animcurve_get_channel(__ac_curve_a,__ac_channel_a)
		}
		else
		{
			show_debug_message("PULSE ERROR: Provided invalid Animation Curve")
		}
		if animcurve_exists(__ac_curve_b)
		{
			_ac_channel_b		=	animcurve_get_channel(__ac_curve_b,__ac_channel_b)
		}
		else
		{
			show_debug_message("PULSE ERROR: Provided invalid Animation Curve")
		}

		_ac_tween =	0;
	}
	
	static	angle		=	function(__angle_start,__angle_end)
	{
		if !is_real(__angle_start)	or !is_real(__angle_end){		show_debug_message("PULSE ERROR: Provided invalid input type (not a number)"); exit}
		_angle_start		=	__angle_start;
		_angle_end			=	__angle_end;
	}

	static	radius		=	function(__radius_internal,__radius_external)
	{
		_radius_internal	=	__radius_internal;
		_radius_external	=	__radius_external;
	}
	
	static	attract		=	function(__speed_min,__speed_max,__life,__force_to_center=false)
	{
		if !is_real(__speed_min)	or !is_real(__speed_max)	or !is_real(__life)	or !is_bool(__force_to_center)	{		show_debug_message("PULSE ERROR: Provided invalid input type (not a number)"); exit}
		
		_speed_start		=	[__speed_min,__speed_max];
		_life				=	__life;
		_force_to_center	=	__force_to_center;
		_mode				=	PULSE_MODE.INWARD
	}
	
	static	fill_shape	=	function(__speed_min,__speed_max,__life,__force_to_edge=false,__mode=PULSE_MODE.SHAPE_FROM_POINT)
	{
		if !is_real(__speed_min)	or !is_real(__speed_max)	or !is_real(__life)	or !is_bool(__force_to_edge)	{		show_debug_message("PULSE ERROR: Provided invalid input type (not a number)"); exit}
		
		_speed_start		=	[__speed_min,__speed_max];
		_life				=	__life;
		_force_to_edge		=	__force_to_edge;
		_mode				=	__mode
	}

	//Emit/Burst function 
	static	pulse		=	function(_amount,x,y)
	{
		if  _add_to_shape>=360	_add_to_shape=0

		repeat(_amount)
			{
				var dir,dir_curve,eval,eval_a,eval_b,length,_xx,_yy;

				//Chooses a direction at random and then plots a random length in that direction.
				//Then adds that coordinate to the origin coordinate.

				if _angle_start==_angle_end
				{
					dir			=	_angle_end;
				}
				else if _direction_mode == PULSE_RANDOM.RANDOM
				{
					dir			=	random_range(_angle_start,_angle_end);
				}
				else if _direction_mode == PULSE_RANDOM.GAUSSIAN
				{
					var main=	(_angle_start+_angle_end)/2
					dir			=	gauss(main,main/3);
				}	

				eval		=	1;
				
				//If there is an animation curve channel assigned, evaluate it.
								
				#region SHAPE (animation curve)
				
				if _ac_channel_a !=undefined
				{
					dir_curve = _add_to_shape+dir;
					if dir_curve>360 dir_curve-=360;
					
					if _ac_channel_b !=undefined
					{
						eval_a	=	animcurve_channel_evaluate(_ac_channel_a,dir_curve*0.0028);
						eval_b	=	animcurve_channel_evaluate(_ac_channel_b,dir_curve*0.0028);
						eval	=	lerp(eval_a,eval_b,abs(_ac_tween))
					}
					else
					{
						if (_mode==PULSE_MODE.SHAPE_FROM_POINT or _mode==PULSE_MODE.SHAPE_FROM_SHAPE)
						{
							_mode=PULSE_MODE.OUTWARD
							show_debug_message("PULSE ERROR: Missing Shape B. Reverting mode to Outward")
						}
						eval	=	animcurve_channel_evaluate(_ac_channel_a,dir_curve*0.0028);
					}
					
				}
				else if (_mode==PULSE_MODE.SHAPE_FROM_POINT or _mode==PULSE_MODE.SHAPE_FROM_SHAPE)
				{
					_mode=PULSE_MODE.OUTWARD
					show_debug_message("PULSE ERROR: Missing Shape A. Reverting mode to Outward")
				}
				
				#endregion
				
				#region ASSIGN LENGTH (radius)
				
				if _radius_internal==_radius_external
				{
					length		=	eval*_radius_external;
				}
				else if _distribution_mode == PULSE_RANDOM.RANDOM
				{
					length		=	eval*random_range(_radius_internal,_radius_external);
				}
				else if _distribution_mode == PULSE_RANDOM.GAUSSIAN
				{
					length		=	eval*gauss(_radius_internal,_radius_external-_radius_internal)//,_radius_internal,_radius_external);
				}
				else if _distribution_mode == PULSE_RANDOM.TWEEN
				{
					length		=	random_range(eval_a*_radius_internal,eval_b*_radius_external)
				}

				#endregion
				
				var _xx		=	x	+ lengthdir_x(length,dir);
				var _yy		=	y	+ lengthdir_y(length,dir);
			
				switch(_mode)
				{
					case PULSE_MODE.OUTWARD :
					{
						//If direction is outwards from center, the direction of the particle is the random direction
						part_type_direction(_part_type,dir,dir,0,0)
						break;
					}
					case PULSE_MODE.INWARD :
					{
						//Direction is inwards, direction should be the opposite. It is necessary to also calculate the distance to the center to change speed/_life
				
						dir			=	point_direction(_xx,_yy,x,y)
						var _speed	=	random_range(_speed_start[0],_speed_start[1])

						var displacement = _speed*_life
						
						// If the displacement over the particle _life is greater than the length to the origin, slow down particle to die at origin.
						
						if ((displacement < length) && _force_to_center) or (displacement > length)
						{
							_speed	=	length/_life
						}

						part_type_life(_part_type,_life,_life);
						part_type_speed(_part_type,_speed,_speed,0,0)
						part_type_direction(_part_type,dir,dir,0,0)
						
						break;
					}
					case PULSE_MODE.SHAPE_FROM_POINT :
					{
						var _speed	=	random_range(_speed_start[0],_speed_start[1])
						var displacement = _speed*_life
						
						// If the displacement over the particle _life is greater than the length to the origin, slow down particle to die at origin.
						
						if ((displacement < length) && _force_to_edge) or (displacement > length)
						{
							_speed	=	length/_life
						}
						
						part_type_life(_part_type,_life,_life);
						part_type_speed(_part_type,_speed,_speed,0,0)
						part_type_direction(_part_type,dir,dir,0,0)
						var _xx		=	x;
						var _yy		=	y;
						
						break;
					}
					case PULSE_MODE.SHAPE_FROM_SHAPE :
					{

						var length_in		=	eval_a*_radius_internal;
						if _ac_channel_b !=undefined

						
						var _speed	=	random_range(_speed_start[0],_speed_start[1])
						var displacement = _speed*_life
						
						// If the displacement over the particle _life is greater than the length to the origin, slow down particle to die at origin.
						
						if ((displacement < length-length_in) && _force_to_edge) or (displacement > length-length_in)
						{
							_speed	=	(length-length_in)/_life
						}
						
						part_type_life(_part_type,_life,_life);
						part_type_speed(_part_type,_speed,_speed,0,0)
						part_type_direction(_part_type,dir,dir,0,0)
						var _xx		=	x	+ lengthdir_x(length_in,dir);
						var _yy		=	y	+ lengthdir_y(length_in,dir);
						
						break;
					}
				//If _mode is set as none, particle is kept as is, so nothing changes.
				}
				
			part_particles_create(_part_system, _xx,_yy,_part_type, 1);
			}
	}
}