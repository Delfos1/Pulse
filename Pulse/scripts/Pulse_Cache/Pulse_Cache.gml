//feather ignore all in ./*
	
	/// @description	Creates a Pulse Cache storage
	
	/// @param { Struct.pulse_emitter}		_emitter : The emitter from which the particles will be emitted. This is used to update collisions and to get the main particle type.
	/// @param {Array}						_cache : An array populated by a Pulse emitter's output. By default is empty. Particles can be added with the add_particles() methods
function	pulse_cache(_emitter , _cache=[] ) constructor
{

	path				= _emitter.path
	path_res			= _emitter.path_res
	line				= _emitter.line
	part_system			= _emitter.part_system
	index				= 0
	shuffle				= true
	default_amount		= _emitter.default_amount
	cache				= _array_clean(_cache)
	length				= array_length(_cache)
	flag_stencil		= false
	if length > 0
	{
		particle = pulse_fetch_particle(cache[0].particle.name)	
	}

	stencil_profile		=	animcurve_really_create({curve_name: "stencil_profile",channels:[	{name:"c",type: animcurvetype_catmullrom , iterations : 8}]})
	_channel_03			=	animcurve_get_channel(stencil_profile,0)

	form_mode			=	_emitter.form_mode	
	radius_external		=	_emitter.radius_external
	radius_internal		=	_emitter.radius_internal
	edge_external		=	_emitter.edge_external
	edge_internal		=	_emitter.edge_internal
	mask_start			=	_emitter.mask_start
	mask_end			=	_emitter.mask_end
	boundary			=	_emitter.boundary
	x_scale				=	_emitter.x_scale
	y_scale				=	_emitter.y_scale
	collide				= false							// Whether to perform the collision code
	is_colliding		= false							// Whether the cached emitter is colliding or not
	colliding_cache		= undefined						// modified cache for collisions
	colliding_entities	= _emitter.colliding_entities	// Entities to search for collisions
	collisions			= _emitter.collisions			// Entities currently colliding with cached emitter
	/// @desc Adds particles to the cache
	/// @param {Array} array with the results of a pulse emit.
	static	add_particles = function(array)
	{
		cache = array_concat(cache,array)
		length	= array_length(cache)
		
		particle = pulse_fetch_particle(cache[0].particle.name)	
	}
	
		/// @description	Adds a collision element to be checked by the collision function.
	/// @param {Any}	_object : Can be an object, instance, tile or anything admitable 
	/// @context pulse_emitter
	static	add_collisions			=	function(_object)
	{
		array_push(collisions,_object)
		
		return self
	}
		 /**
	 * @desc Generates a modified stencil which adapts to colliding objects. Returns an array that contains the IDs of all colliding instances 
	 * @param {Real} _x X coordinate
	 * @param {Real} _y Y coordinate
	 * @param {any} [_collision_obj] Any collideable element that can regularly be an argument for collision functions.  Default : Stored collisions
	 * @param {bool} [_occlude] Whether to apply the collision to the shape or not. Default : TRUE
	 * @param {bool} [_prec] Whether the collision is precise (true, slow) or not (false, fast) .  Default : FALSE
	 * @param {real} [_rays] amount of rays emitted to create a stencil collision.  Default : 32
	 */
	static	check_collision = function(x,y,_collision_obj=collisions, _occlude = true, _prec = false , _rays = 32 )
	{
		if is_array(_collision_obj){
		if array_length(_collision_obj)==0
			return undefined
		}
		
		var _collision 
		/// Check for collision of emitter by bbox
		switch (form_mode)
		{
			case PULSE_FORM.PATH:
			{
				/// if path, find bounding box of path, then check with collision
				var _bbox = path_get_bbox(path,edge_external,mask_start,mask_end)
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
						
						
				break;
			}
			case PULSE_FORM.ELLIPSE:
			{
				_p.normal		=	(_p.u_coord*360)%360
						
				_p.x_origin	=	x
				_p.y_origin	=	y
						

				_p.x_origin	+= (lengthdir_x(_p.length,_p.normal)*x_scale);
				_p.y_origin	+= (lengthdir_y(_p.length,_p.normal)*y_scale);
	
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

			}
		}
			return _p
		}
	static __check_form_collide		=	function(_p)
	{
		var eval	=	clamp(animcurve_channel_evaluate(_channel_03,_p.u_coord),0,1);
		
		if eval >= 1 { return _p}
		//First we define where the EDGE is, where our particle should stop
		
		var to_transversal = abs(angle_difference(_p.dir,_p.transv)) , 
		_length_to_edge
		
		if to_transversal <=30	or 	 abs(to_transversal-180) <=30//TRANSVERSAL
		{
			// Find half chord of the coordinate to the circle (distance to the edge)
			var _a =power(eval*edge_external,2)-power(_p.length,2)
			var _length_to_edge	= sqrt(abs(_a)) 
						
		}
		else if abs(angle_difference(_p.dir,_p.normal))<=75	//NORMAL AWAY FROM CENTER
		{	
			//Edge is the distance remaining from the spawn point to the radius
			if _p.length>=0
			{
				var _length_to_edge	=	(eval*edge_external)-_p.length
			}
			else
			{
				var _length_to_edge	=	(eval*edge_internal)+_p.length
			}
		}
		else			//NORMAL TOWARDS CENTER
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
		if _length_to_edge < 0
		{
			return undefined
		}
				_p.accel ??=  _p.particle.speed[2]*(_p.life*_p.life)*.5
				_p[$ "disp"] ??= (_p.speed*_p.life)+_p.accel
		// If the particle moves beyond the edge of the radius, change either its speed or life
	
		if	_p.disp > _length_to_edge
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

	/// @desc Emits the particles stored in the cache. X,Y coordinates are relative to the stored position.
	/// @param {real} _amount    Amount of particles to emit
	/// @param {real} x			X coordinate, relative to the stored position
	/// @param {real} y			Y coordinate, relative to the stored position
	static	pulse = function(_amount = default_amount ,x=0,y=0)
	{
		if part_system.index = -1
		{
			if part_system.wake_on_emit
			{
				part_system.make_awake()
			}
			else
			{
				__pulse_show_debug_message($"System \"{part_system.name}\" is currently asleep!", 1)
				exit
			}
		}
		if part_system.limit != 0 && ( time_source_get_state(part_system.count) != time_source_state_active)
		{
			if _amount >= part_system.limit
			{
				part_system.factor *= (part_system.limit/_amount)
			}
				
			time_source_reset(part_system.count)
			time_source_start(part_system.count)
		}
		
		_amount = floor((_amount*part_system.factor)*global.pulse.particle_factor)
		if _amount	== 0 exit
			
		do
		{
			var _target , _i  = index
			
			if (index + _amount) >length
			{
				_target = length-index
				index = 0
				_amount -=  _target
			}
			else
			{
				_target = index+_amount
				index = _target % length
				_amount = 0
			}
			

			if collide && is_colliding
			{
				//var _cache = variable_clone(cache)
				//array_copy(_cache,_i ,cache,_i,_target-_i)
				for(_i = _i  ; _i < _target ; _i++)
				{
					var _particle = __check_form_collide(cache[_i])
					if _particle == undefined continue
					particle.launch(_particle,x,y,part_system.index)
				}
			} else {
				for(_i = _i  ; _i < _target ; _i++)
				{
					particle.launch(cache[_i],x,y,part_system.index)
				}
			}
	
			if  index == 0
			{
				
				if shuffle array_shuffle_ext(cache,irandom_range(0,floor(length/2)),length/2)
			}
		} until(_amount == 0)
	}
}

