#region jsDoc
/**
 * Returns a bounding box for a path in the form of an array = [x_min, y_min, x_max, y_max]
 * @param {asset.GMPath} _path
 * @param {real} _padding	Padding in pixels for the bbox
 * @param {real} _from	Starting point of the path, from 0 to 1
 * @param {real} _to	Ending point of the path, from 0 to 1
 * @return {array(real)}	
 */
#endregion
function path_get_bbox(_path,_padding=0,_from=0,_to=1)
{
	var _points = path_get_number(_path)
	
	_from	= floor(lerp(1,_points,_from))
	_to		= floor(lerp(1,_points,_to))
	
	var _x_array , _x, _y_array , _y
	
	_x_array	= [0,0]
	_x_array[0]	= path_get_x(_path,0)
	_x_array[1]	= _x_array[0]
	for(var _i = 1 + _from ; _i<_to ; _i ++ )
	{
		_x = path_get_point_x(_path,_i)
		
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
	_y_array[0]	= path_get_y(_path,0)
	_y_array[1]	= _y_array[0]
	for(var _i = 1 + _from ; _i<_to ; _i ++ )
	{
		_y = path_get_point_y(_path,_i)
		
		if _y > _y_array[1]
		{
			_y_array[1] = _y
		}
		else if _y < _y_array[0]
		{
			_y_array[0] = _y
		}
	}
	
	var _bbox = [_x_array[0]-_padding,_y_array[0]-_padding,_x_array[1]+_padding,_y_array[1]+_padding]
	
	return _bbox
}