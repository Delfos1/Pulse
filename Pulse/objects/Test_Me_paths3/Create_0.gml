/*debug	 = true
on		 = false
_x = x
show_debug_overlay(debug)


pulse_convert_particles(PS_Fire)



path=path_add()

var smoke_pt = pulse_make_particle("smoke",false)

fire = new pulse_emitter("fire","Fire",8)

smoke= new pulse_emitter("smoke","smoke",1)

smoke.set_path(path)
fire.alter_direction=false
fire.force_to_edge=PULSE_TO_EDGE.NONE

smoke_pt.set_shape(pt_shape_cloud)
smoke_pt.set_size(.2,.4,.001)
smoke_pt.set_color(c_grey,c_dkgray)
smoke_pt.set_life(130,150)
smoke_pt.set_orient(0,360,0.3)
smoke_pt.set_speed(.6,.6,0)
smoke.set_direction_range(-90,-90)
smoke.force_to_edge=PULSE_TO_EDGE.NONE

smoke.set_radius(0,10)
smoke.set_mask(0,0.001)



alarm[0]=2
 mp_potential_settings(90,20,1.5,false)
 mp_potential_path_object(path,o_smoke_Dir.x,o_smoke_Dir.y,25,2,oWall)

 path_set_kind(path,1)

