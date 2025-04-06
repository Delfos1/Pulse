enum MOUSE_MODE {NORMAL, LASSO, HOVER, DRAG, ADD, INSERT}
enum MOUSE_COLL {NONE, POINT, LINE, HANDLE}

function RemakeSelectablePoints()
{
	points_selectable = []
	var _target = pathplus.polyline
	for(var _i2=0 ;_i2<array_length(_target) ;  _i2++)
	{
		var _x = _target[_i2].x,
			_y = _target[_i2].y
	
		array_push(points_selectable,[_i2,[_x,_y]])
	}
	if pathplus.type == PATHPLUS.BEZIER
	{
		handles_selectable		= []
		for(var _i2=0 ;_i2<array_length(_target) ;  _i2++)
		{
			if _target[_i2][$"h1"] != undefined
			{
				_x = _target[_i2].h1.x
				_y = _target[_i2].h1.y
				array_push(handles_selectable,[[_i2,true],[_x,_y]])
			}
			if _target[_i2][$"h2"] != undefined
			{
				_x = _target[_i2].h2.x
				_y = _target[_i2].h2.y
				array_push(handles_selectable,[[_i2,false],[_x,_y]])
			}

		}
	}
	
}