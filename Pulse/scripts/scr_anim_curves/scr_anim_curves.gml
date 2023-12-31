/**
 * test whether or not a channel exists within an animation curve
 * @param {asset.GMAnimCurve} curve the animation curve to check
 * @param {any} channel the channel index or name to evaluate
 * @return {bool}
 * By attic-stuff
 */
function animcurve_channel_exists(curve, channel) {
	var data = animcurve_get(curve);
	if (is_real(channel) == true) {
		return channel < array_length(data.channels);
	}
	if (is_string(channel) == true) {
		var index = array_find_index(data.channels, method({channel:channel}, function(value) {
			return value.name == channel;
		}));
		return index > -1 ? true : false;
	}
	return false;
}

/**
 * copy a channel from one curve asset to another
 * @param {asset.GMAnimCurve} curve_src the animation curve to copy from
 * @param {String , Real} channel_src the channel index or name to copy from
 * @param {asset.GMAnimCurve} curve_dest the animation curve to copy to
 * @param {String , Real} channel_dest name for the destination channel. By default is the same as the source
 * @return {bool}
 */
function animcurve_channel_copy(curve_src, channel_src,curve_dst,channel_dst,_rename = true) 
{
	var _source,_dest,_index,_name,_curve_dest;
	_source = animcurve_get_channel(curve_src, channel_src)
	
	_curve_dest = animcurve_get(curve_dst)
	
	// If destination doesn't exist, create it
	if !animcurve_channel_exists(curve_dst, channel_dst)
	{
		_dest = animcurve_channel_new();
		_index = array_length(_curve_dest.channels)
		
		if is_string(channel_dst)
		{
			_name = channel_dst
		}
		else
		{
			_name	=	string_concat(_source.name,"_copy")
		}
	}
	else
	{
		_dest = animcurve_get_channel(curve_dst, channel_dst)

		if is_string(channel_dst)
		{
			_name = channel_dst
			_index = animcurve_get_channel_index(curve_dst, channel_dst)
		}
		else
		{
			if _rename
			{
				_name	= string_concat(_source.name,"_copy")
			}
			else
			{
				_name	= _dest.name
			}
			_index = channel_dst
		}
	}

	_dest.name =		_name;
	_dest.type =		_source.type
	_dest.iterations =	_source.iterations
	_dest.points=		_source.points
	
	var _new_channels = _curve_dest.channels
	_new_channels[_index]=_dest
	
	_curve_dest.channels=_new_channels
	
	return true
}
/**
 * struct that helps to build correctly formatted points for animation curves
 * @param {Array} points You can supply a set of points extracted from an animation curve channel
 * @return {Struct}
 */
function animcurve_point_collection(points = []) constructor
{
	collection	= points
	length		= array_length(collection)
	
	static __make_point = function(index,posx,value)
	{
		var point			= animcurve_point_new()
		point.posx	= posx
		point.value	= value
		
		array_insert(collection, index, point)
	}
	
	static new_point = function(posx,value,replace=false)
	{
		if length == 0
		{
			__make_point(0,posx,value)
			length += 1
		}
		else if collection[length-1].posx < posx
		{
			__make_point(length-1,posx,value)
			length += 1
		}
		else
		{
			var _i =0
			repeat (length+1)
			{
				if _i == length
				{
					__make_point(_i,posx,value)
					length += 1
					break
				}

				if collection[_i].posx < posx
				{
					_i += 1
				}
				else if collection[_i].posx == posx 
				{
					if replace
					{
						array_delete(collection,_i,1)
						__make_point(_i,posx,value)
					}
					break
				}
				else if collection[_i].posx > posx
				{
					__make_point(_i,posx,value)
					length += 1
				}
			}
	
		return self
		}
	}
	static remove_point = function(posx)
	{
		var _i = 0
		repeat(length)
		{
			if collection[_i].posx == posx
			{
				array_delete(collection,_i,1)
				length -=1
				break
			}
		}
		return self
	}
	static export = function()
	{
		return collection
	}

}

/**
 * replaces the points in an already existing channel
 * @param {asset.GMAnimCurve} curve_src the animation curve
 * @param {String , Real} channel_src the channel index or name to replace
 * @param {Array , Struct} new_points An array of animation curve points
 */
function animcurve_points_set(curve, channel, new_points) 
{
	var dest= animcurve_get_channel(curve, channel)

	dest.points = new_points
	
	return
}

