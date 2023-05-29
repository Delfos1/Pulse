debug	 = true
on		 = false
_x = x
show_debug_overlay(debug)


pulse_convert_particles(PS_Fire)

var _fire = pulse_particle_get_ID("Fire")

path=path_add()

var smoke_pt = pulse_make_particle("smoke",false)

fire = new part_pulse_emitter("fire",_fire,8)

smoke= new part_pulse_path_emitter(path,"smoke","Fire",1)

fire._dist_along_form=PULSE_MODE.NONE
fire.angle(90,90)

smoke_pt.shape(pt_shape_cloud)
smoke_pt.size(.2,.4,.001)
smoke_pt.color(c_grey,c_dkgray)
smoke_pt.life(130,150)
smoke_pt.orient(0,360,0.3)
smoke_pt.speed_start(1,1,0)
smoke.direction_range(-90,-90)

smoke.radius(0,10)
smoke.angle(0,0.001)
smoke._index=smoke_pt._index


alarm[0]=2
 mp_potential_settings(90,20,1.5,false)
 mp_potential_path_object(path,o_smoke_Dir.x,o_smoke_Dir.y,25,2,oWall)

 //path_set_kind(path,1)

