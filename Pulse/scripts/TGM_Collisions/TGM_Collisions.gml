
/// Feather ignore all

/// @desc This function returns a boolean (true or false) depending on whether the position is inside a triangle.
/// @param {real} px The x position, example: mouse_x.
/// @param {real} py The y position, example: mouse_y.
/// @param {real} x The x origin of the cone.
/// @param {real} y The y origin of the cone.
/// @param {real} angle The cone angle/direction.
/// @param {real} dist The cone distance.
/// @param {real} fov The cone field of view.
/// @returns {bool}
function point_in_cone(px, py, x, y, angle, dist, fov) {
	var _len_x1 = dcos(angle - fov/2) * dist,
	_len_y1 = dsin(angle - fov/2) * dist,
	_len_x2 = dcos(angle + fov/2) * dist,
	_len_y2 = dsin(angle + fov/2) * dist;
    return point_in_triangle(px, py, x, y, x+_len_x1, y-_len_y1, x+_len_x2, y-_len_y2);
}

/// @desc This function returns a boolean (true or false) depending on whether the position is inside a arc.
/// @param {real} px The x position, example: mouse_x.
/// @param {real} py The y position, example: mouse_y.
/// @param {real} x The x origin of the cone.
/// @param {real} y The y origin of the cone.
/// @param {real} angle The cone angle/direction.
/// @param {real} dist The cone distance.
/// @param {real} fov The cone field of view.
/// @returns {bool} Description
function point_in_arc(px, py, x, y, angle, dist, fov) {
	return (point_distance(px, py, x, y) < dist && abs(angle_difference(angle, point_direction(x, y, px, py))) < fov/2);
}

/// @desc Checks if a point is inside a parallelogram.
/// @param {real} x The x position to check.
/// @param {real} y The y position to check.
/// @param {array} parallelogram Parallelogram points.
/// @returns {bool} 
function point_in_parallelogram(px, py, parallelogram) {
	// in first
	if (point_in_triangle(px, py, parallelogram[0], parallelogram[1], parallelogram[2], parallelogram[3], parallelogram[6], parallelogram[7])) return true;
	// in second
	if (point_in_triangle(px, py, parallelogram[4], parallelogram[5], parallelogram[2], parallelogram[3], parallelogram[6], parallelogram[7])) return true;
	return false;
}

/// @desc This function is used to check collisions without slope support.
/// @param {real} hspd The horizontal vector speed.
/// @param {real} vspd The vertical vector speed.
/// @param {any} object Object to check collision with.
/// @returns {struct} 
function move_and_collide_simple(hspd, vspd, object) {
	var vx = sign(hspd),
	vy = sign(vspd),
	_col = noone,
	_hor_colliding = false,
	_ver_colliding = false,
	_collision_id = noone;
	
	_col = instance_place(x+hspd, y, object);
	if (_col != noone) {
		repeat(abs(hspd) + 1) {
			if (place_meeting(x + vx, y, object)) break;
			x += vx;
		}
		hspd = 0;
		_hor_colliding = true;
		_collision_id = _col;
	}
	x += hspd;
	
	_col = instance_place(x, y+vspd, object);
	if (_col != noone) {
		repeat(abs(vspd) + 1) {
			if (place_meeting(x, y + vy, object)) break;
			y += vy;
		}
		vspd = 0;
		_ver_colliding = true;
		_collision_id = _col;
	}
	y += vspd;
	
	return new Vector3(_hor_colliding, _ver_colliding, _collision_id);
}

/// @desc This function is used to check collisions based on tags, without slope support.
/// @param {real} hspd The horizontal vector speed.
/// @param {real} vspd The vertical vector speed.
/// @param {String, Array<String>} tags Tags string or array
/// @returns {struct} 
function move_and_collide_simple_tag(hspd, vspd, tags) {
	var _pri = ds_priority_create();
	// search for tag objects
	var _object_ids_array = tag_get_asset_ids(tags, asset_object),
	i = 0, isize = array_length(_object_ids_array);
	repeat(isize) {
		var _object = _object_ids_array[i];
		ds_priority_add(_pri, _object, distance_to_object(_object));
		++i;
	}
	var _obj = ds_priority_find_min(_pri);
	ds_priority_destroy(_pri);
	return move_and_collide_simple(hspd, vspd, _obj);
}

/// @desc Gets the instance with the highest depth, regardless of the layer
/// @param {real} px The x position to check.
/// @param {real} py The y position to check.
/// @param {any*} object The object to check.
/// @returns {id} 
function instance_top_position(px, py, object) {
	var _top_instance = noone,
	_list = ds_list_create(),
	_num = collision_point_list(px, py, object, false, true, _list, false);
	if (_num > 0) {
		var i = 0;
		repeat(_num) {
			_top_instance = _list[| ds_list_size(_list)-1];
			++i;
		}
	}
	ds_list_destroy(_list);
	return _top_instance;
}