/**
 * Merges two sets of animation curve points
 * @param {Array , Struct} pointsa 
 * @param {Array , Struct} pointsb 
 * @param {Boolean} a_over_b Whether the first set has priority over the second if there are overlapping points
 */
function animcurve_points_merge(pointsa,pointsb,a_over_b=true)
{
	var _temp = new animcurve_point_collection(pointsa) 
	
	var i = 0
	repeat(array_length(pointsb))
	{
		_temp.new_point(pointsb[i].posx,pointsb[i].value,a_over_b)
		i++
	}
	
	return _temp.export()
}

function animcurve_points_intersect(channel_a,channel_b)
{
	var pointsa = channel_a.points
	var pointsb = channel_b.points
	var _temp	= new animcurve_point_collection()
	var length_a= array_length( channel_a.points)-1
	var length_b= array_length( channel_b.points)-1
	var length	= max(length_a,length_b)
	
	var i = 0
	var j = 0
	
	repeat(length)
	{
		var _x, _val;
		
		i = i<length_a ? i+1 : i
		j = j<length_b ? j+1 : j
		
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
		
		_temp.new_point(_x,_val)
	}
	
	return _temp.export()
}

function animcurve_points_additive(channel_a,channel_b)
{
	var pointsa = channel_a.points
	var pointsb = channel_b.points
	var _temp	= new animcurve_point_collection()
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
			_val	= pointsa[i].value + animcurve_channel_evaluate(channel_b,_x)

		}
		else if pointsa[i].posx > pointsb[j].posx
		{
			_x		= pointsb[j].posx
			_val	= animcurve_channel_evaluate(channel_a,_x) + pointsb[j].value

		}
		else 
		{
			_x		= pointsb[j].posx
			_val	= pointsa[i].value + pointsb[j].value
		}
		
		_temp.new_point(_x,_val)
		
		i = i<length_a-1 ? i+1 : i
		j = j<length_b-1 ? j+1 : j
	}
	
	return _temp.export()
}

function animcurve_points_substract(channel_a,channel_b)
{
	var pointsa = channel_a.points
	var pointsb = channel_b.points
	var _temp	= new animcurve_point_collection()
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
		
		_temp.new_point(_x,_val)
		
		i = i<length_a-1 ? i+1 : i
		j = j<length_b-1 ? j+1 : j
	}
	
	return _temp.export()
}

function animcurve_points_mix(channel_a,channel_b,_mix = .5)
{
	var pointsa = channel_a.points
	var pointsb = channel_b.points
	var _temp	= new animcurve_point_collection()
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
		}
		else 
		{
			_x		= pointsb[j].posx
		}
		
		_val	= lerp(animcurve_channel_evaluate(channel_a,_x),animcurve_channel_evaluate(channel_b,_x),_mix)
		
		_temp.new_point(_x,_val)
		
		i = i<length_a-1 ? i+1 : i
		j = j<length_b-1 ? j+1 : j
	}
	
	return _temp.export()
}

function animcurve_points_normalize(points)
{
	var i = 0,
	_min = points[0].value,
	_max = points[0].value
	
	repeat(array_length(points))
	{
		if points[i].value > _max
		{
			_max = points[i].value
		} else if points[i].value < _min
		{	
			_min = points[i].value
		}
		i +=1
	}
	_min *= -1
	var _d = 1/(_max + _min)
	
	i=0
	repeat(array_length(points)-1)
	{
		points[i].value += _min
		points[i].value *= _d
		i +=1
	}
	
	return points
}

function animcurve_points_find_closest(points,posx, above=  false)
{
			var length= array_length(points)
			var _min = 0,
			_max	= length,
			_guess	= 0

			while (_min < _max)
			{
				_guess = floor((_max + _min)/2);
					
				if _guess+1	== length 
				break

					
				 if points[_guess].posx == posx || points[_guess].posx < posx && points[_guess+1].posx > posx
				{
					if (points[_guess].posx + points[_guess+1].posx )/2 < posx
					_guess +=1;

					break
				}
				else if points[_guess].posx > posx
				{
					_max	= _guess;
				} else _min = _guess+1;
				
			}
	
	/*
	var length= array_length(points)
	
		var _min = 0,
		_max	= 1,
		_middle	= 0,
		_guess	= 0,
		_index	= 0,
		_len	= ceil(log2(length)) ;

		repeat(_len)
		{
			_middle = _min + (_max - _min) * 0.5;
			_guess = floor(length * _middle);
					
			if _guess < length 
			{
				if points[_guess].posx == position
				{
					break
				}
				else if points[_guess].posx < position && points[_guess+1].posx > position
				{
					if (points[_guess].posx + points[_guess+1].posx )/2 < position
					_guess +=1;
					break
				}
				else if points[_guess].posx > position
				{
					_max	= _middle;
				} else _min = _middle;
			}
		}
		*/
		
	return _guess
}

