/// Feather ignore all

enum PP_FOLLOW { FORWARD=1, BACKWARD=-1, BOUNCE ,STOP,CYCLE,CONTINUE }

function PathPlusFollower(pathplus,_xrelative = 0,_yrelative = 0) constructor
{
	if !is_instanceof(pathplus,PathPlus) 
	{
		__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: PathPlusFollower requires a PathPlus attached to it.")
	} 
	else
	{
		path = pathplus
	}
	
	x					= 0 
	y					= 0
	x_start				= _xrelative
	y_start				= _yrelative 
	direction			= PP_FOLLOW.FORWARD
	on_end				= PP_FOLLOW.STOP
	location_on_path	= 0
	curr_speed			= path.polyline[0].speed /100
	speed				= 10
	min_speed			= 1
	normal				= path.polyline[0].normal
	transversal			= path.polyline[0].transversal
	
	static SetSpeed = function(_min,_max)
	{
		speed				= _max
		min_speed				= _min
		return self
	}
	
	static SetPosition = function(_n)
	{
		location_on_path = clamp(_n,0,1)
		
		var _point = path.Sample(location_on_path)
		
		curr_speed = _point.speed / 100
		x = x_start + _point.x
		y = y_start + _point.y
		normal = _point.normal
		transversal = _point.transversal
	}
	
	static SetDirection = function(_dir = PP_FOLLOW.FORWARD)
	{
		if _dir != PP_FOLLOW.FORWARD && _dir != PP_FOLLOW.BACKWARD
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")

			return self
		}
		direction = _dir
		
		return self
	}
	
	static SetActionOnEnd = function(_action = PP_FOLLOW.BOUNCE)
	{
		if _action != PP_FOLLOW.BOUNCE && _action != PP_FOLLOW.STOP && _action != PP_FOLLOW.CONTINUE && _action != PP_FOLLOW.CYCLE 
		{
			__pathplus_show_debug("▉╳▉ ✦PathPlus✦ Error ▉╳▉: Wrong type provided")

			return self
		}
		on_end = _action
		
		return self
	}
	
	static StepForward = function(_step_length = 1, _cache = true){
	
		if _cache && !path._cache_gen && PP_AUTO_GEN_CACHE
		{
			path.GenerateCache()
		}
	
		var _spd = lerp(min_speed,speed,curr_speed)
		_step_length = (  _spd / path.pixel_length) * (_step_length*direction)
	
		location_on_path += _step_length

		if ( location_on_path > 1 && direction == PP_FOLLOW.FORWARD) || (location_on_path < 0  && direction == PP_FOLLOW.BACKWARD)
		{
			switch(on_end)
			{
				case PP_FOLLOW.BOUNCE:
					location_on_path = clamp(location_on_path,0,1)
					direction *= -1
					break
				case PP_FOLLOW.STOP:
					{
						location_on_path = clamp(location_on_path,0,1)
						return
					}
				case PP_FOLLOW.CONTINUE:
				
					if !path.closed
					{
						x_start = x 
						y_start = y 
					}
				case PP_FOLLOW.CYCLE:
					location_on_path = direction == PP_FOLLOW.FORWARD ? 0 : 1
					break

			}
		}


		var _point = _cache ? path.SampleFromCache(location_on_path) : path.Sample(location_on_path)
		curr_speed = _point.speed / 100
		x = x_start + _point.x
		y = y_start + _point.y
		normal = _point.normal
		transversal = direction == PP_FOLLOW.FORWARD ? _point.transversal : (_point.transversal+180)%360
		
		return _point
	
	}
	
	static StepBackward = function(_step_length = 1, _cache = true){
	
		_step_length *= -1
		
		return StepForward(_step_length, _cache )
	}
	
	static GenerateACurve = function(_curve_name ,_cache = true)
	{
		var _step_length , 
		_location = direction == PP_FOLLOW.FORWARD ? 0 : 1 ,
		_curr_speed = direction == PP_FOLLOW.FORWARD? path.polyline[0].speed /100 : path.polyline[path.l-1].speed
		
		if _cache && !path._cache_gen && PP_AUTO_GEN_CACHE
		{
			path.GenerateCache()
		}
	
		var content = {
			curve_name : string(_curve_name) , 
			channels : [{name:"x" , type : animcurvetype_linear , iterations : 8},
						{name:"y" , type : animcurvetype_linear , iterations : 8},
						{name:"normal" , type : animcurvetype_linear , iterations : 8},
						{name:"transversal" , type : animcurvetype_linear , iterations : 8}]
		}
	
		var _animcurve = animcurve_really_create(content),
			_points_x_array = [],
			_points_y_array = [],
			_points_normal_array = [],
			_points_transversal_array = []
			
		
		while (_location > 1 && direction == PP_FOLLOW.FORWARD) || (_location < 0  && direction == PP_FOLLOW.BACKWARD)
		{
			_step_length = ( (speed*_curr_speed )/ path.pixel_length) * direction
	
			_location += _step_length
		
			var _point = _cache ? path.SampleFromCache(_location) : path.Sample(_location)
			_curr_speed = _point.speed / 100
			x = x_start + _point.x
			y = y_start + _point.y
			normal = _point.normal
			transversal = direction == PP_FOLLOW.FORWARD ? _point.transversal : (_point.transversal+180)%360
			
			// Add points
			animcurve_point_add(_points_x_array,_location,x)
			animcurve_point_add(_points_y_array,_location,y)
			animcurve_point_add(_points_normal_array,_location,normal)
			animcurve_point_add(_points_transversal_array,_location,transversal)
		}
		
		animcurve_points_set(_animcurve,"x",_points_x_array)
		animcurve_points_set(_animcurve,"y",_points_y_array)
		animcurve_points_set(_animcurve,"normal",_points_normal_array)
		animcurve_points_set(_animcurve,"transversal",_points_transversal_array)
		
		return _animcurve
	}
	
}