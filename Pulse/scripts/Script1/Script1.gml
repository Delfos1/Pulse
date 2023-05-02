/// @function					part_round_emit()		
/// @descr						Emits particles in a round area, emitting from or towards a central point.
/// @param {id.particlesystem}	partsystem
/// @param {id.particletype}	parttype
/// @param {real}				_amount Amount of particles
/// @param {real}				_x X coordinate for origin
/// @param {real}				_y Y coordinate for origin
/// @param {real}				_radiusExternal Radius of the emitter
/// @param {real}				_radiusInternal Internal Radius. If its equal to external, its a ring.
/// @param {bool}				_outward If true, particles will be moving away from center, otherwise they keep their original setting
/// @param {real}				angle_start From wich angle
/// @param {real}				angle_end To which 


function part_round_emit(partsystem,parttype,_amount,_x,_y,_radiusExternal,_radiusInternal=0,_outward=true,angle_start=0,angle_end=360)	
{
	repeat(_amount)
		{
			//Chooses a direction at random and then plots a random length in that direction.
			//Then adds that coordinate to the origin coordinate.
			var dir		=	random_range(angle_start,angle_end);
			var length	=	random_range(_radiusInternal,_radiusExternal);
			var _xx		=	_x	+ lengthdir_x(length,dir);
			var _yy		=	_y	+ lengthdir_y(length,dir);
			
			if		_outward
			{
				//If direction is outwards from center, the direction of the particle is the random direction
				part_type_direction(parttype,dir,dir,0,0)
			}
			//If _direction is set as false, direction of the particle is kept as before.

			part_particles_create(partsystem, _xx,_yy,parttype, 1);
		}
}

/// @function					instance_round_emit()		
/// @descr						Emits ISNTANCES in a round area, emitting from or towards a central point.
/// @param {id.layerID}			_layer layer ID
/// @param {id.ObjectID}		Object
/// @param {real}				_amount Amount of particles
/// @param {real}				_x X coordinate for origin
/// @param {real}				_y Y coordinate for origin
/// @param {real}				_radiusExternal Radius of the emitter
/// @param {real}				_radiusInternal Internal Radius. If its equal to external, its a ring.
/// @param {string}				_direction It can be "out", "in" or "none". Its the direction the particles will travel
/// @param {real}				angle_start From wich angle
/// @param {real}				angle_end To which 
/// @param {array}				Speed speed of object


function instance_round_emit(_layer,_object,_amount,_x,_y,_radiusExternal,_radiusInternal=0,_direction="out",angle_start=0,angle_end=360,_speed=[2,3])	
{
	repeat(_amount)
		{
			//Chooses a direction at random and then plots a random length in that direction.
			//Then adds that coordinate to the origin coordinate.
			var dir		=	random_range(angle_start,angle_end);
			var length	=	random_range(_radiusInternal,_radiusExternal);
			var _xx		=	_x	+ lengthdir_x(length,dir);
			var _yy		=	_y	+ lengthdir_y(length,dir);
			
			if		_direction == "out"
			{
				//If direction is outwards from center, the direction of the particle is the random direction
				var rot=dir
			}
			else if _direction == "in"
			{
				//If direction is inwards, direction should be the opposite. It is necessary to also calculate the distance to the center to change speed/life
				show_debug_message("Radial particle direction inwards not yet available")
				exit
			}else exit
			
			var inst	=	instance_create_layer(_xx,_yy,_layer,_object)	
			inst.hsp	=	lengthdir_x(1,dir)*random_range(_speed[0],_speed[1])
			inst.vsp	=	lengthdir_y(1,dir)*random_range(_speed[0],_speed[1])
		}
}


/// @function					part_round_sink()		
/// @descr						Emits particles in a round area, towards a central point.
/// @param {id.particlesystem}	partsystem
/// @param {id.particletype}	parttype
/// @param {real}				_SpeedStart Starting speed of particles
/// @param {real}				_life Life of particles
/// @param {real}				_amount Amount of particles
/// @param {real}				_x X coordinate for origin
/// @param {real}				_y Y coordinate for origin
/// @param {real}				_radiusExternal Radius of the emitter
/// @param {real}				_radiusInternal Internal Radius. If its equal to external, its a ring.
/// @param {real}				angle_start From wich angle
/// @param {real}				angle_end To which 
/// @param {real}				_acceleration Starting acceleration
/// @param {bool}				_force_to_center Whether all particles need to end at the origin point regardless of position


function part_round_sink(partsystem,parttype,_speedStart,_life,_amount,_x,_y,_radiusExternal,_radiusInternal=0,angle_start=0,angle_end=360,_acceleration=0,_force_to_center=false)	
{
	repeat(_amount)
		{
			//Chooses a direction at random and then plots a random length in that direction.
			//Then adds that coordinate to the origin coordinate.
			var dir		=	random_range(angle_start,angle_end);
			var length	=	random_range(_radiusInternal,_radiusExternal);
			var _xx		=	_x	+ lengthdir_x(length,dir);
			var _yy		=	_y	+ lengthdir_y(length,dir);
			
			//Direction is inwards, direction should be the opposite. It is necessary to also calculate the distance to the center to change speed/life
				
			dir			=	point_direction(_xx,_yy,_x,_y)
			
			var _speed	=	random_range(_speedStart[0],_speedStart[1])
			

			if _acceleration==0
			{
				var displacement = _speed*_life
			
				if ((displacement < length) && _force_to_center) or (displacement > length)
				{
					_speed	=	length/_life
				}
			}
			else
			{
				var displacement = (_speed*_life)+((_acceleration*sqr(_life))*.5)
			
				if ((displacement < length) && _force_to_center) or (displacement > length)
				{
					_speed = (length/_life)-(_acceleration*_life)*.5;
				}
			}
				
				
			//show_debug_message("speed ={0},accel={1}, displacement = {2}, length = {3}",_speed,accel,displacement,length)
			part_type_life(parttype,_life,_life);
			part_type_speed(parttype,_speed,_speed,_acceleration,0)
			part_type_direction(parttype,dir,dir,0,0)
			part_particles_create(partsystem, _xx,_yy,parttype, 1);
		}
}

function part_shaped_emit(partsystem,parttype,acCurve,acChannel,_amount,_x,_y,_radiusExternal,_radiusInternal=0,_outward=true,angle_start=0,angle_end=360)	
{
	repeat(_amount)
		{

			
			//Chooses a direction at random and then plots a random length in that direction.
			//Then adds that coordinate to the origin coordinate.
			var dir		=	random_range(angle_start,angle_end);
			var curve	=	animcurve_get_channel(acCurve,acChannel)
			var dir_curve = dir+270
			if dir_curve>360 dir_curve-=360
			var eval	=	animcurve_channel_evaluate(curve,dir_curve*0.0028)
			var length	=	eval*random_range(_radiusInternal,_radiusExternal);
			var _xx		=	_x	+ lengthdir_x(length,dir);
			var _yy		=	_y	+ lengthdir_y(length,dir);
			
			if		_outward
			{
				//If direction is outwards from center, the direction of the particle is the random direction
				part_type_direction(parttype,dir,dir,0,0)
			}
			//If _direction is set as false, direction of the particle is kept as before.

			part_particles_create(partsystem, _xx,_yy,parttype, 1);
		}
}