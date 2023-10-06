t2 = (t2 + increment2) % 360;
t3 = (t3 + increment3) % 360;
shift2 = _sign2 * amplitude2 * dsin(t2);
shift3 = amplitude2 * dsin(t3);
//---

if t == 0
{
	_sign = -_sign
}
t = (t + increment) % 360;
shift = _sign * amplitude * dsin(t);

bubble.set_size(.5,.7,[shift2,-shift2]).set_gravity(shift,0)
bubble2.set_size(.1,.3,[shift3,-shift3]).set_gravity(shift,0)
