/// Feather ignore all

enum PATHPLUS {LINEAR, BEZIER,CATMULL_ROM,GM_SMOOTH }
/// PATH PLUS 


/// @desc Pathplus constructor. Needs to be provided of a Game Maker Path resource or an array containing structs containing x and y , and optionally speed.
function PathPlus(_path = undefined , auto_gen = true) constructor
{	
	cache		=	[]
	_cache_gen  =	false
	_length_gen	=	false
	_properties = {}
	bbox_bottom = 0
	bbox_top	= 0
	bbox_left	= 0
	bbox_right	= 0
	
	if is_handle(_path)
	{
		path		=	path_add()
		path_assign(path,_path)
		polyline	=	[]
		precision	=	path_get_precision(path)*2;
		closed		=	path_get_closed(path);
		type		=	path_get_kind(path) == true ? PATHPLUS.GM_SMOOTH : PATHPLUS.LINEAR	;
		l			=	path_get_number(path);
		
		if auto_gen
		{
			if type == PATHPLUS.GM_SMOOTH 
			{
				PathToPoly(true,true);
				l			*=	precision;
				type = PATHPLUS.LINEAR
				__pathplus_show_debug("▉!▉ ✦PathPlus✦ Warning ▉!▉: PathPlus doesn't yet manage smooth curves, baking smoothness instead")
			}else{
				PathToPoly(false,true);
			}
		}
		pixel_length=	path_get_length(path)
	}
	else if is_array(_path)
	{
		path		=	path_add()
		polyline	=	_path
		l			=	array_length(polyline)
		precision	=	16;
		closed		=	false;
		type		=	PATHPLUS.LINEAR	;
		pixel_length =	GetLength()
		
		if auto_gen BakeToPath()
	}
	else if _path == undefined
	{
		path		=	path_add()
		polyline	=	[]
		l			=	0
		precision	=	16;
		closed		=	false;
		type		=	PATHPLUS.LINEAR	;
		pixel_length =	0
	}
	else
	{
		__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Provided wrong type of resource for PathPlus creation. Must be a path or an array of coordinates")
	}

	#region Polyline Setters
	
	static SetPrecision			= function(_precision)
	{
		if !is_real(_precision)
		{
			__pathplus_show_debug("▉╳▉✦ PathPlus Error ✦▉╳▉: Wrong type provided")
			return self
		}
		precision = round(_precision*2)
		_precision = clamp(round(_precision),1,8)
		path_set_precision(path,_precision)
		_cache_gen  =	false
		_length_gen	=	false
		return self
	}
	static SetClosed			= function(_closed)
	{
		if !is_bool(_closed)
		{
			__pathplus_show_debug("▉╳▉✦ PathPlus✦ Error ▉╳▉: Wrong type provided")
			return self
		}
		
		if 	closed == _closed return self
		
		closed = _closed
		path_set_closed(path,_closed)
		
		_cache_gen  =	false
		_length_gen  =	false
		
		if PP_AUTO_GEN_PROPS
		{
			_regen()
			GetLength(n,n+1)	
		}
		return self
	}
	/// Adds point at the end of the Polyline
	static AddPoint				= function(_x,_y,_speed = 100,_optional_vars = {}) 
	{
		return InsertPoint(l,_x,_y,_speed,_optional_vars)
	}
	/// Inserts a point to the polyline at the n position
	static InsertPoint			= function(n,_x,_y,_speed = 100,_optional_vars = {}) 
	{
		if !is_real(_x) || !is_real(_y) || !is_real(n) || !is_real(_speed) 
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")
			return self
		}
		n = clamp(n,0,l)
		_speed = clamp(_speed,0,100)
		
		// Check if the requested point already exists
		var _collide = false
		

		if n == 0 
		{
			if closed && (polyline[l-1].x== _x && polyline[l-1].y== _y)														_collide = true
		}
		else if n == l
		{
			if ((polyline[n-1].x== _x && polyline[n-1].y== _y) || (closed && (polyline[0].x== _x && polyline[0].y== _y)) )	_collide = true
		}
		else if (polyline[n].x== _x && polyline[n].y== _y	)	|| 		(polyline[n-1].x== _x && polyline[n-1].y== _y)				_collide = true

		
		if _collide
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Inserted point is in same position as previous or following point.")
			return self
		}
		
		// create point
		_optional_vars.normal		= 0
		_optional_vars.transversal	= 0
		_optional_vars.x		= _x
		_optional_vars.y		= _y
		_optional_vars.speed	= _speed

		l++
		array_insert(polyline,n,_optional_vars)
		_length_gen  =	false
		_cache_gen  =	false
		
		if PP_AUTO_GEN_PROPS
		{
			_regen()
			GetLength(n,n+1)	
		}

		return self
	}
	/// Removes the point on the polyline at the n position
	static RemovePoint			= function(n,_amount = 1) 
	{
		if !is_real(n) || !is_real(_amount) 
		{
			
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")
			return self
		}
		
		if l == 1
		{
			polyline = []
			_cache_gen  =	false
			l			= 0
			pixel_length = 0
			return self
		}
		
		n = clamp(n,0,l-1)
	
		l-=_amount
		array_delete(polyline,n,_amount)
		
		_length_gen  =	false
		_cache_gen  =	false
		
		if PP_AUTO_GEN_PROPS
		{
			_regen()
			GetLength(n,n+_amount)	
		}

		return self
	}
	/// Changes the point on the polyline at the n position
	static ChangePoint			= function(n,_x,_y,_speed = undefined) 
	{
		if !is_real(_x) || !is_real(_y) || !is_real(n)
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")
			return self
		}
		
		n = clamp(n,0,max(0,l-1))
		var	_prevx = polyline[n].x,
			_prevy = polyline[n].y		
		polyline[n].x		= _x
		polyline[n].y		= _y
		if _speed != undefined
		{
			polyline[n].speed		= _speed
		}

		if type == PATHPLUS.BEZIER
		{
			var _first_handle = polyline[n][$"h1"] ?? polyline[n][$"h2"]
			var _other_handle = _first_handle == polyline[n][$"h1"]  ? polyline[n][$"h2"] : undefined
			if _first_handle != undefined 
			{
			_first_handle.x += (_x-_prevx)
			_first_handle.y += (_y-_prevy)
			}

			if _other_handle != undefined 
			{
				_other_handle.x += (_x-_prevx)
				_other_handle.y += (_y-_prevy)
			}
		}

		_length_gen  =	false
		_cache_gen  =	false
		
		if PP_AUTO_GEN_PROPS
		{
			_regen()
			GetLength(n,n+1)	
		}

		return self
	}
	/// Translates the n point on the polyline relative to its current position
	static TranslatePoint		= function(n,_x,_y) 
	{
		if !is_real(_x) || !is_real(_y) || !is_real(n)
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")
			return self
		}
		
		n = clamp(n,0,max(0,l-1))
		_x += polyline[n].x				
		_y += polyline[n].y		
	
		ChangePoint(n,_x,_y)

		return self
	}
	/// Changes a single variable within a point. To be used with user made variables. For PathPlus variables use the proper getters
	static ChangePointVariable	= function(n,_var_as_string,_new_value) 
	{
		if _var_as_string == "x" || _var_as_string == "y" || _var_as_string == "h1" || _var_as_string == "h2" || _var_as_string == "weight" 
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉:Trying to change a restricted variable, use the appropriate setters")
			return self
		}
				n = clamp(n,0,max(0,l-1))
		if !struct_exists(polyline[n],_var_as_string)
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Attempt to change a custom variable failed, variable not found")
			return self
		}

		polyline[n][$ _var_as_string] = _new_value
		polyline[n].cached	= false
		_cache_gen  =	false
		
		return self
	}
	#endregion
	
	#region Polyline Advanced Operations
	/// Adds noise to the Cache channel. Cache can be regenerated to recover the original line
	static AddNoise				= function(_amp,_freq=1)
	{
		if !is_real(_amp) || !is_real(_freq)
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")
			return self
		}
		
		if !_cache_gen && PP_AUTO_GEN_CACHE GenerateCache()
		
		var _l = array_length(cache) , 
		_prev_noise = 0 ,
		_nxt_noise	= 0 ,
		_curr_noise = 0 
		
		_freq = clamp(round(_freq),1,_l)
		
		for(var i = 0 ; i<_l ; i++ )
		{	
			if i%_freq == 0
			{
				_prev_noise = _nxt_noise
				_nxt_noise	= random_range(-_amp,_amp) 
			}
			_curr_noise = lerp(_prev_noise,_nxt_noise,(i%_freq)/_freq)
			
			
			cache[i].x += lengthdir_x(_curr_noise,cache[i].normal)
			cache[i].y += lengthdir_y(_curr_noise,cache[i].normal)
		}
		
		return self
	}
	///Removes redundant points with the Ramer-Douglas-Pecker algorithm . By default, it tries to find a measured number that will work for most cases.
	/// @arg _epsilon Number between 0 and 1 (representing 0 and the max distance between points on the path). 0 = no change, 1 = removes all but 2 points. 
	static Simplify				= function (_epsilon=undefined)
	{
		if !is_real(_epsilon) && _epsilon != undefined
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")
			return self
		}

		if l < 3 
		{
				return self
		}
	var _points = polyline
	var _start = 0
	var _end = l-1
	var simple_point_list = array_create(l)

	simple_point_list[_start]	=_points[_start]
	simple_point_list[_end]		=_points[_end]

	
	// Go through all points to find the points that are furthest and closest from the line between A and B
	var _maxDist = -infinity,
		_maxIndex = -1,
		_avgDist = 0,
		_distToAvg =0
			
	for(var _i = _start ; _i< _end ;_i++)
	{
		var _d = pointToLineDistance(	_points[_i].x		,_points[_i].y,
										_points[_start].x	,_points[_start].y,
										_points[_end].x	,_points[_end].y)
		_avgDist += _d

			
		if _d > _maxDist
		{
				_maxDist	=	_d
				_maxIndex	=	_i
		}
	}
	_avgDist =(_avgDist/_end)*.1
	_epsilon= _epsilon == undefined ? _avgDist : lerp(0,_maxDist,_epsilon)

		polyline	=	_array_clean(_array_merge(simple_point_list,__simplify_step(_points,_epsilon,_start,_end)))
		l			=	array_length(polyline)
		_length_gen  =	false
		_cache_gen  =	false
		if PP_AUTO_GEN_PROPS
		{
			GetLength()	
			_regen()
		}
		
		return self

}
	#endregion
	
	#region Polyline Getters
	/// Get the lenght of the whole path in pixels, or the length inbetween points
	/// @arg _start Start index . 0 by default
	/// @arg _end End index . Length of the path by default
	static GetLength			= function(_start=0,_end=l)
	{		

		if !_cache_gen && type != PATHPLUS.LINEAR
		{
			GenerateCache()
		}
	
		var _array = type == PATHPLUS.LINEAR ? polyline : cache ,
		_iprev , _i , _l_diff = 0  , _l = array_length(_array)


		// Restrict values to usable values
		_start	= clamp(_start,0,max(0,_l-1))
		_end	= clamp(_end,0,max(0,_l-1))
		
		if !_length_gen
		{
			// Cycle through all points in array
			for(var _i= _start; _i < _l; _i++)
			{
				// If _i is the first point of the line, set the length to 0
				if _i == 0 
				{
					_array[_i].l = 0	
					continue
				}
			
				// if _i is within the segment being changed, save the length difference. 
				if _i <= _end
				{
					if _array[_i][$"l"] !=  undefined _l_diff = _array[_i].l 
					_array[_i].l				= _array[_i-1].l + point_distance(_array[_i-1].x,_array[_i-1].y,_array[_i].x,_array[_i].y) 
					_l_diff						= _array[_i].l - _l_diff
				}
				else // if _i is after the segment being changed, apply the length difference. 
				{
					_array[_i].l += _l_diff
				}
			}
			if closed
			{
				_array[0].l		=	_array[_l-1].l +	point_distance(_array[0].x,_array[0].y,_array[_l-1].x,_array[_l-1].y) 
				pixel_length = _array[0].l	
			}
			else
			{
				pixel_length = _array[_l-1].l	
			}
			_length_gen = true
		}
		
		if _start == 0 && _end == l
		{
			return pixel_length
		}
		else
		{
			return (_array[_end].l - _array[_start].l)
		}
		
		
	}
	/// Gets the closest control point on the path. Returns an index from the polyline array
	/// @arg _n Position between 0 and 1 representing the extension of the path
	static GetClosestPoint	= function(_n)
	{
				if !is_real(_n)
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")
			return 
		}

		var _l = pixel_length * _n ,
		_t = 0 ,
		_point = {}

		var _min = 0,
		_max	= l,
		_ind	= 0

		// Search for closest point index that is lower than the target
 		while (_min < _max)
		{
			_ind = floor((_max + _min)/2);
					
			if _ind+1	== l
			break
			//  If current point is equal to the value, or the value is between this and the next point
			if  polyline[_ind].l <= _l && polyline[_ind+1].l > _l 
			{
				if (polyline[_ind].l + polyline[_ind+1].l )/2 > _l
				{
				// If the value is closer to the next point than the current one
					_ind +=1;
				}
				break
			}
			else if polyline[_ind].l > _l
			{
				_max	= _ind;
			} else _min = _ind+1;
		}
	
	return _ind
	
	}
	/// Gets the relative location of a point index _i in the path. Returns a normalized position in the path, from 0 to 1
	/// @arg _i The point´s index	
	static GetPointLocation = function(_i)
	{
		if !is_real(_i) || _i >= l 
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")	
			return
		}
		
		if PP_AUTO_GEN_PROPS && !_length_gen	
		{
			GetLength()
		}
		
		return  polyline[_i].l / pixel_length
	}
	/// Gets the closest point on the path to a set of room coordinates. Returns an index from the polyline array or a length between 0 and 1 representing the extension of the path
	/// @arg _x Position x on room space
	/// @arg _y Position y on room space
	/// @arg _point_or_length Whether to return a point index (true - default ) or a normalized length (false)
	/// @arg _use_cache Whether to use the cache (true) or the polyline (false - default)
	static GetClosestToCoord = function(_x,_y,_point_or_length= true , _use_cache = false)
	{
		// Go through all points checking for the smallest distance to the reference coordinates
	// saving the index. Pnce found, check either side of the index for the second closest. Do trigonometry and find whats the position of the reference point on the segment.
	// Get the pixel lenght of this slashed segment and get the path length .
	var _cls_i = 0 , _cls_d = infinity , _d = 0 , _d2 = 0 , _cls_i2 = 0 ,
	_array = _use_cache ?  cache :  polyline,
	_l = _use_cache ?  array_length(cache) : l
	
		for(var _i =0 ;_i<_l ; _i++)
		{
			_d = point_distance(_array[_i].x,_array[_i].y,_x,_y)
			
			if _d < _cls_d
			{
				_cls_d = _d
				_cls_i = _i
			}
		}
		
		// If user wanted to retrieve the index of the point, we are done here. Easy as that
		if _point_or_length return _cls_i
		
		///~~~~~~~~~~~~~~~~~~
		var _i_next , _i_prev , _curr_l
					
		_curr_l = _array[_cls_i].l
		
		if _cls_i == 0
		{
			_curr_l = 0
			if closed 
			{
				_i_next = _cls_i+1
				_i_prev = l-1
			}
		
		}
		else if _cls_i == l-1
		{
			if closed 
			{
				_i_next = 0
				_i_prev = _cls_i-1
			}
		}
		else
		{
			_i_next = _cls_i+1
			_i_prev = _cls_i-1
		}
		
		_d2 = point_distance(_array[_i_next].x,_array[_i_next].y,_x,_y)	
		_d	= point_distance(_array[_i_prev].x,_array[_i_prev].y,_x,_y)	
			
		if _d2 < _d 
		{
			var	_w = (_array[_i_next].l -  _curr_l) * (_cls_d / _d2) ,
				_t = (_array[_cls_i].l + _w ) / pixel_length
		} else {

			var	_w = (_curr_l -  _array[_cls_i-1].l) * (_cls_d / _d) ,
				_t = (_array[_i_prev].l + _w ) / pixel_length
		}
		
	 return _t
	}
	/// Gets a point along the path, from 0 to 1
	static Sample		= function(_n)
	{
		if !is_real(_n)
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")
			return self
		}
		
		
		var _l = pixel_length * _n ,
		_t = 0 ,
		_point = {}

		var _min = 0,
		_max	= l,
		_ind	= 0

		// Search for closest point index that is lower than the target
		while (_min < _max)
		{
			_ind = floor((_max + _min)/2);
					
			if _ind+1	== l
			{
				if	polyline[_ind].l > _l				_ind--
				break
			}
			
			//  If current point is equal to the value, or the value is between this and the next point
			if  polyline[_ind].l <= _l && polyline[_ind+1].l > _l 
			{
				break
			}
			else if polyline[_ind].l > _l
			{
				_max	= _ind;
			} else _min = _ind+1;
		}
	
		// Get the next point to establish a segment. If greater than the length of the array, wrap around
		var _ind2 = (_ind + 1)%l

		// If the first point is 0, ignore its length. If the second point is 0, the path is closed
		var _l = _ind==0 ? _l : _l - polyline[_ind].l ,
			_w = _ind==0 ? polyline[_ind2].l : polyline[_ind2].l -  polyline[_ind].l;

		// establish the percentage between the two points of the interval
		if (_w != 0)
		{
			_t =  _w != 0 ? _l / _w : _l
		}
	
		switch(type)
		{
				case PATHPLUS.LINEAR:
				_point = { x : lerp(polyline[_ind].x,polyline[_ind2].x,_t), y : lerp(polyline[_ind].y,polyline[_ind2].y,_t)}
				_point.transversal = point_direction(polyline[_ind].x,polyline[_ind].y,polyline[_ind2].x,polyline[_ind2].y)
				_point.normal = _point.transversal + 90
				break;
				case PATHPLUS.BEZIER:
				{
					_point = __bezier_point(polyline[_ind],polyline[_ind2],_t)
					break;
				}
				case PATHPLUS.CATMULL_ROM:
				{
					if polyline[_ind][$"segment"] == undefined || ( !closed && _ind >= l-1 )
					{
						var _point = 	polyline[_ind] 
						_point.transversal = polyline[_ind-1].transversal 
						_point.normal =  polyline[_ind-1].normal
					}
					else
					{
						var _point =	__catmull_rom_point(polyline[_ind].segment,_t)
					}
				break;
				}
			}
	
		_point.speed = lerp(polyline[_ind].speed,polyline[_ind2].speed,_t)
		_point.l = pixel_length * _n
	return _point
	}
	/// Gets a point along the path, from 0 to 1, from the cache (faster)
	static SampleFromCache = function(_n)
	{
		if  !is_real(_n)
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")
			return self
		}
		
		if !_cache_gen && PP_AUTO_GEN_CACHE GenerateCache()
		
		var _length = array_length(cache) ,
		_l = pixel_length * _n ,
		_t = 0 ,
		_point = {}

		var _min = 0,
		_max	= _length-1,
		_ind	= 0

		// Search for closest point index that is lower than the target
		while (_min < _max)
		{
			_ind = floor((_max + _min)/2);
					
			if _ind+1	== _length
			break
			//  If current point is equal to the value, or the value is between this and the next point
			if  cache[_ind].l <= _l && cache[_ind+1].l > _l 
			{
				break
			}
			else if cache[_ind].l > _l
			{
				_max	= _ind;
			} else _min = _ind+1;
		}
	
		// Get the next point to establish a segment. If greater than the length of the array, wrap around
		var _ind2 = (_ind + 1)%_length

		// If the first point is 0, ignore its length. If the second point is 0, the path is closed
		var _l = _ind==0 ? _l : _l - cache[_ind].l ,
			_w = _ind==0 ? cache[_ind2].l : cache[_ind2].l -  cache[_ind].l;

		// establish the percentage between the two points of the interval
		if (_w != 0)
		{
			_t =  _w != 0 ? _l / _w : _l
		}
	

		_point = { x : lerp(cache[_ind].x,cache[_ind2].x,_t), y : lerp(cache[_ind].y,cache[_ind2].y,_t)}
		_point.transversal = lerp_angle(cache[_ind].transversal,cache[_ind2].transversal,_t)
		_point.normal = _point.transversal + 90
		_point.speed = lerp(cache[_ind].speed,cache[_ind2].speed,_t)
		_point.l = pixel_length * _n
		return _point
	}
	
	static GetBbox = function(_padding=0,_from=0,_to=1)
	{
		var _path= type == PATHPLUS.LINEAR ? polyline : cache ,
		_iprev , _i , _l_diff = 0  , _l = array_length(_path)
	
		_from	= floor(lerp(1,_l,_from))
		_to		= floor(lerp(1,_l,_to))
	
		var _x_array , _x, _y_array , _y
	
		_x_array	= [0,0]
		_x_array[0]	= _path[0].x
		_x_array[1]	= _x_array[0]
		for(var _i = 1 + _from ; _i<_to ; _i ++ )
		{
			_x = _path[_i].x
		
			if _x > _x_array[1]
			{
				_x_array[1] = _x
			}
			else if _x < _x_array[0]
			{
				_x_array[0] = _x
			}
		}
	
		_y_array	= [0,0]
		_y_array[0]	= _path[0].y
		_y_array[1]	= _y_array[0]
		for(var _i = 1 + _from ; _i<_to ; _i ++ )
		{
			_y = _path[_i].y
		
			if _y > _y_array[1]
			{
				_y_array[1] = _y
			}
			else if _y < _y_array[0]
			{
				_y_array[0] = _y
			}
		}
		bbox_bottom = _y_array[1]+_padding
		bbox_top	= _y_array[0]-_padding
		bbox_left	= _x_array[0]-_padding
		bbox_right	= _x_array[1]+_padding
		

		return [bbox_left,bbox_top,bbox_right,bbox_bottom]
	}
	#endregion
	
	#region Path Wrappers
	
	static PathAddPoint		= function(x,y,speed=100)
	{
		path_add_point(path,x,y,speed)
		_mismatch	= true
		return self
	}
	static PathChangePoint	= function(n,x,y,speed=100)
	{
		path_change_point(path,n,x,y,speed)
		_mismatch	= true
		return self
	}
	static PathInsertPoint	= function(n,x,y,speed=100)
	{
		path_insert_point(path,n,x,y,speed)
		_mismatch	= true
		return self
	}
	static PathDeletePoint	= function(n)
	{
		path_delete_point(path,n)
		_mismatch	= true
		return self
	}
	static PathFlip			= function(h_or_v = false)
	{
		if !h_or_v
		{
			path_flip(path)
		}
		else
		{
			path_mirror(path)
		}
		return self
	}
	static PathScale		= function(xscale,yscale)
	{
		path_rescale(path,xscale,yscale)
		return self
	}
	static PathRotate		= function(angle)
	{
		path_rotate(path,angle)
		return self
	}
	static PathTranslate	= function(x,y)
	{
		path_shift(path,x,y)
		return self
	}
	static PathReverse		= function()
	{
		path_reverse(path)
		_mismatch	= true
		return self
	}
	static PathSet			= function(_path)
	{
		if !is_handle(_path) return
		path_assign(path,_path)
		Reset()
		return self
	}
	static PathAppend		= function(_path)
	{
		if !is_handle(_path) return
		path_append(path,_path)
		_mismatch	= true
		return self
	}
	
	#endregion
	
	#region Bezier Handles
	
	/// Changes the position of a bezier handle
	/// @param {Real}  _n Index of the point whose handle will change
	/// @param {Real}  x Absolute x position
	/// @param {Real}  y Absolute y position
	/// @param {Bool}  _handle The handle to change. true: handle 1 (with-flow handle) false: handle 2 (counter-flow handle)
	/// @param {Bool}  _break Whether the opposite handle will remain where it is (true) or reposition to mantain curve continuity (false)
	/// @param {Bool}  _symmetric Whether the opposite handle will reposition to remain equidistant from the changed handle (true) or keep its current length from point (false)
	static ChangeBezierHandle = function(_n,x,y,_handle=true,_break = false,_symmetric = true)
	{
		if type != PATHPLUS.BEZIER return;
		
		var _first_handle = _handle == true ? polyline[_n][$"h1"] : polyline[_n][$"h2"]
		var _other_handle = _handle == true ? polyline[_n][$"h2"] : polyline[_n][$"h1"]
		if _first_handle == undefined return;
		
		
		_first_handle.x = x
		_first_handle.y = y
		

		if _other_handle != undefined  && !_break
		{
			var _angle = point_direction(polyline[_n].x, polyline[_n].y, _first_handle.x,_first_handle.y)+180
			var _length = _symmetric ? 
							point_distance(polyline[_n].x, polyline[_n].y, _first_handle.x,_first_handle.y) : 
							point_distance(polyline[_n].x, polyline[_n].y, _other_handle.x,_other_handle.y) ;
			_other_handle.x =  polyline[_n].x+lengthdir_x(_length,_angle)
			_other_handle.y =  polyline[_n].y+lengthdir_y(_length,_angle)
		}
		_cache_gen  =	false
		_length_gen	=	false
		/*
		 polyline[max(0,(_n-1))].cached = false
		 polyline[_n].cached = false*/
		return self
	}
	/// Changes the position of a bezier handle to a position relative to its control point
	/// @param {Real}  _n Index of the point whose handle will change
	/// @param {Real}  x Relative x position
	/// @param {Real}  y Relative y position
	/// @param {Bool}  _handle The handle to change. true: handle 1 (with-flow handle) false: handle 2 (counter-flow handle)
	/// @param {Bool}  _break Whether the opposite handle will remain where it is (true) or reposition to mantain curve continuity (false)
	/// @param {Bool}  _symmetric Whether the opposite handle will reposition to remain equidistant from the changed handle (true) or keep its current length from point (false)
	static ChangeRelativeBezierHandle = function(_n,x,y,_handle=true,_break = false,_symmetric = true)
	{
		if type != PATHPLUS.BEZIER return
		
		x= polyline[_n].x+x
		y= polyline[_n].y+y
		
		ChangeBezierHandle(_n,x,y,_handle,_break,_symmetric)
		return self
	}
	/// Translates the position of a bezier handle
	/// @param {Real} _n Index of the point whose handle will change
	/// @param {Real}  x Relative x position
	/// @param {Real}  y Relative y position
	/// @param {Bool}  _handle The handle to change. true: handle 1 (with-flow handle) false: handle 2 (counter-flow handle)
	/// @param {Bool}  _break Whether the opposite handle will remain where it is (true) or reposition to mantain curve continuity (false)
	/// @param {Bool}  _symmetric Whether the opposite handle will reposition to remain equidistant from the changed handle (true) or keep its current length from point (false)
	static TranslateBezierHandle = function(_n,x,y,_handle=true,_break = false,_symmetric = true)
	{
		if type != PATHPLUS.BEZIER return

		var _first_handle = _handle == true ? polyline[_n][$"h1"] : polyline[_n][$"h2"]
		if _first_handle == undefined return self;
		
		 x = _first_handle.x + x
		 y = _first_handle.y + y
		
		ChangeBezierHandle(_n,x,y,_handle,_break,_symmetric)
		return self
	}
	/// Changes the position of a bezier handle using angle and length from the control point
	/// @param {Real}  n Index of the point whose handle will change
	/// @param {Real}  _angle Angle in degrees
	/// @param {Real}  _length Length in pixels from the control point
	/// @param {Bool}  _handle The handle to change. true: handle 1 (with-flow handle) false: handle 2 (counter-flow handle)
	/// @param {Bool}  _break Whether the opposite handle will remain where it is (true) or reposition to mantain curve continuity (false)
	/// @param {Bool}  _symmetric Whether the opposite handle will reposition to remain equidistant from the changed handle (true) or keep its current length from point (false)
	static VectorBezierHandle = function(_n,_angle,_length,_handle=true,_break = false,_symmetric = true)
	{
		if type != PATHPLUS.BEZIER return;
		
		var _first_handle = _handle == true ? polyline[_n][$"h1"] : polyline[_n][$"h2"]
		var _other_handle = _handle == true ? polyline[_n][$"h2"] : polyline[_n][$"h1"]
		if _first_handle == undefined return;
		
		_first_handle.x = polyline[_n].x+lengthdir_x(_length,_angle)
		_first_handle.y = polyline[_n].y+lengthdir_y(_length,_angle)
		
		if _other_handle == undefined return;
		
		if !_break
		{
			_angle += 180
			_length = _symmetric ? 
							_length : 
							point_distance(polyline[_n].x, polyline[_n].y, _other_handle.x,_other_handle.y) ;
			_other_handle.x =  polyline[_n].x+lengthdir_x(_length,_angle)
			_other_handle.y =  polyline[_n].y+lengthdir_y(_length,_angle)
		}
		_cache_gen  =	false
		_length_gen	=	false
		return self
	}
	
	static GetBezierHandleLength	= function(_n,_handle=true)
	{
		if type != PATHPLUS.BEZIER return;
		
		_handle =  true ? polyline[_n][$"h1"] : polyline[_n][$"h2"]
		if _handle == undefined return;
		return		point_distance(polyline[_n].x, polyline[_n].y, _handle.x,_handle.y) ;
		
	}
	static GetBezierHandleAngle		= function(_n,_handle=true)
	{
		if type != PATHPLUS.BEZIER return;
		
		_handle = true ? polyline[_n][$"h1"] : polyline[_n][$"h2"]
		if _handle == undefined return;
		return		point_direction(polyline[_n].x, polyline[_n].y, _handle.x,_handle.y) ;
	}

	#endregion

	#region Generators
	/// Generates length, normal, transversal, and curve properties for the path. Only use if you have deactivated the automatic regeneration from the Config file
	static GenerateProperties = function()
	{
		GetLength()	
		_regen()
	}
	/// Generates a cache of the curve. Use if you want a different kind of cache from the standard or if you deactivated automatic cache from the Config file
	static GenerateCache	= function(_precision =precision , _force=false )
	{
		if (_cache_gen && !_force )|| l <= 1  return
		
		var _t = 1/_precision 
		cache = []
		var _n = 0
		var _length_total = 0
		for (var _i= 0 ; _i < l; _i++ )
		{ 
			if ( !closed && _i == l-1 ) break
			for(var _stp = 0 ; _stp <=1 ; _stp+= _t)
			{
				if _stp == 0
				{
						var _point = polyline[_i] 
						
						switch(type)
						{
							case PATHPLUS.LINEAR:

							break;
							case PATHPLUS.BEZIER:
									var _point_transv =	__bezier_point(polyline[_i],polyline[(_i+1)%l],_stp)
									_point.transversal = _point_transv.transversal
									_point.normal = _point.transversal + 90
							break;
							case PATHPLUS.CATMULL_ROM:
									if polyline[_i][$"segment"] == undefined || ( !closed && _i >= l-1 )
									{
										_point.transversal = cache[_n-1].transversal
										_point.normal =  cache[_n-1].normal
									}
									else
									{
										var _point_transv =	__catmull_rom_point(polyline[_i].segment,_stp)
										_point.transversal = _point_transv.transversal
										_point.normal = _point.transversal + 90
									}
							break;
						}
					cache[_n]	= _point
					
				}
				else
				{
									
				switch(type)
				{
					case PATHPLUS.LINEAR:
							var _point ={};
							_point.x = lerp(polyline[_i].x,polyline[(_i+1)%l].x,_stp)
							_point.y = lerp(polyline[_i].y,polyline[(_i+1)%l].y,_stp)
							_point.transversal = point_direction(polyline[_i].x,polyline[_i].y,polyline[(_i+1)%l].x,polyline[(_i+1)%l].y)
							_point.normal = _point.transversal + 90
							if _stp-_t == 0 && _i > 0
							{
								
								cache[_n-1].transversal	= lerp_angle(cache[_n-2].transversal,_point.transversal,.5)
								cache[_n-1].normal = cache[_n-1].transversal + 90
							}
							
					break;
					case PATHPLUS.BEZIER:
							var _point =	__bezier_point(polyline[_i],polyline[(_i+1)%l],_stp)
					break;
					case PATHPLUS.CATMULL_ROM:
							if polyline[_i][$"segment"] == undefined || ( !closed && _i >= l-1 )
							{
								var _point = 	polyline[_i] 
								_point.transversal = cache[_n-1].transversal
								_point.normal =  cache[_n-1].normal
							}
							else
							{
								var _point =	__catmull_rom_point(polyline[_i].segment,_stp)
							}
					break;
				}
				

				if polyline[_i][$ "speed"] != undefined && polyline[(_i+1)%l][$ "speed"] != undefined 
				{
					_point.speed = lerp(polyline[_i].speed,polyline[(_i+1)%l].speed,_stp)
				}
				else
				{
					_point.speed = 99
				}
				
				cache[_n]= _point
				
					var _d				=	point_distance(cache[_n-1].x,cache[_n-1].y,cache[_n].x,cache[_n].y) 
					_length_total		+=	_d
							
				}
				cache[_n].l = _length_total
				if _stp <1 {_n++}
			}
			polyline[(_i+1)%l].l	= _length_total
		}
		pixel_length = _length_total

		_cache_gen = true	
		_length_gen = true
			
	return
	}
		/// Generates a cache of the path at even intervals, in pixels. Samples from an inbetween cache that can be generated beforehand.
	static GenerateCacheEven = function(_pxlength)
	{
		if !_cache_gen
		{
			GenerateCache()
		}
		
		if _pxlength > pixel_length/2 return
		
		var _t = _pxlength / pixel_length , _n = 0, _cache = array_create( floor(pixel_length /_pxlength) ),
		_d = 0 , _length_total = 0
		

		for(var i = 0; i <=1 ; i += _t )	
		{
			_cache[_n] = Sample(i)
			_n++
			if i == 0 continue 
			
			 _d				=	point_distance(_cache[_n-2].x,_cache[_n-2].y,_cache[_n-1].x,_cache[_n-1].y) 
			_length_total		+=	round(_d)
			_cache[_n-1].l = _length_total
		}
		
		// cap the path in case the latest sample was behind the end
		if (i > 1 && i-_t < 1) && !closed
		{
			_cache[_n] = SampleFromCache(1)
			_cache[_n].l = pixel_length
		}
		
		cache = _cache
		_cache_gen = true	
	}
	/// Generates a polyline out of the path
	static PathToPoly		= function(_bake_smooth = false , _keep_speed =true)
	{
		var _l = path_get_number(path)

		if _l < 2 return
		
		var _bake = ( path_get_kind(path)  && _bake_smooth ),
		_d = 0,
		_total_length = 0
		
		if _bake
		{
			var _t =   1 / (precision * _l) 
			polyline = array_create(precision *_l)
			_l = 1
		}
		else
		{
			var _t =   1
			polyline = array_create(_l)
		}
			
			
		for(var _i= 0, _n = 0; _i < _l; {_i+= _t ; _n+=1 ;})
		{
			var _point = {x:0,y:0,speed:0,normal:0,transversal:0}
				
			if _bake
			{
				_point.x = path_get_x(path,_i)
				_point.y = path_get_y(path,_i)	
				if _keep_speed _point.speed = path_get_speed(path,_i) else _point.speed = 100
			}
			else
			{
				_point.x = path_get_point_x(path,_i)
				_point.y = path_get_point_y(path,_i)				
				if _keep_speed _point.speed = path_get_point_speed(path,_i) else _point.speed = 100
			}

			// Register Normal and length at conversion
				
			if _i != 0
			{
				polyline[_n-1].transversal	= point_direction(polyline[_n-1].x,polyline[_n-1].y,_point.x,_point.y)
				polyline[_n-1].normal		= polyline[_n-1].transversal + 90
				_total_length		+=	point_distance(polyline[_n-1].x,polyline[_n-1].y,_point.x,_point.y) 
				_point.l			= _total_length
				if _i+_t == _l
				{
					_point.transversal = polyline[_n-1].transversal
					_point.normal = polyline[_n-1].normal
				}
			}
			else
			{
				if closed
				{
					_point.l = path_get_length(path)
				}
				else
				{
					_point.l = 0	
				}
			}

			_point.cached	= false
			polyline[_n] = _point
		}
	}
	///Transforms all the points in cache into control points of a GM Path
	static BakeToPath		= function()
	{
		if (!_cache_gen || cache == undefined) && PP_AUTO_GEN_CACHE  GenerateCache()
		
		if array_length(cache) < 2 return
		path_clear_points(path)
		path_set_closed(path,closed)
		path_set_precision(path,clamp(precision/2,1,8))
		path_set_kind(path,0)
		
		for (var _i= 0; _i < array_length(cache); _i++)
		{
			var _speed =  cache[_i][$ "speed"] ?? 100
			path_add_point(path,cache[_i].x,cache[_i].y,_speed)
		}
		
		return path
	}
	
	/// Export a .yy file with the contents of the cache polyline. You need to overwrite an existing path in your GameMaker project for it to work.
	/// Recommended that you simplify the result before exporting to avoid redundant information
	static Export			= function()
	{

	show_message("Warning : You must replace an already existing path in your Game Maker project")

	var file;
	file = get_save_filename("*.yy", "path");
	if (file != "")
	{
		var _path = path ,
		 _closed = path_get_closed(_path)? "\"closed\":true," :"\"closed\":false,",
		 _kind = "\"kind\":" + string(path_get_kind(_path)) + ",",
		 _precision = "\"precision\":" + string(path_get_precision(_path)) + ",",
		 _stringy = json_stringify(cache),
		_name = filename_name(file) 
		_name = string_delete(_name , string_length(_name)-2,3) 
		var _pre = "{ \"$GMPath\":\"\",  \"%Name\":\"" +_name + "\"," +_closed + _kind + _precision + "  \"name\":\"" +_name + "\"," +  "\"parent\":{    \"name\":\"Paths\",    \"path\":\"folders/Paths.yy\",  },\"points\":"
		var _post = ", \"resourceType\":\"GMPath\",  \"resourceVersion\":\"2.0\",}"
		_stringy = string_concat(_pre,_stringy,_post)
		var _buff = buffer_create(string_byte_length(_stringy), buffer_fixed, 1);
	
		buffer_write(_buff, buffer_text, _stringy);
		buffer_save(_buff, file);
		buffer_delete(_buff);
	}
}
	#endregion

	static _regen			= function()
	{
	 switch(type){
			case PATHPLUS.LINEAR:

			// Cycle through all points in array
			for(var _i= 1; _i < l; _i++)
			{			
				polyline[_i-1].transversal		= point_direction(polyline[_i-1].x,polyline[_i-1].y,polyline[_i].x,polyline[_i].y)
				polyline[_i-1].normal			= polyline[_i-1].transversal + 90
			}	
			if closed
			{
				polyline[l-1].transversal		= point_direction(polyline[l-1].x,polyline[l-1].y,polyline[0].x,polyline[0].y)
				polyline[l-1].normal			= polyline[l-1].transversal + 90
			}
			else
			{
				polyline[l-1].transversal		= polyline[_i-1].transversal
				polyline[l-1].normal			= polyline[_i-1].normal
			}
			
			break
			case PATHPLUS.CATMULL_ROM:
					__catmull_rom_set()
			break
			case PATHPLUS.BEZIER:
					__bezier_set()
			break
		}	
	}
	
	static Reset			= function()
	{
		polyline	= [];
		cache		= [];
		l			=	0
		pixel_length =	0
		path_clear_points(path)
		_properties = {}
		_cache_gen  =	false
		_length_gen = false
	}
	
	static Destroy			=function()
	{
		path_delete(path)
	}
	/// Draws either a path, a polyline or its cached version.
	/// @param {Real}   _x		Drawing offset
	/// @param {Real}   _y		Drawing offset
	/// @param {Bool}   _abs	Whether to draw from the absolute or relative position
	/// @param {Bool}   _points Whether to draw control points or not
	/// @param {Bool}  _path	Whether to draw the path element or the polyline/cache element
	/// @param {Bool}  _force_poly	Whether to display the interpolated line(false) or base polyline (true)
	static DebugDraw		= function(_x=0,_y=0,_abs=true,_points=false,_path=false,_force_poly=false)
	{
		if _path
		{
			draw_path(path,_x,_y,_abs)
			return
		}
		// If type is linear or we are forcing polyline, assign the polyline array, otherwise draw from cache
		var _lines =  _force_poly || !_cache_gen ? polyline : cache  
		
		if !_abs
		{
			_x = _x -_lines[0].x
			_y = _y -_lines[0].y
		}
		
		var _c1 = draw_get_color()
		var _len = array_length(_lines)
		
		for(var _i=0; _i<_len;_i++)
		{
			draw_set_color(PP_COLOR_LINE)
			if closed && _i + 1 == _len
			{
				draw_line(_x+_lines[_i].x,_y+_lines[_i].y,_x+_lines[0].x,_y+_lines[0].y)
			}
			else if _i + 1 < _len
			{
				draw_line(_x+_lines[_i].x,_y+_lines[_i].y,_x+_lines[_i+1].x,_y+_lines[_i+1].y)
			}
			if _points
			{
				if PP_SHOW_DEBUG_PT_NUMBER draw_text(_x+_lines[_i].x+10,_y+10+_lines[_i].y,$"{_i}")
				draw_set_color(PP_COLOR_INTR)
				draw_circle(_x+_lines[_i].x,_y+_lines[_i].y,max(PP_SHOW_DEBUG_PT_SIZE /2,1) ,false)
				draw_set_color(PP_COLOR_NORMAL)

				if PP_SHOW_DEBUG_NORMALS
				{	// get normal and extend from x, and draw it
					var x1 = _x+_lines[_i].x+lengthdir_x(15,_lines[_i].normal)
					var y1 =_y+_lines[_i].y+lengthdir_y(15,_lines[_i].normal)
					var x2 = _x+_lines[_i].x
					var y2 =_y+_lines[_i].y
					draw_arrow(x2,y2,x1,y1,6)
				}

			}
		}
		if _points
		{
			var _lines = polyline

			for(var _i=0; _i<array_length(_lines);_i++)
			{
				var _col = !PP_SHOW_DEBUG_SPEEDS ? PP_COLOR_PT : merge_color(PP_COLOR_PT,PP_COLOR_PT_SPEED,(_lines[_i].speed/100))
				draw_set_color(_col)
				draw_circle(_x+_lines[_i].x,_y+_lines[_i].y,PP_SHOW_DEBUG_PT_SIZE,false)
			}
			if type == PATHPLUS.BEZIER 
			{
				draw_set_color(PP_COLOR_BEZ)
				for(var _i=0; _i<array_length(_lines);_i++)
				{
					if _lines[_i][$"h1"] != undefined
					{
						draw_circle(_x+_lines[_i].h1.x,_y+_lines[_i].h1.y,2,false)
						draw_line(_x+_lines[_i].h1.x,_y+_lines[_i].h1.y,_x+_lines[_i].x,_y+_lines[_i].y)
					}
					if _lines[_i][$"h2"] != undefined
					{
						draw_circle(_x+_lines[_i].h2.x,_y+_lines[_i].h2.y,2,false)
						draw_line(_x+_lines[_i].h2.x,_y+_lines[_i].h2.y,_x+_lines[_i].x,_y+_lines[_i].y)
					}
				}	
			}

		}
		draw_set_color(_c1)
	}

	#region Catmull-Rom
		static SetCatmullRom = function(_alpha=.5,_tension=.5)
		{
			if l <=2
			{
				type		= PATHPLUS.LINEAR
				return
			}
			_alpha		= clamp(_alpha,0,1)
			_tension	= clamp(_tension,0,1)
			_properties = {alpha : _alpha , tension : _tension}
			type		= PATHPLUS.CATMULL_ROM
			cache= []
			_cache_gen = false
			_length_gen = false
			__catmull_rom_set()
			GenerateCache()
		}
			static  __catmull_rom_set = function(_start = 0 , _end = l)
		{
			if l <=2
			{
				// Prevents crashing if there are not enough points to make a curve
				type		= PATHPLUS.LINEAR
				return
			}
			
			var _alpha		= _properties.alpha,
				_tension	= _properties.tension
				
			if _start < 0
			{
				 _start = closed ? l-_start : 0
			}
			if _end == l
			{
				var _length = closed ? l : l-1
			}
			else
			{
				var _length = _end
			}

			//Go through points and generate the coefficients for each segment
			for (var _i= _start; _i < _length; _i++)
			{ 
				var _p1= undefined , _p2 , _p3, _p4 = undefined;
			
				if _i==0 // if first point, create a phantom previous point OR pick the last point
				{
					if closed
					{
						_p1 = polyline[_length-1]
					}
					else
					{
						var _dir = point_direction(polyline[1].x,polyline[1].y,polyline[0].x,polyline[0].y) 
						var _len = 1
						_p1 =
						{
							x: lengthdir_x(_len,_dir)+polyline[0].x,
							y: lengthdir_y(_len,_dir)+polyline[0].y
						}

						
					}
				}
				else if _i == _length-1 && !closed // if second to last point and its open, create a phantom fourth point 
				{
					var _dir = point_direction(polyline[_i].x,polyline[_i].y,polyline[_i+1].x,polyline[_i+1].y)
					var _len = 1
					_p4 =
					{
						x: lengthdir_x(_len,_dir)+polyline[_i+1].x,
						y: lengthdir_y(_len,_dir)+polyline[_i+1].y
					}

				}
		
			_p1 ??= polyline[_i-1] ;
			_p2 = polyline[_i];
			if closed{
				_p3 = polyline[(_i+1)%_length];
				_p4 ??= polyline[(_i+2)%_length];
			}
			else
			{
				_p3 = polyline[(_i+1)];
				_p4 ??= polyline[(_i+2)];
			}
				polyline[_i].segment = __catmull_rom_coef(_p1,_p2,_p3,_p4,_alpha,_tension)
			}
		}
			/// Based off Mika Rantanen implementation
			/// https://qroph.github.io/2018/07/30/smooth-paths-using-catmull-rom-splines.html
			static	__catmull_rom_coef = function(p0,p1,p2,p3,alpha=1,tension=0)
		{
			var
			 t01 = power(point_distance(p0.x,p0.y, p1.x,p1.y), alpha),
			 t12 = power(point_distance(p1.x,p1.y, p2.x,p2.y), alpha),
			 t23 = power(point_distance(p2.x,p2.y, p3.x,p3.y), alpha),
			m1={},m2={},segment={};
			segment.a={};segment.b={};segment.c={};segment.d={};

			m1.x = (1.0 - tension) *
			    (p2.x - p1.x + t12 * ((p1.x - p0.x) / t01 - (p2.x - p0.x) / (t01 + t12)));
			m2.x = (1.0 - tension) *
			    (p2.x - p1.x + t12 * ((p3.x - p2.x) / t23 - (p3.x - p1.x) / (t12 + t23)));
	
			m1.y = (1.0 - tension) *
			    (p2.y - p1.y + t12 * ((p1.y - p0.y) / t01 - (p2.y - p0.y) / (t01 + t12)));
			m2.y = (1.0 - tension) *
			    (p2.y - p1.y + t12 * ((p3.y - p2.y) / t23 - (p3.y - p1.y) / (t12 + t23)));

			segment.a.x = 2.0 * (p1.x - p2.x) + m1.x + m2.x;
			segment.b.x = -3.0 * (p1.x - p2.x) - m1.x - m1.x - m2.x;
			segment.c.x = m1.x;
			segment.d.x = p1.x;

			segment.a.y = 2.0 * (p1.y - p2.y) + m1.y + m2.y;
			segment.b.y = -3.0 * (p1.y - p2.y) - m1.y - m1.y - m2.y;
			segment.c.y = m1.y;
			segment.d.y = p1.y;

			return segment
		}
			static  __catmull_rom_point = function(segment,t)
		{
			var point = {},
			_2t = t*t,
			_3t= t*_2t
	
			point.x = segment.a.x * _3t +
		              segment.b.x * _2t +
		              segment.c.x * t +
		              segment.d.x;	
			point.y = segment.a.y * _3t +
		              segment.b.y * _2t +
		              segment.c.y * t +
		              segment.d.y;	
		var _x = 3 * segment.a.x * _2t + 2 * segment.b.x * t + segment.c.x;
		var _y = 3 * segment.a.y * _2t  + 2 * segment.b.y * t + segment.c.y;
	
		point.transversal = point_direction(0,0,_x,_y)
		point.normal =   point.transversal +90
			return point
		}
	#endregion
	
	#region Bezier
	static SetBezier = function()
		{
			type = PATHPLUS.BEZIER
			var _size = closed ? l*precision : ((l-1)*precision)+1
			cache= array_create(_size,0)
			__bezier_set(0,l)
			_cache_gen = false
			_length_gen = false
			
			GenerateCache()
			
			return self
		}
		static  __bezier_set	  = function(_start = 0 ,  _end = l)
		{
			if _end == l
			{
				var _length = closed ? l : l-1
			}
			else
			{
				var _length = _end % l
			}
			
			//Go through points and generate the tangents for each point
			for (var _i= _start; _i < _length; _i++)
			{ 
			
				var _p1= undefined , _p2 , _p3, _p4 = undefined;
			
				if _i==0 // if first point, create a phantom previous point OR pick the last point
				{
					if closed
					{
						_p1 = polyline[_length-1]
					}
					else
					{
						var _dir = point_direction(polyline[0].x,polyline[0].y,polyline[1].x,polyline[1].y)+180
						var _len = point_distance(polyline[0].x,polyline[0].y,polyline[1].x,polyline[1].y)
						_p1 =
						{
							x: lengthdir_x(_len,_dir)+polyline[0].x,
							y: lengthdir_y(_len,_dir)+polyline[0].y
						}
					}
				}
				else if _i == _length-1 && !closed // if last point, create a phantom next point OR pick the first point
				{
					var _dir = point_direction(polyline[_i].x,polyline[_i].y,polyline[_i+1].x,polyline[_i+1].y)
					var _len = point_distance(polyline[_i].x,polyline[_i].y,polyline[_i+1].x,polyline[_i+1].y)
					_p4 =
					{
						x: lengthdir_x(_len,_dir)+polyline[_i+1].x,
						y: lengthdir_y(_len,_dir)+polyline[_i+1].y
					}
				}
		
				_p1 ??= polyline[_i-1] ;
				_p2 = polyline[_i];
				_p3 = polyline[(_i+1)%l];
				_p4 ??= polyline[(_i+2)%l];
		
				var _tangents= __bezier_tangents(_p1,_p2,_p3,_p4)
				_p2[$ "h1"] ??= _tangents[0]
				_p3[$ "h2"] ??= _tangents[1]
				

			}
		}
		static  __bezier_set_single	  = function(_n)
		{
			var _i = _n
			if _n-1 >= 0
			{
				_i --
				var _p1= undefined , _p2 , _p3, _p4 = undefined;
			
				if _i==0 // if first point, create a phantom previous point OR pick the last point
				{
					if closed
					{
						_p1 = polyline[l-1]
					}
					else
					{
						var _dir = point_direction(polyline[0].x,polyline[0].y,polyline[1].x,polyline[1].y)+180
						var _len = point_distance(polyline[0].x,polyline[0].y,polyline[1].x,polyline[1].y)
						_p1 =
						{
							x: lengthdir_x(_len,_dir)+polyline[0].x,
							y: lengthdir_y(_len,_dir)+polyline[0].y
						}
					}
				}
				else if _i == l-1 && !closed // if last point, create a phantom next point OR pick the first point
				{
					var _dir = point_direction(polyline[_i].x,polyline[_i].y,polyline[_i+1].x,polyline[_i+1].y)
					var _len = point_distance(polyline[_i].x,polyline[_i].y,polyline[_i+1].x,polyline[_i+1].y)
					_p4 =
					{
						x: lengthdir_x(_len,_dir)+polyline[_i+1].x,
						y: lengthdir_y(_len,_dir)+polyline[_i+1].y
					}
				}
		
				_p1 ??= polyline[_i-1] ;
				_p2 = polyline[_i];
				_p3 = polyline[(_i+1)%l];
				_p4 ??= polyline[(_i+2)%l];
		
				var _tangents= __bezier_tangents(_p1,_p2,_p3,_p4)
				_p3.h2 = _tangents[1]
				_p2.cached = false
				_i++
			}
			if _n +1 < l
			{
				var _p1= undefined , _p2 , _p3, _p4 = undefined;
			
				if _i==0 // if first point, create a phantom previous point OR pick the last point
				{
					if closed
					{
						_p1 = polyline[l-1]
					}
					else
					{
						var _dir = point_direction(polyline[0].x,polyline[0].y,polyline[1].x,polyline[1].y)+180
						var _len = point_distance(polyline[0].x,polyline[0].y,polyline[1].x,polyline[1].y)
						_p1 =
						{
							x: lengthdir_x(_len,_dir)+polyline[0].x,
							y: lengthdir_y(_len,_dir)+polyline[0].y
						}
					}
				}
				else if _i == l-1 && !closed // if last point, create a phantom next point OR pick the first point
				{
					var _dir = point_direction(polyline[_i].x,polyline[_i].y,polyline[_i+1].x,polyline[_i+1].y)
					var _len = point_distance(polyline[_i].x,polyline[_i].y,polyline[_i+1].x,polyline[_i+1].y)
					_p4 =
					{
						x: lengthdir_x(_len,_dir)+polyline[_i+1].x,
						y: lengthdir_y(_len,_dir)+polyline[_i+1].y
					}
				}
		
				_p1 ??= polyline[_i-1] ;
				_p2 = polyline[_i];
				_p3 = polyline[(_i+1)%l];
				_p4 ??= polyline[(_i+2)%l];
		
				var _tangents= __bezier_tangents(_p1,_p2,_p3,_p4)
				_p2.h1 = _tangents[0]
				_p2.cached = false
			}
			
			
		}
		static	__bezier_tangents = function(p0,p1,p2,p3)
		{
			var
			 t01 = point_distance(p0.x,p0.y, p1.x,p1.y),
			 t12 = point_distance(p1.x,p1.y, p2.x,p2.y),
			 t23 = point_distance(p2.x,p2.y, p3.x,p3.y),
			h1={},h2={}

			h1.x = p1.x+(p2.x - p1.x + t12 * ((p1.x - p0.x) / t01 - (p2.x - p0.x) / (t01 + t12)))*.33;
			h2.x = p2.x-(p2.x - p1.x + t12 * ((p3.x - p2.x) / t23 - (p3.x - p1.x) / (t12 + t23)))*.33;
	
			h1.y =  p1.y+(p2.y - p1.y + t12 * ((p1.y - p0.y) / t01 - (p2.y - p0.y) / (t01 + t12)))*.33;
			h2.y =  p2.y-(p2.y - p1.y + t12 * ((p3.y - p2.y) / t23 - (p3.y - p1.y) / (t12 + t23)))*.33;


			return [h1,h2]
		}
		static  __bezier_point = function(p1,p2,t)
		{
			if p1[$ "h1"]  == undefined || p2[$ "h2"] == undefined
			{
				p1.transversal = 0
				p1.normal = -90
				return p1
			}
			var point = {},
			_2t = t*t,
			_3t= t*_2t
	
			var mt = 1 - t;
			var mt2 = mt * mt;
			var mt3 = mt2 * mt;

			point.x = (p1.x * mt3) + (3 * p1.h1.x * mt2 * t) + 3 * (p2.h2.x * mt * _2t) + (p2.x * _3t);
			point.y = (p1.y * mt3) + (3 * p1.h1.y * mt2 * t) + 3 * (p2.h2.y * mt * _2t) + (p2.y * _3t);
			
			if t==0
			{
				t=-0.0001
				_2t = t*t
				_3t= t*_2t
				mt = 1 - t
				mt2 = mt * mt
				mt3 = mt2 * mt
			}
			
			var  _tan_x = (p1.x * mt2 ) + (2 * p1.h1.x * mt * t ) + (p2.h2.x * _2t)
			var  _tan_y = (p1.y * mt2 ) + (2 * p1.h1.y * mt * t ) + (p2.h2.y * _2t)
			
			point.transversal = point_direction(_tan_x,_tan_y,point.x,point.y)
			point.normal =   point.transversal +90
			  
			return point
		}	
	#endregion

}

