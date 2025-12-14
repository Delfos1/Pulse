/// @description			Use this to create a new force to apply within an emitter. Forces can be linear or radial, range of influence is infinite by default.
/// @param {Real}			_x : X coordinate relative to the emitter
/// @param {Real}			_y : Y coordinate relative to the emitter
/// @param {Real}			_direction	: Direction in degrees of the force
/// @param {Real}			_type	: Can be either PULSE_FORCE.DIRECTION or PULSE_FORCE.RADIAL
/// @param {Real}			_strength	: Strength of the force, in pixels.
/// @param {Real}			_weight	: Amount that this force will influence the particle, from 0 to 1.
/// @param {Bool}			_local	: Whether the force is placed in relation to the emitter (true) or in room space (false)
/// @return {Struct}
function pulse_force				(_x,_y,_direction,_type = PULSE_FORCE.DIRECTION, _strength = 1  ,_weight = 1, _local = true) constructor
{
	
	x			= _x
	y			= _y
	type		= _type
	range		= PULSE_FORCE.RANGE_INFINITE
	direction	= _direction
	strength	= _strength
	weight		= _weight
	vec			= [0,0];
	vec[0]		= lengthdir_x(_strength,direction)
	vec[1]		= lengthdir_y(_strength,direction)
	local		= _local
	north		= undefined
	south		= undefined
	east		= undefined
	west		= undefined
	radius		= undefined
					
	/// @description			Sets the range of the force to directional.
	/// @param {Real}			[_north] : X coordinate relative to the emitter
	/// @param {Real}			[_south] : X coordinate relative to the emitter
	/// @param {Real}			[_east]  : X coordinate relative to the emitter
	/// @param {Real}			[_west]  : X coordinate relative to the emitter
	static set_range_directional = function(_north=-1,_south=-1,_east=-1,_west=-1)
	{
		if (_north==-1 &&_south==-1 &&_east==-1 &&_west==-1) 
		{
			range		= PULSE_FORCE.RANGE_INFINITE
			return self
		}
		north	= _north < 0 ? -1 : _north
		south	= _south < 0 ? -1 : _south
		east	= _east < 0 ? -1 : _east
		west	= _west < 0 ? -1 : _west
		
		range		= PULSE_FORCE.RANGE_DIRECTIONAL
		return self
		
	}
	/// @description			Sets the force's range to radial
	/// @param {Real}			_radius : X coordinate relative to the emitter	
	static set_range_radial = function (_radius)
	{
		radius		= abs(_radius)
		range		= PULSE_FORCE.RANGE_RADIAL
		return self
	}
	/// @description			Sets the range of the force to infinity in all directions.
	static set_range_infinite =  function()
	{
		range		= PULSE_FORCE.RANGE_INFINITE
		return self
	}
	/// @description			Sets the direction of a force.
	/// @param {Real}			_direction : Direction of the force in degrees
	static set_direction =  function(_direction)
	{
		direction	= _direction
		vec[0]		= lengthdir_x(strength,direction)
		vec[1]		= lengthdir_y(strength,direction)
		return self
	}
	/// @description			Sets the strength of the force.
	/// @param {Real}			_strength : Strength of the force
	static set_strength =  function(_strength)
	{
		strength		= _strength
		vec[0]		= lengthdir_x(strength,direction)
		vec[1]		= lengthdir_y(strength,direction)
	}
	/// @description			Changes the type of the force
	/// @param {Real}			_type : PULSE_FORCE.DIRECTION or PULSE_FORCE.POINT
	static set_type = function(_type)
	{
		type		= _type
		
		return self
	}
}
