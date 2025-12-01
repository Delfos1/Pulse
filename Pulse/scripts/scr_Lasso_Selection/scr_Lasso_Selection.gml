       
/// Records a polygon to be usde as a lasso selection  
/// @param {Real}		x x coordinate of the new position
/// @param {Real}		y y coordinate of the new position
/// @param {Real}		_dis minimum distance required to record a new vertex

function LassoSelection(x,y,_dis = 10){
	
	static rec = new PathPlus() 
	static active = true
	
	active = true
	if rec.l > 1 
	{
		var _distance = point_distance(x,y,rec.polyline[rec.l-1].x,rec.polyline[rec.l-1].y) //compare current position to previous 
		if  _distance < _dis		return
	}
	
	rec.AddPoint(x,y)
}
/// Draws the lasso
function LassoDraw(){

	if !LassoSelection.active { return }
	LassoSelection.rec.DebugDraw()
	
	return
}

/// Completes the selection. Provide an instance, an array of instances/objects, or an array of coordinates with the format [id,[x,y],[x,y],etc...] . To collide, half or more of the object needs to be within the lasso shape. It returns an array of ID's or the variable provided in the first array space.
function LassoEnd(_collide){

	if LassoSelection.rec.l	== 0 ||  !LassoSelection.active  return 
	

	var _coord =[]

	#region Prepare collision points for checks
	if is_array(_collide)
	{
		for(var _j=0; _j<array_length(_collide);_j++)
		{
			if is_handle(_collide[_j])
			{
				with(_collide[_j])
				{
					array_push(_coord,[id,[bbox_left,bbox_top],[bbox_left,bbox_bottom],[bbox_right,bbox_top],[bbox_right,bbox_bottom]])
				}
			}else{array_push(_coord,_collide[_j])}
		}
	}
	else if is_handle(_collide)
	{
		with(_collide)
		{
			array_push(_coord,[id,[bbox_left,bbox_top],[bbox_left,bbox_bottom],[bbox_right,bbox_top],[bbox_right,bbox_bottom]])
		}
	}
	else
	{
		show_debug_message("Lasso Error: Collide data provided doesnt conform to an array or an object")	
		LassoSelection.rec.Reset()
		LassoSelection.rec.l	=0
		LassoSelection.active = false
		return []
	}
	#endregion
	
	var _results =[]
	var _l = array_length(_coord)
	for(var _i=0; _i<_l;_i++)
	{
		// Starts at 1 because 0 is reserved for an id
		var _found_points = 0
		for (var _in = 1 ;_in <  array_length(_coord[_i]) ;_in++ )
		{
			_found_points = point_in_polygon(_coord[_i][_in][0],_coord[_i][_in][1],LassoSelection.rec.polyline) ? _found_points+1 : _found_points
		}
	
		if (_found_points >= (array_length(_coord[_i])-1)/2)
		{
			array_push(_results,_coord[_i][0])
		}
		
	}
		LassoSelection.rec.Reset()
		LassoSelection.rec.l	=0
		LassoSelection.active = false
		return _results
}
