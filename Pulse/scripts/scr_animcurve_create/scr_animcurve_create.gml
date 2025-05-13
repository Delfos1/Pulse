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
 * Checks for the existence of an anim curve without returning error if its not an anim curve asset
 * @param {asset.GMAnimCurve} curve
 * @return {bool}
 */
function animcurve_really_exists(curve)
{
	if !is_handle(curve) and !is_struct(curve) and !is_ptr(curve) return false
	if !animcurve_exists(curve) return false
	
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

/**
 * copy a channel from one curve asset to another
 * @param {asset.GMAnimCurve} curve_src the animation curve to copy from
 * @param {String , Real} channel_src the channel index or name to copy from
 * @param {asset.GMAnimCurve} curve_dst the animation curve to copy to
 * @param {String , Real} channel_dst name for the destination channel. By default is the same as the source
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
 * Replaces the points in an already existing channel
 * @param {asset.GMAnimCurve} _curve the animation curve
 * @param {String , Real} _channel the channel index or name to replace
 * @param {Array} _new_points An array of animation curve points
 */
function animcurve_points_set(_curve, _channel, _new_points) 
{
	var _dest= animcurve_get_channel(_curve, _channel)

	_dest.points = _new_points
	
	return
}

/**
 * Changes the type of a curve
 * @param { Struct } _channel The channel to change as returned by animcurve_get_channel()
 * @param {Constant.AnimCurveInterpolationType} _type		The type one wishes to change the curve to, such as animcurvetype_catmullrom
 * @param {Real} _iterations	The amount of iterations for the curve, which defaults to 0 in the case of linear
 */
function animcurve_change_type(_channel, _type = animcurvetype_catmullrom, _iterations = 8)
{
	_channel.type = _type
	_channel.iterations = (_type==animcurvetype_linear) ? 0 : _iterations
	return
}