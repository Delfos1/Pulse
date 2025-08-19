s_status = system.index != -1 ?  "System is Awake" : "System is Asleep"
sleepy = system.index != -1 ?  1 : 0
if system.index != 1
{
	system.get_particle_count()
	if s_supersample && !s_update
	{
		system.update_system(s_resampling)
	}
}