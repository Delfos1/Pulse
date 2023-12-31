/*		// draw radiuses
		var ext_x =  radius_external*scalex
		var int_x =  radius_internal*scalex
		var ext_y =  radius_external*scaley
		var int_y =  radius_internal*scaley
		
		if form_mode == PULSE_FORM.ELLIPSE
		{
			draw_ellipse(x-ext_x,y-ext_y,x+ext_x,y+ext_y,true)
			draw_ellipse(x-int_x,y-int_y,x+int_x,y+int_y,true)
		}
		else if form_mode == PULSE_FORM.PATH
		{
			draw_path(path_a,x,y,true)
		}
		
		//draw origin
		draw_line_width_color(x-10,y,x+10,y,1,c_green,c_green)
		draw_line_width_color(x,y-10,x,y+10,1,c_green,c_green)
		
		//draw focal point
		if x_focal_point != 0 or y_focal_point!= 0
		{
			draw_line_width_color(x-10+x_focal_point,y+y_focal_point,x+10+x_focal_point,y+y_focal_point,3,c_yellow,c_yellow)
			draw_line_width_color(x+x_focal_point,y-10+y_focal_point,x+x_focal_point,y+10+y_focal_point,3,c_yellow,c_yellow)
		}
		
		if array_length(debug_col_rays) > 0
		{
			if is_colliding
			{
				draw_set_color(c_fuchsia)
			}else
			{
				draw_set_color(c_yellow)
			}
			
			for( var _i = 0 ; _i<array_length(debug_col_rays); _i++)
			{
				var _x = x+lengthdir_x(debug_col_rays[_i].value*ext_x,(debug_col_rays[_i].posx*360)%360)
				var _y = y+lengthdir_y(debug_col_rays[_i].value*ext_y,(debug_col_rays[_i].posx*360)%360)
				draw_circle(_x,_y,5,false)
			}
			draw_set_color(c_white)
		}
		
		
		//draw angle
		/*
		
		var _anstart_x = x+lengthdir_x(ext_x,mask_start)
		var _anstart_y = y+lengthdir_y(ext_y,mask_start)
		var _anend_x = x+lengthdir_x(ext_x,mask_end)
		var _anend_y = y+lengthdir_y(ext_y,mask_end)
		draw_line_width_color(x,y,_anstart_x,_anstart_y,1,c_green,c_green)
		draw_line_width_color(x,y,_anend_x,_anend_y,1,c_green,c_green)
		*/
		// draw direction
/*
		var angle = (direction_range[0]+direction_range[1])/2
			draw_arrow(x+(ext_x/2),y,x,y,10)
*/
