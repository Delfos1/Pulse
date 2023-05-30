debug	 = false
on		 = false
_x = x
show_debug_overlay(debug)


pulse_convert_particles(PS_Fire)



path=path_add()

var smoke_pt = pulse_make_particle("smoke",false)

fire = new part_pulse_emitter("fire","Fire",8)

smoke= new part_pulse_emitter("smoke","smoke",1)

smoke._path_a=path


smoke_pt.shape(pt_shape_cloud)
smoke_pt.size(.2,.4,.001)
smoke_pt.color(c_grey,c_dkgray)
smoke_pt.life(130,150)
smoke_pt.orient(0,360,0.3)
smoke_pt.speed_start(1,1,0)
smoke.direction_range(-90,-90)

smoke.radius(0,10)
smoke.mask(0,0.001)



alarm[0]=2
 mp_potential_settings(90,20,1.5,false)
 mp_potential_path_object(path,o_smoke_Dir.x,o_smoke_Dir.y,25,2,oWall)

 //path_set_kind(path,1)

