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
 * @param {String} channel_src the channel index or name to copy from
 * @param {asset.GMAnimCurve} curve_dest the animation curve to copy to
 * @param {String} channel_dest name for the destination channel. By default is the same as the source
 * @return {bool}
 */
function animcurve_channel_copy(curve_src, channel_src,curve_dst,channel_dst=channel_src) 
{
	if !animcurve_channel_exists(curve_src, channel_src) return false
	
	var _source,_dest;
	_source = animcurve_get_channel(curve_src, channel_src)
	
	if !animcurve_channel_exists(curve_dst, channel_src)
	{
		_dest = animcurve_channel_new();
	}
	else
	{
		_dest = animcurve_get_channel(curve_dst, channel_src)
	}


	_dest.name =		channel_dst;
	_dest.type =		_source.type
	_dest.iterations =	_source.iterations
	_dest.points=		_source.points
	
	array_push(curve_dst.channels,_dest)
	
	return true
}