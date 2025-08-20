if e_collide && activate_collision
{
	cache.check_collision(x,y)

	activate_collision =  false
}
if counter % e_freq == 0
{
	cache.pulse(e_amount*system_instance.s_resampling,0,0)
};
++counter