/// @desc Get the number of instances of a specific object.
/// @param {asset.gmobject} object The object asset.
/// @returns {real} 
function instance_number_object(object) {
	var _number = 0;
	with(object) {
		if (object_index == object) _number++;
	}
	return _number;
}

/// @desc Gets the nearest instance of an object, based on x and y position.
/// @param {Real} x The x position to check from.
/// @param {Real} y The y position to check from.
/// @param {Id.GMObject} object Object asset index.
/// @param {Real} number The position number.
/// @returns {id} 
function instance_nearest_nth(x, y, object, number) {
	//if (!instance_exists(object)) return noone;
	var _px = x,
	_py = y,
	_inst = noone,
	_pri = ds_priority_create(),
	i = 0;
	with(object) {
		if (self == object) continue;
		ds_priority_add(_pri, id, distance_to_point(_px, _py));
		++i;
	}
	var _numb = min(i, max(1, number));
	repeat(_numb) {
		_inst = ds_priority_delete_min(_pri);
	}
	ds_priority_destroy(_pri);
	return _inst;
}

/// @desc Gets the farthest instance of an object, based on x and y position.
/// @param {Real} x The x position to check from.
/// @param {Real} y The y position to check from.
/// @param {Id.GMObject} object Object asset index.
/// @param {Real} number The position number.
/// @returns {id} 
function instance_farthest_nth(x, y, object, number) {
	//if (!instance_exists(object)) return noone;
	var _px = x,
	_py = y,
	_inst = noone,
	_pri = ds_priority_create(),
	i = 0;
	with(object) {
		if (self == object) continue;
		ds_priority_add(_pri, id, distance_to_point(_px, _py));
		++i;
	}
	var _numb = min(i, max(1, number));
	repeat(_numb) {
		_inst = ds_priority_delete_max(_pri);
	}
	ds_priority_destroy(_pri);
	return _inst;
}
	
	
	#region jsDoc
