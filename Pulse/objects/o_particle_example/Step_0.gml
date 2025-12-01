steps++
if steps >= life 
{
	instance_destroy()
	exit
}

var _lifepoint = steps/life
if _lifepoint < .5
{
	var _midppoint = clamp(_lifepoint*2,0,1)
	if array_length(particle.alpha) == 3
	{
		image_alpha = lerp(particle.alpha[0],particle.alpha[1],_midppoint)
	}
	else if array_length(particle.alpha) == 2
	{
		image_alpha = lerp(particle.alpha[0],particle.alpha[1],_lifepoint)
	}
}
else
{
	var _midppoint = (_lifepoint-0.5)*2
	if array_length(particle.alpha) == 3
	{
		image_alpha = lerp(particle.alpha[1],particle.alpha[2],_midppoint)
	}
	else if array_length(particle.alpha) == 1
	{
		image_alpha = lerp(particle.alpha[0],particle.alpha[1],_lifepoint)
	}
}