function draw_animcurve(_channel,_color,_x,_y,_width,_height){
	
	draw_set_color(_color)
	var _points = _channel.points
	if _channel.type == animcurvetype_linear
	{
		for(var _i = 0 ; _i< array_length(_points) ; _i++)
		{
			var _x0 = (_points[_i].posx * _width)+_x
			var _y0 = (_points[_i].value * -_height)+_y
		
			draw_circle(_x0,_y0,3,false)
			draw_text(_x0,_y0-20,string(_i))
		
			if _i+1< array_length(_points)
			{
				var _x1 = (_points[_i+1].posx * _width)+_x
				var _y1 = (_points[_i+1].value * -_height)+_y
				draw_line(_x0,_y0,_x1,_y1)
			}
		}
	}
	else
	{
		var _iterations = _channel.iterations
	
		for(var _i = 0 ; _i< array_length(_points) ; _i++)
		{
			var _x0 = (_points[_i].posx * _width)+_x
			var _y0 = (_points[_i].value * -_height)+_y
		
			draw_circle(_x0,_y0,3,false)
			draw_text(_x0,_y0-20,string(_i))
		
			if _i+1< array_length(_points)
			{
				for(var _j = 0 ; _j< _iterations ; _j++)
				{
					var _increment = (_points[_i+1].posx-_points[_i].posx)/_iterations
					var	_posx	= _points[_i].posx+_increment*_j
					var _value	= animcurve_channel_evaluate(_channel,_posx)
					
					_x0 = (_posx * _width)+_x
					_y0 = (_value * -_height)+_y
					
					var	_posx	= _points[_i].posx+_increment*(_j+1)
					var _value	= animcurve_channel_evaluate(_channel,_posx)
					
					var _x1 = (_posx * _width)+_x
					var _y1 = (_value * -_height)+_y
					
					draw_line(_x0,_y0,_x1,_y1)
				}
			}
		}
	}
}