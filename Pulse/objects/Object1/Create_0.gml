show_debug_overlay(true)
/*
part_sys=part_system_create()
part_type=part_type_create()

part_type_shape(part_type,pt_shape_disk)

part_type_orientation(part_type,0,0,0,0,true)
part_type_size(part_type,.1,.15,0,0)

//part_type_blend(part_type,true)*/

sys= new part_pulse_emitter("sandwich","fire")
particle_fire= pulse_particle_get_ID("fire")
system = pulse_system_get_ID("sandwich")

part_type_color3	(particle_fire,c_white,c_aqua,c_blue)
part_type_sprite	(particle_fire,s_part_fire,0,0,false)
part_type_size		(particle_fire,.3,.3,0.04,0)
part_type_life		(particle_fire,15,30)
part_type_speed		(particle_fire,10,10,-.1,0)
part_type_blend		(particle_fire,true)

particle_smoke_struct			=	new pulse_particle("smoke") 
particle_smoke					=	particle_smoke_struct._part_type
particle_smoke_struct._shape	=	pt_shape_cloud
particle_smoke_struct.reset()

part_type_gravity	(particle_smoke,.8,90)
part_type_color2	(particle_smoke,c_blue,c_black)
part_type_size		(particle_smoke,.5,.7,.2,0)
part_type_alpha2	(particle_smoke,.6,0)
part_type_death		(particle_fire,2,particle_smoke)


//sys.attract(2,5,80,false)
//sys.fill_shape(10,10,60,true,PULSE_MODE.SHAPE_FROM_SHAPE)
sys.radius(60,60)
//sys.angle(-150,180)
//sys._direction_mode=PULSE_RANDOM.GAUSSIAN
//sys.speed_start(0,0)
sys.shape(ac_Shape,"Elipse")
sys._add_to_shape+=90

