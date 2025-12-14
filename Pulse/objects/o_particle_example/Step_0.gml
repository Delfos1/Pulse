steps++
if steps >= life 
{
	instance_destroy()
	exit
}
image_angle+= particle.orient[2]
if particle.orient[4]
{
	var _angle = point_direction(_x,_y,x,y)
	image_angle = lerp_angle(image_angle,_angle,.6)
}

// calculate alpha over time
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
	
	if particle.color_mode == PULSE_COLOR_PARTICLE.COLOR
	{
		if array_length(particle.color) == 3
		{
			image_blend = merge_colour(particle.color[0],particle.color[1],_midppoint)
		}
		else if array_length(particle.alpha) == 2
		{
			image_blend = merge_colour(particle.color[0],particle.color[1],_lifepoint)
		}
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
	if particle.color_mode == PULSE_COLOR_PARTICLE.COLOR
	{
		if array_length(particle.color) == 3
		{
			image_blend = merge_colour(particle.color[1],particle.color[2],_midppoint)
		}
		else if array_length(particle.color) == 1
		{
			image_blend = merge_colour(particle.color[0],particle.color[1],_lifepoint)
		}
	}
}
_x=x
_y=y