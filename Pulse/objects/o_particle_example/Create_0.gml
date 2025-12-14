// This is a barebones example. If you are using instances, you probably want to do more complex
//stuff with this
_x=x
_y=y
steps = 0;
direction= dir
gravity_direction = particle.gravity[1]
gravity= particle.gravity[0]
if particle.orient !=undefined
{
	image_angle = particle.orient[0]
}
sprite_index = particle.sprite ==  undefined ? sprite_index : particle.sprite[0]

image_alpha = particle.alpha[0]

// if sprite is not animated
if !particle.sprite[1]
{
	image_speed = 0
}

// if sprite frame is random
if particle.sprite[3]
{
	image_index= irandom_range(0,image_number)
} else {
	image_index= clamp(particle.sprite[4],0,image_number)
}