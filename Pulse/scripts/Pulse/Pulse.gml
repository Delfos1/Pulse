enum PULSE_MODE
{
	OUTWARD=0,
	INWARD=1,
	SHAPE_FROM_POINT=2,
	SHAPE_FROM_SHAPE=3,
	NONE=4
}
enum PULSE_SHAPE
{
	POINT=10,
	SHAPE=11,
	A_TO_B=12,
}
enum PULSE_RANDOM
{
	RANDOM=20,
	GAUSSIAN=21,
	NONE=22
}




function part_pulse_emitter(__part_system=__PULSE_DEFAULT_SYS_NAME,__part_type=__PULSE_DEFAULT_PART_NAME,__radius_external=50) constructor
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
			array_push(global.pulse.systems,new pulse_system(__part_system))
			var _struct = array_last(global.pulse.systems)
			__part_system = _struct._system
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
				array_push(global.pulse.part_types,new pulse_particle(__part_type))
				var _struct = array_last(global.pulse.part_types);	
				__part_type = _struct._ind
		}
		else
		{
			var get = pulse_system_get_ID(__part_type)
			if get == -1
			{
				array_push(global.pulse.part_types,new pulse_particle(__part_type))
				var _struct = array_last(global.pulse.part_types)
				__part_type = _struct._ind
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
	_ind				=	__part_type
	_ac_channel_a		=	undefined
	_ac_channel_b		=	undefined
	_ac_tween			=	undefined
	_radius_external	=	abs(__radius_external)	
	_radius_internal	=	0
	_angle_start		=	0
	_angle_end			=	360
	_scalex				=	1
	_scaley				=	1
	_rot				=	270
	_speed_start		=	undefined
	_life				=	undefined
	_mode				=	__PULSE_DEFAULT_EMITTER_MODE
	_distribution_mode	=	__PULSE_DEFAULT_EMITTER_DISTRIBUTION
	_direction_mode		=	__PULSE_DEFAULT_EMITTER_DIRECTION_DIST
	_revolutions		=	1
	_force_to_center	=	false
	_force_to_edge		=	false

	
	
	//Pulse properties settings
	
	static	shape		=	function(__ac_curve,__ac_channel,_channel="a")
	{
		try
		{
			switch (_channel)
			{
				case "a":
					_ac_channel_a		=	animcurve_get_channel(__ac_curve,__ac_channel)
					break;
				case "b":
					_ac_channel_b		=	animcurve_get_channel(__ac_curve,__ac_channel)
					break;
			}
		}
		catch(_error)
		{
				show_debug_message("PULSE ERROR: Provided invalid Animation Curve")
		}
	}
	
	static	tween_shape	=	function(__ac_curve_a,__ac_channel_a,__ac_curve_b,__ac_channel_b)
	{
		shape(__ac_curve_a,__ac_channel_a,"a");
		shape(__ac_curve_b,__ac_channel_b,"b");

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
	
	static	inward		=	function(__speed_min,__speed_max,__acc,__life_min,__life_max,__force_to_center=false)
	{
				
		_speed_start		=	[__speed_min,__speed_max,__acc,0];
		_life				=	[__life_min,__life_max]
		_force_to_center	=	__force_to_center;
		_mode				=	PULSE_MODE.INWARD
	}
	
	static	outward_shape	=	function(__speed_min,__speed_max,__acc,__life_min,__life_max,__force_to_edge=false,__mode=PULSE_MODE.SHAPE_FROM_POINT)
	{
			
		_speed_start		=	[__speed_min,__speed_max,__acc,0];
		_life				=	[__life_min,__life_max]
		_force_to_edge		=	__force_to_edge;
		_mode				=	__mode
	}

	static	even_distrib	=	function(_angle=true,_length=true,__revolutions=1)
	{
		if _angle
		{
			_direction_mode		= PULSE_RANDOM.NONE
		}
		if _length
		{
			_distribution_mode	= PULSE_RANDOM.NONE	
		}
		_revolutions = __revolutions
	}

	static	transform	=	function(__scalex=_scalex,__scaley=_scaley,__rot=_rot)
	{
		_scalex			=	__scalex
		_scaley			=	__scaley
		_rot			=	__rot
	}
	
	//Emit/Burst function 
	static	pulse		=	function(_amount,x,y)
	{
		var rev,dir,dir_curve,eval,eval_a,eval_b,length,_xx,_yy;
		dir = _angle_start
		rev	= 1
		// KEEP ROTATION TRANSFORM WITHIN 360 ANGLE
		if  _rot>=360	_rot-=360

		repeat(_amount)
			{
				

				#region ASSIGN DIRECTION (angle)
				//Chooses a direction at random and then plots a random length in that direction.
				//Then adds that coordinate to the origin coordinate.

				if _angle_start==_angle_end
				{
					dir			=	_angle_end;
				}
				else if _direction_mode == PULSE_RANDOM.RANDOM
				{
					//Use random to distribute the direction
					
					dir			=	random_range(_angle_start,_angle_end);
				}
				else if _direction_mode == PULSE_RANDOM.GAUSSIAN
				{
					//Use gaussian to distribute the direction along the mean
					//This doesnt work great
					
					var main=	(_angle_start+_angle_end)/2
					dir			=	gauss(main,main/3);
				}
				else if  _direction_mode == PULSE_RANDOM.NONE
				{
					//Distribute the direction evenly by particle amount and number of revolutions
					var _range = _angle_end-_angle_start
					dir += (_range/(_amount/_revolutions))
					
					if dir >=_angle_end
					{
						dir=_angle_start
					}
				}

				#endregion
								
				#region SHAPE (animation curve)
				
				//If there is an animation curve channel assigned, evaluate it.
				
				eval		=	1;
				if _ac_channel_a !=undefined
				{
					dir_curve = _rot+dir;
					if dir_curve>360 dir_curve-=360;
					
					if _ac_channel_b !=undefined
					{
						eval_a	=	animcurve_channel_evaluate(_ac_channel_a,dir_curve*0.0028);
						eval_b	=	animcurve_channel_evaluate(_ac_channel_b,dir_curve*0.0028);
						eval	=	lerp(eval_a,eval_b,abs(_ac_tween))
					}
					else
					{
						// IF THERE IS NO SHAPE B ASSIGNED
						
						if (_mode==PULSE_MODE.SHAPE_FROM_SHAPE)
						{
							_mode=PULSE_MODE.SHAPE_FROM_POINT
							show_debug_message("PULSE ERROR: Missing Shape B. Reverting mode to Shape from Point")
						}
						if _distribution_mode == PULSE_SHAPE.A_TO_B
						{
							_distribution_mode = PULSE_RANDOM.RANDOM
							show_debug_message("PULSE ERROR: Missing Shape B. Reverting Random Mode to Random")
						}
						eval	=	animcurve_channel_evaluate(_ac_channel_a,dir_curve*0.0028);
					}
					
				}
				else if (_mode==PULSE_MODE.SHAPE_FROM_POINT or _mode==PULSE_MODE.SHAPE_FROM_SHAPE) && _ac_channel_b ==undefined
				{
					//IF THERE IS NO SHAPE A ASSIGNED
					
					_mode=PULSE_MODE.OUTWARD
					show_debug_message("PULSE ERROR: Missing Shape A. Reverting mode to Outward")
				}
				else if	_ac_channel_b !=undefined
				{
					show_debug_message("PULSE WARNING: Missing Shape A. Using Shape B instead")
					eval	=	animcurve_channel_evaluate(_ac_channel_a,dir_curve*0.0028);
				}
				
				#endregion
				
				#region ASSIGN LENGTH (radius)
				
				if _radius_internal==_radius_external
				{
					// If the 2 radius are equal, then there is no need to randomize
					
					length		=	eval*_radius_external;
				}
				else if _distribution_mode == PULSE_RANDOM.RANDOM
				{
					//Distribute along the radius by randomizing, then adjusting by shape evaluation
					
					length		=	eval*random_range(_radius_internal,_radius_external);
				}
				else if _distribution_mode == PULSE_RANDOM.GAUSSIAN
				{
					//Distribute along the radius by gaussian random, then adjusting by shape evaluation
					//This doesnt work great
					
					length		=	eval*gauss(_radius_internal,_radius_external-_radius_internal)//,_radius_internal,_radius_external);
				}
				else if _distribution_mode == PULSE_SHAPE.A_TO_B
				{
					//Distribute along the radius by randomizing, evaluating by each shape individually
					
					length		=	random_range(eval_a*_radius_internal,eval_b*_radius_external)
				}
				else if _distribution_mode == PULSE_RANDOM.NONE
				{
					//Distribute evenly
					
					length		=	eval*lerp(_radius_internal,_radius_external,(rev/_revolutions))
					rev++
					if rev>_revolutions rev=1
				}
				#endregion
				
				// Set coordinate position relative to origin point
				var _xx		=	x	+ (lengthdir_x(length,dir)*_scalex);
				var _yy		=	y	+ (lengthdir_y(length,dir)*_scaley);
			
				switch(_mode)
				{
					case PULSE_MODE.OUTWARD : // OUTWARD emits from the inside out, setting the particle direction only
					{
						//If direction is outwards from center, the direction of the particle is the random direction
						
						part_type_direction(_ind,dir,dir,0,0)
						break;
					}
					case PULSE_MODE.INWARD : // INWARD emits from the outside in, setting particle direction and speed particle to end their life before they go past the center point
					{
						//Direction is inwards, the opposite of the prev. assigned direction
						//It is necessary to also calculate the distance to the center to change speed/_life
				
						dir			=	point_direction(_xx,_yy,x,y)
						
						if _speed_start == undefined
						{
							_speed_start =__PULSE_DEFAULT_PART_SPEED
						}
						if _life == undefined
						{
							_life = __PULSE_DEFAULT_PART_LIFE
						}
						
						var _speed	=	random_range(_speed_start[0],_speed_start[1])
						var __life	=	random_range(_life[0],_life[1])
						var _accel	=	_speed_start[2]

						var displacement = (_speed*__life)+(_accel*__life)
						
						// If the displacement over the particle _life is greater than the length to the origin, slow down particle to die at origin point.
						
						if ((displacement < length) && _force_to_center) or (displacement > length)
						{
							_speed	=	(length-(_accel*__life))/__life
						}

						part_type_life(_ind,__life,__life);
						part_type_speed(_ind,_speed,_speed,_accel,0)
						part_type_direction(_ind,dir,dir,0,0)
						
						break;
					}
					case PULSE_MODE.SHAPE_FROM_POINT : // OUTWARD mode that restricts the speed of the particles to conform to a shape. The opposite of INWARD
					{
						if _speed_start == undefined
						{
							_speed_start =__PULSE_DEFAULT_PART_SPEED
						}
						if _life == undefined
						{
							_life = __PULSE_DEFAULT_PART_LIFE
						}
						
						var _speed	=	random_range(_speed_start[0],_speed_start[1])
						var __life	=	random_range(_life[0],_life[1])
						var _accel	=	_speed_start[2]

						var displacement = (_speed*__life)+(_accel*__life)
						
						// If the displacement over the particle _life is greater than the length to the origin, slow down particle to die at origin.
						
						if ((displacement < length) && _force_to_edge) or (displacement > length)
						{
							_speed	=	(length-(_accel*__life))/__life
						}
						
						part_type_life(_ind,__life,__life);
						part_type_speed(_ind,_speed,_speed,_accel,0)
						part_type_direction(_ind,dir,dir,0,0)
						var _xx		=	x;
						var _yy		=	y;
						
						break;
					}
					case PULSE_MODE.SHAPE_FROM_SHAPE :	// OUTWARD mode that restricts the speed of the particles to conform to a shape for both inner and outer radius
					{

						if _speed_start == undefined
						{
							_speed_start =__PULSE_DEFAULT_PART_SPEED
						}
						if _life == undefined
						{
							_life = __PULSE_DEFAULT_PART_LIFE
						}
						
						var length_in	=	eval_a*_radius_internal;
						var _speed		=	random_range(_speed_start[0],_speed_start[1])
						var __life		=	random_range(_life[0],_life[1])
						var _accel	=	_speed_start[2]

						var displacement = (_speed*__life)+(_accel*__life)
						
						// If the displacement over the particle _life is greater than the length to the origin, slow down particle to die at origin.
						
						if ((displacement < length-length_in) && _force_to_edge) or (displacement > length-length_in)
						{
							_speed	=	(length-(_accel*__life))/__life
						}
						
						part_type_life(_ind,__life,__life);
						part_type_speed(_ind,_speed,_speed,_accel,0)
						part_type_direction(_ind,dir,dir,0,0)
						var _xx		=	x	+ lengthdir_x(length_in,dir);
						var _yy		=	y	+ lengthdir_y(length_in,dir);
						
						break;
					}
				//If _mode is set as none, particle is kept as is, so nothing changes.
				}
				
			part_particles_create(_part_system, _xx,_yy,_ind, 1);
			}
	}
}