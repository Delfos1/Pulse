
// dynamically changing the gravity strength to make a wavey back and forth effect
if t == 0
{
	_sign = -_sign
}


t = (t + increment) % 360;
shift = _sign * amplitude * dsin(t);

particle.set_gravity(shift,25)

emit.pulse(1,0,0)