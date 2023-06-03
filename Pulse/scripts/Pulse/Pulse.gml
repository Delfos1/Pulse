enum PULSE_MODE
{
	OUTWARD				=	0,
	INWARD				=	1,
	SHAPE_FROM_POINT	=	2,
	SHAPE_FROM_SHAPE	=	3,
	NONE				=	4
}
enum PULSE_SHAPE
{
	POINT				=	10,
	SHAPE				=	11,
	A_TO_B				=	12,
	PATH				=	13
}
enum PULSE_RANDOM
{
	RANDOM				=	20,
	GAUSSIAN			=	21,
	EVEN				=	22,
	NONE				=	23,
}




function pulse_emitter(__part_system=__PULSE_DEFAULT_SYS_NAME,__part_type=__PULSE_DEFAULT_PART_NAME,__radius_external=50) constructor
{
	
	if  struct_exists(global.pulse.systems,__part_system)
	{
		_part_system = global.pulse.systems[$__part_system];
	}
	else
	{
		_part_system = pulse_make_system(__part_system);
	}

	if  struct_exists(global.pulse.part_types,__part_type)
	{
		_part_type = global.pulse.part_types[$__part_type];
	}
	else
	{
		_part_type = pulse_make_particle(__part_type);
	}

	_part_system		=	_part_system.index
	_index				=	_part_type._index
	
	//emitter form
	_path_a				=	undefined
	_path_b				=	undefined
	_path_res			=	-1
	_ac_channel_a		=	undefined
	_ac_channel_b		=	undefined
	_ac_tween			=	undefined
	_radius_external	=	abs(__radius_external)	
	_radius_internal	=	0
	_mask_start			=	0
	_mask_end			=	1
	
	//emitter properties
	x					=	0
	y					=	0
	_scalex				=	1
	_scaley				=	1
	_rot				=	270
	_mode				=	__PULSE_DEFAULT_EMITTER_MODE
	_dist_along_normal	=	__PULSE_DEFAULT_EMITTER_DISTRIBUTION
	_dist_along_form	=	__PULSE_DEFAULT_EMITTER_DIRECTION_DIST
	_revolutions		=	1
	_force_to_edge		=	false	
	
	
	
	_direction_range	=	[0,0]
	_speed_start		=	_part_type._speed
	_life				=	_part_type._life


	
	
	//Pulse properties settings
	
	static	stencil			=	function(__ac_curve,__ac_channel,_channel="a")
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
	
	static	tween_stencil	=	function(__ac_curve_a,__ac_channel_a,__ac_curve_b,__ac_channel_b)
	{
		stencil(__ac_curve_a,__ac_channel_a,"a");
		stencil(__ac_curve_b,__ac_channel_b,"b");

		_ac_tween =	0;
	}
	
	static	mask			=	function(__mask_start,__mask_end)
	{
		_mask_start			=	clamp(__mask_start,0,1);
		_mask_end			=	clamp(__mask_end,0,1);
	}

	static	radius			=	function(__radius_internal,__radius_external)
	{
		_radius_internal	=	__radius_internal;
		_radius_external	=	__radius_external;
	}
	
	static	direction_range	=	function(_direction_min,_direction_max)
	{
		_direction_range	=	[_direction_min,_direction_max]

	}
	
	static	even_distrib	=	function(_angle=true,_length=true,__revolutions=1)
	{
		if _angle
		{
			_dist_along_form		= PULSE_RANDOM.EVEN
		}
		if _length
		{
			_dist_along_normal		= PULSE_RANDOM.EVEN	
		}
		_revolutions = __revolutions
	}

	static	transform		=	function(__scalex=_scalex,__scaley=_scaley,__rot=_rot)
	{
		_scalex			=	__scalex
		_scaley			=	__scaley
		_rot			=	__rot
	}
	
	static	draw_debug		=	function(x,y)
	{
		// draw radiuses
		var ext_x =  _radius_external*_scalex
		var int_x =  _radius_internal*_scalex
		var ext_y =  _radius_external*_scaley
		var int_y =  _radius_internal*_scaley
		draw_ellipse(x-ext_x,y-ext_y,x+ext_x,y+ext_y,true)
		draw_ellipse(x-int_x,y-int_y,x+int_x,y+int_y,true)
		
		//draw origin
		draw_line_width_color(x-10,y,x+10,y,1,c_green,c_green)
		draw_line_width_color(x,y-10,x,y+10,1,c_green,c_green)
		
		//draw angle
		/*
		
		var _anstart_x = x+lengthdir_x(ext_x,_mask_start)
		var _anstart_y = y+lengthdir_y(ext_y,_mask_start)
		var _anend_x = x+lengthdir_x(ext_x,_mask_end)
		var _anend_y = y+lengthdir_y(ext_y,_mask_end)
		draw_line_width_color(x,y,_anstart_x,_anstart_y,1,c_green,c_green)
		draw_line_width_color(x,y,_anend_x,_anend_y,1,c_green,c_green)
		*/
		// draw direction
		if _mode == PULSE_MODE.INWARD
		{
			draw_arrow(x+(ext_x/2),y,x,y,10)
		}
		else
		{
			draw_arrow(x,y,x+(ext_x/2),y,10)
		}
	}
	
	
	//Emit/Burst function 
	static	pulse		=	function(_amount,x,y,_cache=false)
	{
		if _cache var cache = array_create(_amount,0)
		if _path_res ==-1 && _path_a!= undefined
		{
			_path_res = power(path_get_number(_path_a)-1,path_get_precision(_path_a))
			
			if path_get_kind(_path_a) //SMOOTH
			{
				//
			}
			else
			{
				//_path_res = 1
			}
		}
		var rev,dir,dir_stencil,eval,eval_a,eval_b,length,_xx,_yy,i,j,x_origin,y_origin,x1,y1,normal,point,transv;
		var _speed_start	=	_part_type._speed
		var _life			=	_part_type._life
		
		_mask_start = clamp_wrap(_mask_start,0,1)
		_mask_end = clamp_wrap(_mask_end,0,1)
		
		point = _mask_start
		rev	= 1
		i	=	0
		// KEEP ROTATION TRANSFORM WITHIN 360 ANGLE
		if  _rot>=360	_rot-=360

		repeat(_amount)
			{
				var to_edge = false
				
				#region ASSIGN POINT 
				//Chooses a point at random along the form (number between 0 and 1)

				if _mask_start==_mask_end
				{
					point			=	_mask_end;
				}
				else if _dist_along_form	== PULSE_RANDOM.RANDOM
				{
					//Use random to distribute along 
					
					point			=	random_range(_mask_start,_mask_end);
				}
				else if _dist_along_form	== PULSE_RANDOM.GAUSSIAN
				{
					//Use gaussian to distribute the pointection along the mean
					//This doesnt work great
					
					var main=	(_mask_start+_mask_end)/2
					point			=	gauss(main,main/3);
				}
				else if _dist_along_form	== PULSE_RANDOM.EVEN
				{
					//Distribute the point evenly by particle amount and number of revolutions
					var _range = _mask_end-_mask_start
					point += (_range/_revolutions)
					
					if point >=_mask_end
					{
						point=_mask_start
					}
				}

				#endregion
				
				#region FORM (origin and normal)
				
				//If there is a path assigned, evaluate it.
				if		_path_a != undefined 
				{
					point		= random_range(_mask_start,_mask_end);
					j			= 1/_path_res
					x_origin	= path_get_x(_path_a,point)
					y_origin	= path_get_y(_path_a,point)
					x1			= path_get_x(_path_a,point+j)
					y1			= path_get_y(_path_a,point+j)
					var x2		= path_get_x(_path_a,point+(j*2))
					var y2		= path_get_y(_path_a,point+(j*2))
					transv		= point_direction(x_origin,y_origin,x1,y1)
					var arch	= angle_difference(transv, point_direction(x_origin,y_origin,x2,y2))/point_distance(x_origin,y_origin,x2,y2) 

					normal		= ((transv+90)>=360) ? transv-270 : transv+90;
				}
				//Otherwise pick the center of the emitter and convert point into a normal from center
				else
				{
					x_origin	=	x
					y_origin	=	y
					normal		=	point*360
				}
				
				#endregion

				#region DIRECTION (angle)
				//Adds a random range to the normal
				
				if _direction_range[0]!=_direction_range[1]
				{
					dir =	normal + random_range(_direction_range[0],_direction_range[1])
				}
				else
				{
					dir =	normal + _direction_range[0]
				}

				dir =  dir>=360 ? dir-360 : dir;

				#endregion

				#region STENCIL (animation curve)
				
				//If there is an animation curve channel assigned, evaluate it.
				
				eval		=	1;
				eval_a		=	1;
				eval_b		=	1;
				
				if _ac_channel_a !=undefined
				{
					dir_stencil = (_rot/360)+point;
					dir_stencil=  dir_stencil>=1 ? dir_stencil-1 : dir_stencil
					
					if _ac_channel_b !=undefined
					{
						eval_a	=	animcurve_channel_evaluate(_ac_channel_a,dir_stencil);
						eval_b	=	animcurve_channel_evaluate(_ac_channel_b,dir_stencil);
						eval	=	lerp(eval_a,eval_b,abs(_ac_tween))
					}
					else
					{
						// IF THERE IS NO SHAPE B ASSIGNED
						
						if (_mode==PULSE_MODE.SHAPE_FROM_SHAPE)
						{
							_mode=PULSE_MODE.SHAPE_FROM_POINT
							__pulse_show_debug_message("PULSE ERROR: Missing Shape B. Reverting mode to Shape from Point")
						}
						if _dist_along_normal == PULSE_SHAPE.A_TO_B
						{
							_dist_along_normal = PULSE_RANDOM.RANDOM
							__pulse_show_debug_message("PULSE ERROR: Missing Shape B. Reverting Random Mode to Random")
						}
						eval_a	=	animcurve_channel_evaluate(_ac_channel_a,dir_stencil);
						eval	=	eval_a
					}
					
				}
				else if (_mode==PULSE_MODE.SHAPE_FROM_POINT or _mode==PULSE_MODE.SHAPE_FROM_SHAPE) && _ac_channel_b ==undefined
				{
					//IF THERE IS NO SHAPE A ASSIGNED
					
					_mode=PULSE_MODE.OUTWARD
					__pulse_show_debug_message("PULSE ERROR: Missing Shape A. Reverting mode to Outward")
				}
				else if	_ac_channel_b !=undefined
				{
					__pulse_show_debug_message("PULSE WARNING: Missing Shape A. Using Shape B instead")
					eval_a	=	animcurve_channel_evaluate(_ac_channel_b,dir_stencil);
					eval	=	eval_a
				}
				
				#endregion
				
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
				else if _dist_along_normal == PULSE_RANDOM.EVEN
				{
					//Distribute evenly
					
					length		=	eval*lerp(_radius_internal,_radius_external,(rev/_revolutions))
					rev++
					if rev>_revolutions rev=1
				}
				#endregion
			
				// IF COHESION POINT EXISTS, APPLY
				var _speed		=	random_range(_speed_start[0],_speed_start[1])
				var __life		=	random_range(_life[0],_life[1])
				var _accel		=	_speed_start[2]*__life
				var displacement = (_speed*__life)+_accel
				
		
				if abs(dir-normal)<=75			//NORMAL AWAY FROM CENTER
				{		
					if _force_to_edge && (displacement > length)
					{
						if _accel<(_speed*__life)
						{
							_speed	=	(length-_accel)/__life
							to_edge	=	true
						}
					}
				}
				else if abs(angle_difference(dir,normal))<=105		//TRANSVERSAL
				{
					if _force_to_edge
					{
						var _edge		= sqrt(power(_radius_external,2)-power(length,2))
					
						if	displacement > _edge
						{
							_speed	=	(_edge-_accel)/__life
							to_edge	=	true
						}
					}
				}
				else												//NORMAL TOWARDS CENTER
				{										

					if (displacement > length)
					{
						_speed	=	(length-_accel)/__life
						to_edge	=	true
					}
				}
			

				//APPLY LOCAL AND GLOBAL FORCES
				
				//CHECK FOR OCCLUDERS/COLLISIONS
				
				//DETERMINE DYNAMIC PARTICLES

			
				x_origin	+= (lengthdir_x(length,normal)*_scalex);
				y_origin	+= (lengthdir_y(length,normal)*_scaley);
				
				var launch_struct ={
					__life:__life,
					_speed:_speed,
					_accel:_accel,
					x_origin:x_origin,
					y_origin:y_origin,
					dir:dir,
					_part_system:_part_system,
					_index:_index
				}
				
				if _cache
				{
					cache[i]=launch_struct
				}
				else
				{
					_part_type.launch(launch_struct)
				}
				i++
			}
			if _cache return cache
	}
	
	static pulse_from_cache = function(_amount,x,y,_cache)
	{
		var _launch_particle = function(_element,_index)
		{
				_part_type.launch(_element)
		}
		
		array_foreach(_cache,_launch_particle,irandom(array_length(_cache)-1),_amount)
		
		
	}
}