/**
 * Private function used by PathPlus
  */
function __simplify_step(_points,_epsilon,_start,_end)
{
		var _maxDist = -1
		var _maxIndex = -1

		var point_list = array_create(array_length(_points))
		
	point_list[_start]=_points[_start]
	point_list[_end]=_points[_end]

		// Go through all points to find the point that is furthest from the line between A and B
		for(var _i = _start ; _i< _end ;_i++)
		{
			var _d = pointToLineDistance(	_points[_i].x		,_points[_i].y,
											_points[_start].x	,_points[_start].y,
											_points[_end].x	,_points[_end].y)
			if _d > _maxDist
			{
				  _maxDist =	_d
				 _maxIndex = _i
				 var _x = _points[_i].x ,	
				 _y = _points[_i].y
			}
		}

		// If the point is further than epsilon, add it to the collection and try again between left and right sides of the point
	    if (_maxDist > _epsilon)
		{
			point_list[_maxIndex]=_points[_maxIndex]

	        if (_maxIndex - _start > 1)
			{
				point_list = _array_merge(point_list, __simplify_step(_points,_epsilon,_start,_maxIndex))//recursion from start to index
			}
	        if (_end - _maxIndex > 1)
			{
				point_list = _array_merge(point_list,__simplify_step(_points,_epsilon,_maxIndex,_end))// recursion from index to end
			}
	    }
		return  point_list
	}