/// @func    collision_circle_array()
/// @desc    This function is the same as the collision_circle() function, only instead of just detecting one instance / tile map in collision at a time, it will detect multiple instances or tile maps.
/// @param   {Real}	x1 : The x coordinate of the center of the circle to check.
/// @param   {Real}	y1 : The y coordinate of the center of the circle to check.
/// @param   {Real}	rad : The radius (distance in pixels from its center to its edge).
/// @param   {Object}	obj : Asset or Object Instance or Tile Map Element ID or Array	An object, instance, tile map ID, keywords all/other, or array containing these items
/// @param   {Boolean}	prec : Whether the check is based on precise collisions (true, which is slower) or its bounding box in general (false, faster).
/// @param   {Boolean}	notme : Whether the calling instance, if relevant, should be excluded (true) or not (false).
/// @param   {Array}	array : The array to use to store the IDs of colliding instances.
/// @param   {Boolean}	ordered : Whether the list should be ordered by distance (true) or not (false).
/// @returns {Array}
#endregion
function collision_circle_array(_x1, _y1, _radius, _obj, _prec=false, _notme=true, _arr=undefined, _ordered=false) {
	static __list = ds_list_create();
	collision_circle_list(_x1, _y1, _radius, _obj, _prec, _notme, __list, _ordered);
	
	_arr = __push_list_into_arr(_arr, __list);
	
	ds_list_clear(__list);
	return _arr;
}
#region jsDoc
/// @func    collision_ellipse_array()
/// @desc    This function is the same as the collision_ellipse() function, only instead of just detecting one instance / tile map in collision at a time, it will detect multiple instances or tile maps.
/// @param   {Real}	x1 : The x coordinate of the left side of the ellipse to check.
/// @param   {Real}	y1 : The y coordinate of the top side of the ellipse to check.
/// @param   {Real}	x2 : The x coordinate of the right side of the ellipse to check.
/// @param   {Real}	y2 : The y coordinate of the bottom side of the ellipse to check.
/// @param   {Object}	obj : Asset or Object Instance or Tile Map Element ID or Array	An object, instance, tile map ID, keywords all/other, or array containing these items
/// @param   {Boolean}	prec : Whether the check is based on precise collisions (true, which is slower) or its bounding box in general (false, faster).
/// @param   {Boolean}	notme : Whether the calling instance, if relevant, should be excluded (true) or not (false).
/// @param   {Array}	array : The array to use to store the IDs of colliding instances.
/// @param   {Boolean}	ordered : Whether the list should be ordered by distance (true) or not (false).
/// @returns {Array}
#endregion
function collision_ellipse_array(_x1, _y1, _x2, _y2, _obj, _prec=false, _notme=true, _arr=undefined, _ordered=false) {
	static __list = ds_list_create();
	collision_ellipse_list(_x1, _y1, _x2, _y2, _obj, _prec, _notme, __list, _ordered);
	
	_arr = __push_list_into_arr(_arr, __list);
	
	ds_list_clear(__list);
	return _arr;
}
#region jsDoc
/// @func    collision_line_array()
/// @desc    This function is the same as the collision_line() function, only instead of just detecting one instance / tile map in collision at a time, it will detect multiple instances / tile maps.
/// @param   {Real}	x1 : The x coordinate of the start of the line.
/// @param   {Real}	y1 : The y coordinate of the start of the line.
/// @param   {Real}	x2 : The x coordinate of the end of the line.
/// @param   {Real}	y2 : The y coordinate of the end of the line.
/// @param   {Object}	obj : Asset or Object Instance or Tile Map Element ID or Array	An object, instance, tile map ID, keywords all/other, or array containing these items
/// @param   {Boolean}	prec : Whether the check is based on precise collisions (true, which is slower) or its bounding box in general (false, faster).
/// @param   {Boolean}	notme : Whether the calling instance, if relevant, should be excluded (true) or not (false).
/// @param   {Array}	array : The array to use to store the IDs of colliding instances.
/// @param   {Boolean}	ordered : Whether the list should be ordered by distance (true) or not (false).
/// @returns {Array}
#endregion
function collision_line_array(_x1, _y1, _x2, _y2, _obj, _prec=false, _notme=true, _arr=undefined, _ordered=false) {
	static __list = ds_list_create();
	collision_line_list(_x1, _y1, _x2, _y2, _obj, _prec, _notme, __list, _ordered);
	
	_arr = __push_list_into_arr(_arr, __list);
	
	ds_list_clear(__list);
	return _arr;
}
#region jsDoc
/// @func    collision_point_array()
/// @desc    This function is the same as the collision_circle() function, only instead of just detecting one instance / tile map in collision at a time, it will detect multiple instances or tile maps.
/// @param   {Real} x : The x coordinate of the point to check.
/// @param   {Real} y : The y coordinate of the point to check.
/// @param   {Object} obj : Asset or Object Instance or Tile Map Element ID or Array	An object, instance, tile map ID, keywords all/other, or array containing these items
/// @param   {Boolean} prec : Whether the check is based on precise collisions (true, which is slower) or its bounding box in general (false, faster).
/// @param   {Boolean} notme : Whether the calling instance, if relevant, should be excluded (true) or not (false).
/// @param   {Array}	array : The array to use to store the IDs of colliding instances.
/// @param   {Boolean} ordered : Whether the list should be ordered by distance (true) or not (false).
/// @returns {Array}
#endregion
function collision_point_array(_x, _y, _obj, _prec=false, _notme=true, _arr=undefined, _ordered=false) {
	static __list = ds_list_create();
	collision_point_list(_x, _y, _obj, _prec, _notme, __list, _ordered);
	
	_arr = __push_list_into_arr(_arr, __list);
	
	ds_list_clear(__list);
	return _arr;
}
#region jsDoc
/// @func    collision_rectangle_array()
/// @desc    This function is the same as the collision_circle() function, only instead of just detecting one instance / tile map in collision at a time, it will detect multiple instances or tile maps.
/// @param   {Real} x1 : The x coordinate of the left side of the rectangle to check.
/// @param   {Real} y1 : The y coordinate of the top side of the rectangle to check.
/// @param   {Real} x2 : The x coordinate of the right side of the rectangle to check.
/// @param   {Real} y2 : The y coordinate of the bottom side of the rectangle to check.
/// @param   {Object} obj : Asset or Object Instance or Tile Map Element ID or Array	An object, instance, tile map ID, keywords all/other, or array containing these items
/// @param   {Boolean} prec : Whether the check is based on precise collisions (true, which is slower) or its bounding box in general (false, faster).
/// @param   {Boolean} notme : Whether the calling instance, if relevant, should be excluded (true) or not (false).
/// @param   {Array}	array : The array to use to store the IDs of colliding instances.
/// @param   {Boolean} ordered : Whether the list should be ordered by distance (true) or not (false).
/// @returns {Array}
#endregion
function collision_rectangle_array(_x1, _y1, _x2, _y2, _obj, _prec=false, _notme=true, _arr=undefined, _ordered=false) {
	static __list = ds_list_create();
	collision_rectangle_list(_x1, _y1, _x2, _y2, _obj, _prec, _notme, __list, _ordered);
	
	_arr = __push_list_into_arr(_arr, __list);
	
	ds_list_clear(__list);
	return _arr;
}

//helper function
function __push_list_into_arr(_arr, _list) {
	gml_pragma("forceinline");
	if (_arr == undefined) {
		_arr = array_create(ds_list_size(_list), undefined);
		var _offset = 0;
	}
	else {
		var _offset = array_length(_arr);
		array_resize(_arr, _offset+ds_list_size(_list))
	}
	
	var _i=0; repeat(ds_list_size(_list)) {
		_arr[_offset+_i] = _list[| _i];
	_i+=1;}//end repeat loop
	
	return _arr;
}
