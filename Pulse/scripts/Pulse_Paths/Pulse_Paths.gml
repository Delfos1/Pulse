function part_pulse_path_emitter(__path,__part_system=__PULSE_DEFAULT_SYS_NAME,__part_type=__PULSE_DEFAULT_PART_NAME,__radius_external=50) constructor
{
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
				array_push(global.pulse.systems,new pulse_system(__part_system));
				var _struct = array_last(global.pulse.systems);
				__part_system = _struct._system;
			}
			else
			{
				__part_system = get;
			}
		}
	}
	
	if is_string(__part_type)
	{
		if __part_type		==__PULSE_DEFAULT_PART_NAME
		{
				array_push(global.pulse.part_types,new pulse_particle(__part_type))
				var _struct = array_last(global.pulse.part_types);	
				__part_type = _struct._index
		}
		else
		{
			var get = pulse_system_get_ID(__part_type)
			if get == -1
			{
				array_push(global.pulse.part_types,new pulse_particle(__part_type))
				var _struct = array_last(global.pulse.part_types)
				__part_type = _struct._index
			}
			else
			{
				__part_type = get
			}
		}
	}
	
	if path_get_kind(__path) //SMOOTH
	{
	points = power(path_get_number(__path)-1,path_get_precision(__path))
	}
	else
	{
		points = 1
	}
	_path				=	__path
	x					=	0
	y					=	0
	_part_system		=	__part_system
	_index				=	__part_type
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
	_dist_along_normal	=	__PULSE_DEFAULT_EMITTER_DISTRIBUTION
	_dist_along_form		=	__PULSE_DEFAULT_EMITTER_DIRECTION_DIST
	_revolutions		=	1
	_force_to_center	=	false
	_force_to_edge		=	false
	_direction_range	=	[0,0]
	_resolution			=	10

	
	
	//Pulse properties settings
	
	static	shape			=	function(__ac_curve,__ac_channel,_channel="a")
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
	
	static	tween_shape		=	function(__ac_curve_a,__ac_channel_a,__ac_curve_b,__ac_channel_b)
	{
		shape(__ac_curve_a,__ac_channel_a,"a");
		shape(__ac_curve_b,__ac_channel_b,"b");

		_ac_tween =	0;
	}
	
	static	angle			=	function(__angle_start,__angle_end)
	{
		if !is_real(__angle_start)	or !is_real(__angle_end){		show_debug_message("PULSE ERROR: Provided invalid input type (not a number)"); exit}
		_angle_start		=	__angle_start;
		_angle_end			=	__angle_end;
	}
	
	static direction_range	=	function(__dir_start, __dir_end)
	{
		_direction_range	=[__dir_start, __dir_end]
	}

	static	radius			=	function(__radius_internal,__radius_external)
	{
		_radius_internal	=	__radius_internal;
		_radius_external	=	__radius_external;
	}
	
	static	inward			=	function(__speed_min,__speed_max,__life_min,__life_max,__force_to_center=false)
	{
				
		_speed_start		=	[__speed_min,__speed_max];
		_life				=	[__life_min,__life_max]
		_force_to_center	=	__force_to_center;
		_mode				=	PULSE_MODE.INWARD
	}
	
	static	outward_shape	=	function(__speed_min,__speed_max,__life_min,__life_max,__force_to_edge=false,__mode=PULSE_MODE.SHAPE_FROM_POINT)
	{
			
		_speed_start		=	[__speed_min,__speed_max];
		_life				=	[__life_min,__life_max]
		_force_to_edge		=	__force_to_edge;
		_mode				=	__mode
	}

	static	even_distrib	=	function(_angle=true,_length=true,__revolutions=1)
	{
		if _angle
		{
			_dist_along_form		= PULSE_RANDOM.NONE
		}
		if _length
		{
			_dist_along_normal	= PULSE_RANDOM.NONE	
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
		var rev,dir,dir_curve,eval,eval_a,eval_b,length,_xx,_yy,x0,y0,x1,y1,norm,_dir,i,j;
		dir = _angle_start
		rev	= 1
		eval = 1
		// KEEP ROTATION TRANSFORM WITHIN 360 ANGLE
		if  _rot>=360	_rot-=360
		
		points = _resolution
		
		repeat(_amount)
			{
				
				


								
				
				
				#region ASSIGN LENGTH (radius)
				
				if _radius_internal==_radius_external
				{
					// If the 2 radius are equal, then there is no need to randomize
					
					length		=	eval*_radius_external;
				}
				else if _dist_along_normal == PULSE_RANDOM.RANDOM
				{
					//Distribute along the radius by randomizing, then adjusting by shape evaluation
					
					length		=	eval*random_range(_radius_internal,_radius_external);
				}
				else if _dist_along_normal == PULSE_RANDOM.GAUSSIAN
				{
					//Distribute along the radius by gaussian random, then adjusting by shape evaluation
					//This doesnt work great
					
					length		=	eval*gauss(_radius_internal,_radius_external-_radius_internal)//,_radius_internal,_radius_external);
				}
				else if _dist_along_normal == PULSE_SHAPE.A_TO_B
				{
					//Distribute along the radius by randomizing, evaluating by each shape individually
					
					length		=	random_range(eval_a*_radius_internal,eval_b*_radius_external)
				}
				else if _dist_along_normal == PULSE_RANDOM.NONE
				{
					//Distribute evenly
					
					length		=	eval*lerp(_radius_internal,_radius_external,(rev/_revolutions))
					rev++
					if rev>_revolutions rev=1
				}
				#endregion
				
				// Set coordinate position relative to random point
				var _xx		=	x0	+ (lengthdir_x(length,dir)*_scalex);
				var _yy		=	y0	+ (lengthdir_y(length,dir)*_scaley);
			
				switch(_mode)
				{
					case PULSE_MODE.OUTWARD : // OUTWARD emits from the inside out, setting the particle direction only
					{
						//If direction is outwards from center, the direction of the particle is the random direction
						
						part_type_direction(_index,dir,dir,0,0)
						break;
					}
					case PULSE_MODE.INWARD : // INWARD emits from the outside in, setting particle direction and speed particle to end their life before they go past the center point
					{
						//Direction is inwards, the opposite of the prev. assigned direction
						//It is necessary to also calculate the distance to the center to change speed/_life
				
						dir			=	point_direction(_xx,_yy,x0,y0)
						
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

						var displacement = _speed*__life
						
						// If the displacement over the particle _life is greater than the length to the origin, slow down particle to die at origin point.
						
						if ((displacement < length) && _force_to_center) or (displacement > length)
						{
							_speed	=	length/__life
						}

						part_type_life(_index,__life,__life);
						part_type_speed(_index,_speed,_speed,0,0)
						part_type_direction(_index,dir,dir,0,0)
						
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

						var displacement = _speed*__life
						
						// If the displacement over the particle _life is greater than the length to the origin, slow down particle to die at origin.
						
						if ((displacement < length) && _force_to_edge) or (displacement > length)
						{
							_speed	=	length/__life
						}
						
						part_type_life(_index,__life,__life);
						part_type_speed(_index,_speed,_speed,0,0)
						part_type_direction(_index,dir,dir,0,0)
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

						var displacement = _speed*__life
						
						// If the displacement over the particle _life is greater than the length to the origin, slow down particle to die at origin.
						
						if ((displacement < length-length_in) && _force_to_edge) or (displacement > length-length_in)
						{
							_speed	=	(length-length_in)/__life
						}
						
						part_type_life(_index,__life,__life);
						part_type_speed(_index,_speed,_speed,0,0)
						part_type_direction(_index,dir,dir,0,0)
						var _xx		=	x	+ lengthdir_x(length_in,dir);
						var _yy		=	y	+ lengthdir_y(length_in,dir);
						
						break;
					}
				//If _mode is set as none, particle is kept as is, so nothing changes.
				}
				
			part_particles_create(_part_system, _xx,_yy,_index, 1);
			}
	}
}

