/// @description			Use this to create a new force to apply within an emitter. Forces can be linear or radial, range of influence is infinite by default.
/// @param {Real}			_x : X coordinate relative to the emitter
/// @param {Real}			_y : Y coordinate relative to the emitter
/// @param {Real}			_direction	: Direction in degrees of the force
/// @param {Real}			_type	: Can be either PULSE_FORCE.DIRECTION or PULSE_FORCE.RADIAL
/// @param {Real}			_weight	: Amount that this will influence the particle, from 0 to 1.
/// @param {Real}			_force	: Amount that this will influence the particle, from 0 to 1.
/// @param {Bool}			_local	: Whether the force is placed in relation to the emitter (true) or in room space (false)
/// @return {Struct}
function pulse_force				(_x,_y,_direction,_type = PULSE_FORCE.DIRECTION,_weight = 1, _force = 1 , _local = true) constructor
{
	x			= _x
	y			= _y
	type		= _type
	range		= PULSE_FORCE.RANGE_INFINITE
	direction	= _direction
	weight		= _weight
	vec			= [0,0];
	vec[0]		= lengthdir_x(_force,direction)
	vec[1]		= lengthdir_y(_force,direction)
	local		= _local
							
	static set_range_directional = function(_north=-1,_south=-1,_east=-1,_west=-1)
	{
		if (_north==-1 &&_south==-1 &&_east==-1 &&_west==-1) 
		{
			range		= PULSE_FORCE.RANGE_INFINITE
			return self
		}
		north	= _north
		south	= _south
		east	= _east
		west	= _west
		
		range		= PULSE_FORCE.RANGE_DIRECTIONAL
		return self
		
	}
	static set_range_radial = function (_radius)
	{
		radius		= _radius
		range		= PULSE_FORCE.RANGE_RADIAL
		return self
	}
	
}
