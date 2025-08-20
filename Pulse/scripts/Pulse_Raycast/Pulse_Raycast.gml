/// @desc Throws a vector until it hits an object. Returns Vector3(x, y, id) if it hits.
/// @param {real} origin_x The ray x origin.
/// @param {real} origin_y The ray y origin.
/// @param {Id.GMObject} object The object id do check.
/// @param {real} angle Ray angle.
/// @param {real} distance Ray distance.
/// @param {bool} precise Whether the check is based on precise collisions (true, which is slower) or its bounding box in general (false, faster).
/// @param {bool} notme Whether the calling instance, if relevant, should be excluded (true) or not (false).
/// @returns {struct} Description
	// original by: YellowAfterLife, https://yal.cc/gamemaker-collision-line-point/
	// edited by FoxyOfJungle, adapted for Pulse
function	__pulse_raycast(origin_x, origin_y, object, angle, distance, precise=true, notme=true)
{

	//	var _dir = degtorad(angle),
	var _x1 = origin_x,
	_y1 = origin_y,
	_x2 = origin_x + lengthdir_x(distance,angle), //+ cos(_dir)*distance,
	_y2 = origin_y + lengthdir_y(distance,angle),//- sin(_dir)*distance,
	
	_col = collision_line(_x1, _y1, _x2, _y2, object, precise, notme),
	_col2 = noone,
	
	_xo = _x1,
	_yo = _y1;
	
	if (_col != noone) {
		var _p0 = 0,
		_p1 = 1,
		_np = 0,
		_px = 0,
		_py = 0,
		_nx = 0,
		_ny = 0,
		_len = ceil(log2(point_distance(_x1, _y1, _x2, _y2))) + 1;
		repeat(_len) {
			_np = _p0 + (_p1 - _p0) * 0.5;
			_nx = _x1 + (_x2 - _x1) * _np;
			_ny = _y1 + (_y2 - _y1) * _np;
			_px = _x1 + (_x2 - _x1) * _p0;
			_py = _y1 + (_y2 - _y1) * _p0;
			_col2 = collision_line(_px, _py, _nx, _ny, object, precise, notme);
			if (_col2 != noone) {
				_col = _col2;
				_xo = _nx;
				_yo = _ny;
				_p1 = _np;
			} else _p0 = _np;
		}
		return {x: _xo, y: _yo, z: _col};
	}
	return noone
	
}
