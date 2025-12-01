//feather ignore all
/**
 * Simplifies an animation curve based on an epsilon value from 0 to 1. 0 = no simplification 1 = Complete simplification.
 *  Returns a new array of points.
 * @param {Array} _points 
 * @param {Real} _epsilon  0 = no simplification 1 = Complete simplification. When epsilon is left empty, it will use an estimate which is fairly strong, based on an average of the points.
 * @return {Array}
 */
function animcurve_simplify(_points,_epsilon=undefined){

	var _start = 0
	var _end = array_length(_points)-1
	var simple_point_list = []

	animcurve_point_add(simple_point_list,_points[_start].posx	,_points[_start].value)
	animcurve_point_add(simple_point_list,_points[_end].posx	,_points[_end].value)
	
			// Go through all points to find the points that are furthest and closest from the line between A and B
		var _maxDist = -1,
			_maxIndex = -1,
			_avgDist = 0
			
		for(var _i = _start ; _i< _end ;_i++)
		{
			var _d = pointToLineDistance(	_points[_i].posx		,_points[_i].value,
											_points[_start].posx	,_points[_start].value,
											_points[_end].posx	,_points[_end].value)
			_avgDist += _d
			
			if _d > _maxDist
			{
				 _maxDist	=	_d
				 _maxIndex	=	_i
			}
		}
		_avgDist = _maxDist-(_avgDist/_end)
		
		_epsilon= _epsilon == undefined ? _avgDist : lerp(0,_maxDist,_epsilon)
	
	
	
	simple_point_list = animcurve_points_merge(simple_point_list,__simplify_step(_points,_epsilon,_start,_end))
	
	return simple_point_list
}