function	pulse_add_path(_pulse,_path)
{

	if path_get_closed(_path) exit;

	if path_get_kind(_path) //SMOOTH
	{
		var x0,y0,x1,y1,dir,norm,i,j,l,points;	
		
		points = power(path_get_number(_path)-1,path_get_precision(_path))
		
		var callback = function()
		{
			var _direction = array_create(2)
		}
		
		var path_array=array_create_ext(points-1,callback)
		
		i=0;
		l=0;
		j= 1/points;
		do
		{
			x0= path_get_x(_path,i)
			y0= path_get_y(_path,i)
			x1= path_get_x(_path,i+j)
			y1= path_get_y(_path,i+j)
			dir = point_direction(x0,y0,x1,y1)

			norm = ((dir+90)>=360) ? dir-270 : dir+90;

			path_array[l]=[dir,norm];
			i+=j
			l++
		}until (i==1+j)
	
	
	}
	else					//STRAIGHT
	{
		var x0,y0,x1,y1,dir,norm,i,points;	
		
		points = path_get_number(_path)
		
		var callback = function()
		{
			var _direction = array_create(2)
		}
		
		var path_array=array_create_ext(points-1,callback)
		
		i=0;
		repeat(points-1)
		{
			x0= path_get_point_x(_path,i)
			y0= path_get_point_y(_path,i)
			x1= path_get_point_x(_path,i+1)
			y1= path_get_point_y(_path,i+1)
			dir = point_direction(x0,y0,x1,y1)

			norm = ((dir+90)>=360) ? dir-270 : dir+90;

			path_array[i]=[dir,norm];
			i++
		}
	}
	_pulse._path	=	path_array;
}
