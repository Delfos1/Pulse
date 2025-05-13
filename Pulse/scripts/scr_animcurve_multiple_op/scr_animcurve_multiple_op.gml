//feather ignore all
/**
 * Merges two sets of animation curve points, where all points are mantained as-is unless they overlap. Returns an array of points
 * @param {Array} _pointsa 
 * @param {Array} _pointsb 
 * @param {Boolean} _a_over_b Whether the first set has priority over the second if there are overlapping points
 * @return {Array}
 */
function animcurve_points_merge(_pointsa,_pointsb,_a_over_b=true)
{
	var _temp = _pointsa //new animcurve_point_collection(pointsa) 
	
	var _i = 0
	repeat(array_length(_pointsb))
	{
		animcurve_point_add(_temp,_pointsb[_i].posx,_pointsb[_i].value,_a_over_b)
		_i++
	}
	
	return _temp
}

/**
 * Intersects two animation curve channels. Returns an array representing the overlap on the positive side.
 * @param {Array , Struct} pointsa 
 * @param {Array , Struct} pointsb 
 * @return {Array}
 */
function animcurve_points_intersect(channel_a,channel_b)
{
	var pointsa = channel_a.points
	var pointsb = channel_b.points
	var _temp	= []
	var length_a= array_length( channel_a.points)-1
	var length_b= array_length( channel_b.points)-1
	var length	= max(length_a,length_b)
	
	var i = 0
	var j = 0
	
	repeat(length+1)
	{
		var _x, _val;
		
		if pointsa[i].posx < pointsb[j].posx
		{
			_x		= pointsa[i].posx
			_val	= animcurve_channel_evaluate(channel_b,_x)
					
			if  pointsa[i].value <= _val
			{
				_val	= pointsa[i].value
			}
		}
		else if pointsa[i].posx > pointsb[j].posx
		{
			_x		= pointsb[j].posx
			_val	= animcurve_channel_evaluate(channel_a,_x)
			
			if  pointsb[i].value <= _val
			{
				_val	= pointsb[i].value
			}
		}
		else 
		{
			_x		= pointsb[j].posx
			
			if  pointsa[i].value <= pointsb[j].value
			{
				_val	= pointsa[i].value
			}
			else
			{
				_val	= pointsb[j].value
			}
		}
		
		animcurve_point_add(_temp,_x,_val)
		
		i = i<length_a ? i+1 : i
		j = j<length_b ? j+1 : j
	}
	
	return _temp
}
/**
 * The values from two channels are added from eachother. Returns an array of points
 * @param { Struct} channel_a 
 * @param { Struct} channel_b 
 * @return {Array}
 */
function animcurve_points_additive(_channel_a,_channel_b)
{
	var _pointsa = _channel_a.points
	var _pointsb = _channel_b.points
	var _temp	 = []
	var _length_a= array_length(_channel_a.points)
	var _length_b= array_length(_channel_b.points)
	var _length  = max(_length_a,_length_b)
	
	var _i = 0
	var _j = 0
	
	repeat(_length)
	{
		var _x, _val;
			
		if _pointsa[_i].posx < _pointsb[_j].posx
		{
			_x		= _pointsa[_i].posx
			_val	= _pointsa[_i].value + animcurve_channel_evaluate(_channel_b,_x)
		}
		else if _pointsa[_i].posx > _pointsb[_j].posx
		{
			_x		= _pointsb[_j].posx
			_val	= animcurve_channel_evaluate(_channel_a,_x) + _pointsb[_j].value
		}
		else 
		{
			_x		= _pointsb[_j].posx
			_val	= _pointsa[_i].value + _pointsb[_j].value
		}
		
		animcurve_point_add(_temp,_x,_val)
		
		_i = _i<_length_a-1 ? _i+1 : _i
		_j = _j<_length_b-1 ? _j+1 : _j
	}
	
	return _temp
}
/**
 * The values from two channels are substracted from eachother. Returns an array of points
 * @param { Struct} channel_a 
 * @param { Struct} channel_b 
 * @return {Array}
 */
function animcurve_points_substract(channel_a,channel_b)
{
	var pointsa = channel_a.points
	var pointsb = channel_b.points
	var _temp	= []
	var length_a= array_length( channel_a.points)
	var length_b= array_length( channel_b.points)
	var length	= max(length_a,length_b)
	
	var i = 0
	var j = 0
	
	repeat(length)
	{
		var _x, _val;
		
	
		if pointsa[i].posx < pointsb[j].posx
		{
			_x		= pointsa[i].posx
			_val	= pointsa[i].value - animcurve_channel_evaluate(channel_b,_x)

		}
		else if pointsa[i].posx > pointsb[j].posx
		{
			_x		= pointsb[j].posx
			_val	= animcurve_channel_evaluate(channel_a,_x) - pointsb[j].value

		}
		else 
		{
			_x		= pointsb[j].posx
			_val	= pointsa[i].value - pointsb[j].value
		}
		
		animcurve_point_add(_temp,_x,_val)
		
		i = i<length_a-1 ? i+1 : i
		j = j<length_b-1 ? j+1 : j
	}
	
	return _temp
}
/**
 * Mixes two animation curve channels, lerping between them. Returns an array of points
 * @param { Struct} channel_a 
 * @param {Struct} channel_b
 * @param {Real} _mix Amount of mix from A to B
 * @return {Array}
 */
function animcurve_points_mix(channel_a,channel_b,_mix = .5)
{
	var pointsa = channel_a.points
	var pointsb = channel_b.points
	var _temp	= []
	var length_a= array_length( channel_a.points)
	var length_b= array_length( channel_b.points)
	var length	= max(length_a,length_b)
	
	var i = 0
	var j = 0
	
	repeat(length+1)
	{
		var _x, _val;

		if pointsa[i].posx < pointsb[j].posx
		{
			_x		= pointsa[i].posx
		}
		else 
		{
			_x		= pointsb[j].posx
		}
		
		_val	= lerp(animcurve_channel_evaluate(channel_a,_x),animcurve_channel_evaluate(channel_b,_x),_mix)
		
		animcurve_point_add(_temp,_x,_val)
		
		i = i<length_a-1 ? i+1 : i
		j = j<length_b-1 ? j+1 : j
	}
	
	return _temp
}
