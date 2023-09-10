
// dynamically changing the gravity strength to make a wavey back and forth effect
if t == 0
{
	_sign = -_sign
}


t = (t + increment) % 360;
shift = _sign * amplitude * dsin(t);

particle.set_gravity(shift,25)

var _random = irandom_range(0,1)

if _random == 0
{
emit.pulse(1,-50,-50)
}