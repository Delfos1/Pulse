/**
 * Takes an array of animation curve points and adds a point to it.
 * @param { Array} _point_array The Array of points to be modified
 * @param {Real} _posx The x position of the point
 * @param {Real} _value The y position of the point
 * @param {Bool} _replace Whether to replace a pre-existing point on the x position with the new point or not.
 */
function animcurve_point_add(_point_array,_posx,_value,_replace=false)
{
	var _length = array_length(_point_array)
	
		static __make_point = function(_posx,_value)
		{
			var _point	= animcurve_point_new()
			_point.posx	= _posx
			_point.value	= _value
		
			return _point
		}
		
		
		if _length == 0
		{
			_point_array[0]= __make_point(_posx,_value)
		}
		else
		{
			var _i =0
			repeat (_length+1)
			{
				if _i == _length
				{
					array_insert(_point_array, _i, __make_point(_posx,_value))
					break
				}
				if _point_array[_i].posx < _posx
				{
					_i += 1
				}
				else if _point_array[_i].posx == _posx 
				{
					if _replace
					{
						/*
						array_delete(_point_array,_i,1)
						array_insert(_point_array, _i, __make_point(_posx,_value))
						*/
						_point_array[_i]= __make_point(_posx,_value)
					}
					break
				}
				else if _point_array[_i].posx > _posx
				{
					array_insert(_point_array, _i, __make_point(_posx,_value))
				}
			}
	
		return
		}
	}

/**
 * Takes an array of animation curve points and removes a point from it
 * @param { Array} _point_array The Array of points to be modified
 * @param {Real} _posx The x position of the point
 */
function animcurve_point_remove(_point_array,_posx)
	{
		var _i = 0
		var _length = array_length(_point_array)
		while(_i<_length)
		{
			if _point_array[_i].posx == _posx
			{
				array_delete(_point_array,_i,1)
				_length -=1
				break
			}
			_i ++
		}
	}

/**
 * Takes an array of animation curve points and finds the closest point index to the provided x position. Returns an index
 * @param { Array} _points
 * @param {Real} _posx
 * @return {Real}
 */
function animcurve_point_find_closest(_points,_posx)
{
	var _length= array_length(_points)
	var _min = 0,
	_max	= _length,
	_guess	= 0

	while (_min < _max)
	{
		_guess = floor((_max + _min)/2);
					
		if _guess+1	== _length 
		break
		//  If current point is equal to the value, or the value is between this and the next point
		if _points[_guess].posx == _posx || _points[_guess].posx < _posx && _points[_guess+1].posx > _posx
		{
			if (_points[_guess].posx + _points[_guess+1].posx )/2 > _posx
			{
				// If the value is closer to the next point than the current one
				_guess +=1;
			}
			break
		}
		else if _points[_guess].posx > _posx
		{
			_max	= _guess;
		} else _min = _guess+1;
	}
		
	return _guess
}

/**
 * Takes an array of animation curve points and deletes the point that is closest to the provided x position.
 * @param { Array} _points
 * @param {Real} _posx
 */
function animcurve_point_remove_closest(_points,_posx)
{
	var _i = animcurve_point_remove(_points,_posx)
		
	array_delete(_points,_i,1)	
	return _points
}