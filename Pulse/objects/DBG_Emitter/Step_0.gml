if system_instance == undefined or particle_instance == undefined
{
	++counter
	exit	
}

if e_collide && activate_collision
{
	if cacheing
	{
		cache.check_collision(x,y)
	}
	else
	{
		emitter.check_collision(x,y)
	}
	activate_collision =  false
}
if counter % e_freq == 0
{
	if cacheing
	{
		// Restarting the particle prevents carry-over from color data
		particle_instance.particle.reset()
		cache.pulse(e_amount*system_instance.s_resampling,0,0)
	}
	else
	{
		// Restarting the particle prevents carry-over from color data
		particle_instance.particle.reset()
		emitter.pulse(e_amount*system_instance.s_resampling,x,y,false)	;
	}
};
++counter



if !array_equals(e_mask_u_prev,e_mask_u)
{
	emitter.set_u_mask(e_mask_u[0],e_mask_u[1])

	e_mask_u_prev[0] = e_mask_u[0]
	e_mask_u_prev[1] = e_mask_u[1]
}
if !array_equals(e_mask_v_prev,e_mask_v)
{
	emitter.set_v_mask(e_mask_v[0],e_mask_v[1])

	e_mask_v_prev[0] = e_mask_v[0]
	e_mask_v_prev[1] = e_mask_v[1]
}
if !array_equals(e_dir_prev,e_dir)
{
	emitter.set_direction_range(e_dir[0],e_dir[1])

	e_dir_prev[0] = e_dir[0]
	e_dir_prev[1] = e_dir[1]
}

if !array_equals(e_stencils,e_stencils_prev) || e_stencils_mode != e_stencils_mode_prev
{
	if e_stencils[0] != undefined
	{
		emitter.set_stencil(ac_Polygons,e_stencils[0],e_stencils_mode,0)
		e_stencils_prev[0] = e_stencils[0]
	}
	if e_stencils[1] != undefined
	{
		emitter.set_stencil(ac_Polygons,e_stencils[1],e_stencils_mode,1)
		e_stencils_prev[1] = e_stencils[1]
	}
	if e_stencils_mode != e_stencils_mode_prev
	{
		e_stencils_mode_prev = e_stencils_mode
	}
}
if e_stencils_off !=e_stencils_off_prev
{
	emitter.set_stencil_offset(e_stencils_off)
	e_stencils_off_prev =  e_stencils_off
}
if e_stencils_tween != e_stencils_tween_prev
{
	emitter.set_stencil_tween(e_stencils_tween)
	e_stencils_tween_prev =  e_stencils_tween
}

if e_dist_v_offset != e_dist_v_offset_prev
{
	emitter.set_distribution_v_offset(e_dist_v_offset)
	
	e_dist_v_offset_prev = e_dist_v_offset
}

if e_dist_u_offset != e_dist_u_offset_prev
{
	emitter.set_distribution_u_offset(e_dist_u_offset)
	
	e_dist_u_offset_prev = e_dist_u_offset
}


#endregion