/**
 * add subdivisions to a points array. Returns points array
 * @param {Struct} channel_src the channel struct from animcurve_get_channel()
 * @param {Real} amount of subdivisions
 * @param {Real} _start Start the subdivisions from this x (0 to 1)
 * @param {Real} _end Make subdivisions until this x (0 to 1)
 * @return {bool}
 */
function animcurve_points_subdiv(channel_src, amount,_start=0,_end=1) 
{
	var _incr		= (_end-_start)/amount
	var _points		= new animcurve_point_collection(channel_src.points)
	for(var _pos = _start ; _pos < _end ; _pos += _incr )
	{
		_points.new_point(_pos , animcurve_channel_evaluate(channel_src,_pos))
	}

	return _points.export()
}


/**
 * Checks for the existence of an anim curve without returning error if its not an anim curve asset
 * @param {asset.GMAnimCurve} curve
 * @return {bool}
 */
function animcurve_really_exists(curve)
{
	//if !is_ptr(curve) return false
	if !is_handle(curve) and !is_struct(curve) and !is_ptr(curve) return false
	if !animcurve_exists(curve) return false
	
	return true
}
/**
 * Checks for the existence of an path without returning error if its not an path
 * @param {asset.GMPath} path
 * @return {bool}
 */
function path_really_exists(path)
{
	if !is_handle(path) and !is_ptr(path) and !is_real(path) return false
	if !path_exists(path) return false
	
	return true
}

/**
 * Create a new Animation Curve with everything required for it to work properly. If you supply channels you must supply all elements.
 * @param {Struct} _struct You can supply this information:  curve_name : "string" , channels : [{name:"curve1" , type : animcurvetype_catmullrom , iterations : 8},{name:"curve2" , ... etc}]
 * @return {bool}
 */
function animcurve_really_create(_struct={})
{

	var new_curve = animcurve_create()

	new_curve.name = _struct[$ "curve_name"] ?? "My_Curve";
	
	// Define Channels. If undefined by user, create a single channel
	
	if _struct[$ "channels"] == undefined
	{
		var _channels = array_create(1)
		_channels[0] = animcurve_channel_new();
		_channels[0].name = "curve1";
		_channels[0].type = animcurvetype_catmullrom;
		_channels[0].iterations = 8;
	}
	else
	{
		var _new_channels = _struct[$ "channels"]
		var _channels =	array_create( array_length(_new_channels))
		
		for (var _i = 0 ; _i < array_length(_channels) ; _i++)
		{
			_channels[_i] = animcurve_channel_new();
			_channels[_i].name = _new_channels[_i].name
			_channels[_i].type = _new_channels[_i].type;
			_channels[_i].iterations = _new_channels[_i].iterations;
		}
	}
	
	// Define 2 points at the start and the end of the curve
	var _points = array_create(2);
	_points[0] = animcurve_point_new();
	_points[0].posx = 0;
	_points[0].value = 1;
	_points[1] = animcurve_point_new();
	_points[1].posx = 1;
	_points[1].value = 1;

	var _i =0
	repeat array_length(_channels)
	{
		_channels[_i].points = _points;
		_i++
	}
	new_curve.channels = _channels;	
	
	return new_curve
}


#region jsDoc
/**
 * Returns a bounding box for a path in the form of an array = [x_min, y_min, x_max, y_max]
 * @param {asset.GMPath} _path
 * @param {real} _padding	Padding in pixels for the bbox
 * @param {real} _from	Starting point of the path, from 0 to 1
 * @param {real} _to	Ending point of the path, from 0 to 1
 * @return {array}	
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



/* Binary search (something might be off though
			var _min = 0,
			_max	= length,
			_guess	= 0,

			while _min < _max
			{
				_guess = floor((_max + _min)/2);
					
				if collection[_guess].posx == posx
				{
					if replace
					{
						array_delete(collection,_guess,1)
						__make_point(_guess,posx,value)
					}
					break
				}
				else if collection[_guess].posx < posx && collection[_guess+1].posx > posx
				{
					__make_point(_guess,posx,value)
					length += 1
					break
				}
				else if collection[_guess].posx > posx
				{
					_max	= _guess;
				} else _min = _guess+1;
				
			}
*/