/**
 * Given a line XY1->XY2 and a Point XY3, find the distance from the point to the line.
 */
function pointToLineDistance(x1,y1,x2,y2,x3,y3){
	static vector_length = function(_vec)
	{
		return sqrt(sqr(_vec[0])+sqr(_vec[1]))
	}
// dot product of normalized AB and AP. AB being the original line and AP the vector from point A to the point we want to know.
// this is the projection on AB of the distance to point P

//define AB vector
var _ABvec = [(x3-x2),(y3-y2)]

// define AP vector
var _APvec = [(x1-x2),(y1-y2)]

var _ABlength = vector_length(_ABvec)
var _APlength = vector_length(_APvec)
		
_ABvec = [_ABvec[0]/_ABlength,_ABvec[1]/_ABlength]

var _l = dot_product(_APvec[0],_APvec[1],_ABvec[0],_ABvec[1])
	
return sqrt(sqr(_APlength)-sqr(_l))
};

/// @desc Merges two arrays
function _array_merge(array1,array2)
{
	var l = array_length(array1)
	
	var _new_array = array1 //array_create(l)
	
	for(var _i = 0 ; _i < l ; _i++ )
	{
		if (array1[_i] == 0 && array2[_i] != 0) 
		{
			_new_array[_i] = array2[_i]
		}
	}
	
	return _new_array
}

/// @desc removes empty positions from an array
function _array_clean(array)
{
	var l = array_length(array)
	
	var _new_array = array_create()
	
	for(var _i = 0 ; _i < l ; _i++ )
	{
		if array[_i] != 0 
		{
			array_push(_new_array,array[_i])	
		}
	}
	
	return _new_array
}
