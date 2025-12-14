//////////////////////////
//////////////////////////
///////   PARTICLE  ///////
//////////////////////////
//////////////////////////
	with DBG_Particle
	{
		active = 0
	}
	active = 1

this = dbg_view($"Particle: {particle.name}",true,30,330,300,700)

active=1
active_spr = s_pulse_star
ref_active = ref_create(self,"active")
ref_active_spr = ref_create(self,"active_spr")
active_func = function(){
	
	with DBG_Particle
	{
		active = 0
	}
	DBG_General.p_l = array_find_index(DBG_General.particles,function(value){ return value == id })		
	active=1
}
ref_active_func = ref_create(self,"active_func")


dbg_section("File",true)

dbg_text($"Particle: {particle.name}")

dbg_sprite_button(ref_active_func,ref_active_spr,ref_active)
dbg_same_line()
dbg_button("Make Active",ref_active_func)


p_newname = string(particle.name)+"_clone"

dbg_text_separator("Clone")

dbg_text_input(ref_create(self,"p_newname"),"New Particle's name")

dbg_button("Clone",function(){
	var _part = pulse_clone_particle(particle,p_newname),
	_inst = instance_create_layer(0,0,layer,DBG_Particle,{particle: _part})
	array_push(DBG_General.particles,_inst)
	DBG_General.p_l = array_length(DBG_General.particles)-1
})
dbg_button("Destroy",function(){
	
	array_delete(DBG_General.particles, array_find_index(DBG_General.particles,function(_element, _index){return _element==id}),1)
	DBG_General.p_l = array_length(DBG_General.particles)-1
	with DBG_Emitter
	{	
		if particle_instance == other.id
		{
			if DBG_General.p_l == -1 
			{
				particle_instance =  undefined
			}else
			{
				particle_instance = DBG_General.particles[DBG_General.p_l]
				emitter.set_particle_type(particle_instance.particle)
			}
		}
	}
	pulse_destroy_particle(particle.name)
	delete particle
	dbg_view_delete(this)
	instance_destroy()
})
dbg_button("Export",function(){
	pulse_export_particle(particle,"none")})
dbg_button("Randomize",function(){

		//Life
		p_life = [irandom_range(10,100),irandom_range(10,100)]
		particle.set_life(p_life[0],p_life[1])
		//Speed
		p_speed[0] = random(10)
		p_speed[1] = random(10)
		particle.set_speed(p_speed[0],p_speed[1],0,0)

		//Final Speed
		if choose(true,false)
		{
			p_final_speed[0] = random(20)
			p_final_speed[1] = choose(2,0,1)
			p_final_speed[2] = irandom_range(0,5000)
			var _step = p_final_speed[2] >= p_life[1] || p_final_speed[2] == 0 ? undefined : max(1,p_final_speed[2])
			particle.set_final_speed(p_final_speed[0],p_final_speed[1])
			p_speed[0] = particle.speed[0]
			p_speed[1] = particle.speed[1]
			p_speed[2] = particle.speed[2]
			p_speed[3] = particle.speed[3]
		}

		//Direction
		p_dir[0]= random(360)
		p_dir[1]= random(360)
		p_dir[2]= choose(0,0,0,random(.3))
		p_dir[3]= choose(0,0,0,random(20))
		particle.set_direction(p_dir[0],p_dir[1],p_dir[2],p_dir[3])	

		//Gravity
		p_grav[0]= random(.5)
		p_grav[1]= random(360)
		particle.set_gravity(p_grav[0],p_grav[1])

		//Orient
		p_orient[0] = random(360)
		p_orient[1] = random(360)
		p_orient[2] = choose(0,0,0,random(.3))
		p_orient[3] = choose(0,0,0,random(20))
		p_orient[4] = choose(true,false)
		particle.set_orient(p_orient[0],p_orient[1],p_orient[2],p_orient[3],p_orient[4])

		//Shape or Sprite
		if  choose(true,false)
		{
			//Shape
			p_shape =choose(pt_shape_circle,pt_shape_cloud,
			pt_shape_disk,pt_shape_explosion,pt_shape_flare,pt_shape_line,pt_shape_pixel,pt_shape_ring,
			pt_shape_smoke,pt_shape_snow,pt_shape_spark,pt_shape_star,pt_shape_sphere,pt_shape_square)
			particle.set_shape(p_shape)
		}else{
			//Sprite
			p_sprite =choose(flame_01,s_hand,Smoke_center___200_200_,p_arrow_normal,s_arrow)
			p_anim =  choose(true,false)
			p_stretch =  choose(true,false)
			p_sp_random =  choose(true,false)
			p_sp_frame = 0
			particle.set_sprite(p_sprite,p_anim,p_stretch,p_sp_random,p_sp_frame)
		}

		p_scale[0] = random_range(.1,1.5)
		p_scale[1] = random_range(.1,1.5)
		particle.set_scale(p_scale[0],p_scale[1])

		//Size

		p_size_split = choose(true,false)

		p_size[0] = random(1.5)
		p_size_y[0] = random(1.5)
		p_size[1] = random(1.5)
		p_size_y[1] = random(1.5)
		p_size[2] = choose(0,0,0,random(.05))
		p_size_y[2] = choose(0,0,0,random(.05))
		p_size[3] = choose(0,0,0,random(.05))
		p_size_y[3] = choose(0,0,0,random(.05))

			if p_size_split
			{
				particle.set_size([p_size[0],p_size_y[0]],[p_size[1],p_size_y[1]],[p_size[2],p_size_y[2]],[p_size[3],p_size_y[3]])
			
			}else
			{
				particle.set_size(p_size[0],p_size[1],p_size[2],p_size[3])
			}

		p_color[0]= choose(c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black)
		p_color[1]= choose(undefined,c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black)
		p_color[2]= choose(undefined,c_white,c_aqua,c_teal,c_blue,c_navy,c_purple,c_fuchsia,c_red,c_maroon,c_orange,c_yellow,c_olive,c_green,c_ltgrey,c_silver,c_grey,c_dkgrey,c_black)
		p_blend = 	choose(true,false)
			particle.set_color(p_color[0],p_color[1],p_color[2])
			particle.set_blend(p_blend)
	
		p_alpha[0]=random(1)
		p_alpha[1]=random(1)
		p_alpha[2]=random(1)
			p_alpha[1] = p_alpha[1]<0 ? -1 : p_alpha[1]
			p_alpha[2] = p_alpha[2]<0 ? -1 : p_alpha[2]
			particle.set_alpha(p_alpha[0],p_alpha[1],p_alpha[2])	
			
		if particle.subparticle != undefined
		{
			particle.subparticle.update()
		}
})

dbg_section("Life",false)	

p_life = [30,50]
dbg_text_input(ref_create(self,"p_life",0),"Life Minimum","i")
dbg_text_input(ref_create(self,"p_life",1),"Life Maximum","i")


dbg_button("Apply",function(){
	particle.set_life(p_life[0],p_life[1])			
})

dbg_section("Speed Settings",false)	
p_speed = [1,2,0,0]
dbg_text_separator("Speed")
dbg_text_input(ref_create(self,"p_speed",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_speed",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_speed",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_speed",3),"Wiggle","f")
dbg_button("Apply",function(){
	particle.set_speed(p_speed[0],p_speed[1],p_speed[2],p_speed[3])			})

dbg_text_separator("Final Speed")
dbg_text("Change the acceleration parameter by \n determining the final speed of the particle")
p_final_speed = [0,0,0]
dbg_text_input(ref_create(self,"p_final_speed",0),"Final Speed","f")
dbg_drop_down(ref_create(self,"p_final_speed",1),[2,0,1],["Average","Slowest, Shortest Lived","Fastest, Longest Lived"],"Mode")
dbg_text_input(ref_create(self,"p_final_speed",2),"Steps","f")

dbg_button("Apply",function(){
	
	var _step = p_final_speed[2] >= p_life[1] || p_final_speed[2] == 0 ? undefined : max(1,p_final_speed[2])
	particle.set_final_speed(p_final_speed[0],p_final_speed[1])
	p_speed[0] = particle.speed[0]
	p_speed[1] = particle.speed[1]
	p_speed[2] = particle.speed[2]
	p_speed[3] = particle.speed[3]
})

dbg_section("Direction Settings",false)	
dbg_text_separator("Direction")
p_dir = [1,2,0,0]
dbg_text_input(ref_create(self,"p_dir",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_dir",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_dir",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_dir",3),"Wiggle","f")
dbg_button("Apply",function(){
	particle.set_direction(p_dir[0],p_dir[1],p_dir[2],p_dir[3])			})
	
dbg_text_separator("Arc Trajectory")
dbg_text("Alters the direction change per step. 0 = Linear, 1 = full circle ")
p_arc = [0,0,0]
dbg_text_input(ref_create(self,"p_arc",0),"Total arc","f")
dbg_drop_down(ref_create(self,"p_arc",1),[2,0,1],["Average","Slowest, Shortest Lived","Fastest, Longest Lived"],"Mode")
dbg_text_input(ref_create(self,"p_arc",2),"Steps","f")

dbg_button("Apply",function(){
	
	var _step = p_arc[2] == 0 ? undefined : max(1,p_arc[2])
	particle.set_arc_trajectory(p_arc[0],p_arc[1],p_arc[2])

	p_direction[2] = particle.direction[2]

})


dbg_text_separator("Gravity")
p_grav = [.24,270]
dbg_text_input(ref_create(self,"p_grav",0),"Acceleration","f")
dbg_slider(ref_create(self,"p_grav",1),0,360,"Direction")
dbg_button("Apply",function(){
	particle.set_gravity(p_grav[0],p_grav[1])						})

dbg_section("Orientation Settings",false)	
dbg_text_separator("Orientation")
p_orient = [1,2,0,0,true]
dbg_text_input(ref_create(self,"p_orient",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_orient",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_orient",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_orient",3),"Wiggle","f")
dbg_checkbox(ref_create(self,"p_orient",4),"Relative to direction")
dbg_button("Apply",function(){
	particle.set_orient(p_orient[0],p_orient[1],p_orient[2],p_orient[3],p_orient[4])			})
	
dbg_section("Sprite Settings",false)

dbg_text_separator("Shape")
p_shape = pt_shape_circle
dbg_drop_down(ref_create(self,"p_shape"),[pt_shape_circle,pt_shape_cloud,
pt_shape_disk,pt_shape_explosion,pt_shape_flare,pt_shape_line,pt_shape_pixel,pt_shape_ring,
pt_shape_smoke,pt_shape_snow,pt_shape_spark,pt_shape_star,pt_shape_sphere,pt_shape_square],
["Circle","Cloud","Disk","Explosion","Flare","Line","Pixel","Ring","Smoke","Snow","Spark","Star","Sphere","Square",])

dbg_button("Apply",function(){	particle.set_shape(p_shape)	})

dbg_text_separator("Sprite")
/// Sprite selection
p_sprite = flame_01
p_sprite_ref = ref_create(self,"p_sprite")
dbg_drop_down(p_sprite_ref,[flame_01,s_hand,Smoke_center___200_200_,p_arrow_normal,s_arrow],["Flame","Hand","Smoke","Arrow-Volume","Arrow"])

/// Sprite Properties

p_anim = false
p_stretch = false
p_sp_random = true
p_sp_frame = 0
p_sp_frame_ref = ref_create(self,"p_sp_frame")
dbg_checkbox(ref_create(self,"p_anim"),"Animate")
dbg_checkbox(ref_create(self,"p_stretch"),"Stretch animation over Life")
dbg_checkbox(ref_create(self,"p_sp_random"),"Random Frame/SubImage")
dbg_text_input(p_sp_frame_ref,"Frame / SubImage","i")

dbg_sprite(p_sprite_ref,p_sp_frame_ref,"Sprite")
dbg_button("Apply",function(){
	particle.set_sprite(p_sprite,p_anim,p_stretch,p_sp_random,p_sp_frame)
						})


dbg_section("Size Settings",false)

dbg_text_separator("Scale")

p_scale = [1,1]

dbg_text_input(ref_create(self,"p_scale",0),"Scale X","f")
dbg_text_input(ref_create(self,"p_scale",1),"Scale Y","f")
dbg_button("Apply",function(){
	particle.set_scale(p_scale[0],p_scale[1])
})

dbg_text_separator("Size (Relative)")
dbg_text("Sets the size of a particle relative to its own size, where 1==100% size ")
p_size = [1,2,0,0]
dbg_text_input(ref_create(self,"p_size",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_size",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_size",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_size",3),"Wiggle","f")

p_size_split = false
dbg_checkbox(ref_create(self,"p_size_split"),"Split into X and Y dimensions")

dbg_text_separator("Size - Y")
p_size_y = [1,2,0,0]
dbg_text_input(ref_create(self,"p_size_y",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_size_y",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_size_y",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_size_y",3),"Wiggle","f")

dbg_button("Apply",function(){
	if p_size_split
	{
		particle.set_size([p_size[0],p_size_y[0]],[p_size[1],p_size_y[1]],[p_size[2],p_size_y[2]],[p_size[3],p_size_y[3]])
			
	}else
	{
		particle.set_size(p_size[0],p_size[1],p_size[2],p_size[3])
	}
						})
				
dbg_text_separator("Size (Absolute)")
dbg_text("Sets the size of a particle in absolute pixel size")
p_size_abs = [1,2,0,0]
dbg_text_input(ref_create(self,"p_size_abs",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_size_abs",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_size_abs",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_size_abs",3),"Wiggle","f")

p_size_abs_split = false
dbg_checkbox(ref_create(self,"p_size_abs_split"),"Split into X and Y dimensions")
p_size_abs_mode = 0

dbg_drop_down(ref_create(self,"p_size_abs_mode"),[0,1,2],["Average","Shortest Side","Largest Side"],"Mode")

dbg_text_separator("size_abs - Y")
p_size_abs_y = [1,2,0,0]
dbg_text_input(ref_create(self,"p_size_abs_y",0),"Range Minimum","f")
dbg_text_input(ref_create(self,"p_size_abs_y",1),"Range Maximum","f")
dbg_text_input(ref_create(self,"p_size_abs_y",2),"Acceleration","f")
dbg_text_input(ref_create(self,"p_size_abs_y",3),"Wiggle","f")

dbg_button("Apply",function(){
	if p_size_abs_split
	{
		particle.set_size_abs([p_size_abs[0],p_size_abs_y[0]],[p_size_abs[1],p_size_abs_y[1]],[p_size_abs[2],p_size_abs_y[2]],[p_size_abs[3],p_size_abs_y[3]],p_size_abs_mode)
			
	}else
	{
		particle.set_size_abs(p_size_abs[0],p_size_abs[1],p_size_abs[2],p_size_abs[3],p_size_abs_mode)
	}
})
	
dbg_text_separator("Set Final Size")
dbg_text("Sets the size acceleration of a particle to approximate a size in relative scale terms")
p_size_final = [0,0,undefined]
p_size_final_split = false
p_size_final_mode = 0
	dbg_checkbox(ref_create(self,"p_size_final_split"),"Split into X and Y dimensions")
	dbg_text_input(ref_create(self,"p_size_final",0),"Size X","f")
	dbg_text_input(ref_create(self,"p_size_final",1),"Size Y","f")
dbg_drop_down(ref_create(self,"p_size_final_mode"),[2,0,1],["Average","Shortest Side","Largest Side"],"Mode")
	dbg_button("Apply",function(){
	if p_size_final_split
	{
		particle.set_final_size([p_size_final[0],p_size_final[1]],p_size_final_mode,p_size_final[2])
			
	}else
	{
		particle.set_final_size(p_size_final[0],p_size_final_mode,p_size_final[2])
	}
						})

dbg_section("Color",false)

p_color = [c_blue,c_aqua,c_white]

dbg_colour(ref_create(self,"p_color",0),"Color 1")
dbg_colour(ref_create(self,"p_color",1),"Color 2")
dbg_colour(ref_create(self,"p_color",2),"Color 3")
p_blend = false
dbg_checkbox(ref_create(self,"p_blend"),"Additive Blending")

dbg_button("Apply",function()
{
	particle.set_color(p_color[0],p_color[1],p_color[2])
	particle.set_blend(p_blend)
})

dbg_text_separator("Alpha")

p_alpha = [1,1,0]


dbg_slider(ref_create(self,"p_alpha",0),0,1,"Alpha Start",.1)

dbg_text("Use -.1 to set as undefined ⮧")
dbg_slider(ref_create(self,"p_alpha",1),-.1,1,"Alpha Mid Point",.1)
dbg_slider(ref_create(self,"p_alpha",2),-.1,1,"Alpha End",.1)
dbg_button("Apply",function()
{
	p_alpha[1] = p_alpha[1]<0 ? -1 : p_alpha[1]
	p_alpha[2] = p_alpha[2]<0 ? -1 : p_alpha[2]
	particle.set_alpha(p_alpha[0],p_alpha[1],p_alpha[2])
})

dbg_section("Time and Space Scaling",false)
dbg_text("It changes the properties of the particle relative to a factor.\n Time scaling changes the timing \n(life, speed, acceleration, gravity) while\n Space changes the trajectory of the\n particle as if it was zoomed in or out")
p_time_factor = 1
dbg_text_input(ref_create(self,"p_time_factor"),"Time Factor","f")
dbg_button("Apply",function()
{
	particle.scale_time_abs(p_time_factor)
})
p_space_factor = [1,true,true]
dbg_text_input(ref_create(self,"p_space_factor",0),"Space Factor","f")
dbg_checkbox(ref_create(self,"p_space_factor",1),"Shrink Particle")
dbg_checkbox(ref_create(self,"p_space_factor",2),"Alter Gravity")
dbg_button("Apply",function()
{
	particle.scale_space_abs(p_space_factor[0],p_space_factor[1],p_space_factor[2])
})

dbg_section("Sub Particles",false)

p_step=1
p_death=1
p_collision=1
dbg_text_separator("Step")
dbg_text("Applies the active Particle")
dbg_text_input(ref_create(self,"p_step"),"Step particles amount","i")
dbg_button("Apply",function(){
	if DBG_General.particles[DBG_General.p_l] == id{ return}
	particle.set_step_particle(p_step,DBG_General.particles[DBG_General.p_l].particle)				
	})

dbg_text_separator("Death")
dbg_text("Applies the active Particle")
dbg_text_input(ref_create(self,"p_death"),"Death particles amount","i")
dbg_button("Apply",function(){
	if DBG_General.particles[DBG_General.p_l] == id{ return}
	particle.set_death_particle(p_death,DBG_General.particles[DBG_General.p_l].particle)		
	})

dbg_text_separator("Death on Collision")
dbg_text("Applies the active Particle")
dbg_text_input(ref_create(self,"p_collision"),"Death particles amount","i")
dbg_button("Apply",function(){
	if DBG_General.particles[DBG_General.p_l] == id {return}
	particle.set_death_on_collision(p_collision,DBG_General.particles[DBG_General.p_l].particle)					
	})
	
	function refresh()
{
	p_life[0] = particle.life[0]
	p_life[1] = particle.life[1]
	p_speed[0] =  particle.speed[0]
	p_speed[1] =  particle.speed[1]
	p_speed[2] =  particle.speed[2]
	p_speed[3] =  particle.speed[3]
	p_dir[0] =  particle.direction[0]
	p_dir[1] =  particle.direction[1]
	p_dir[2] =  particle.direction[2]
	p_dir[3] =  particle.direction[3]

	p_grav[0] = particle.gravity[0]
	p_grav[1] = particle.gravity[1]

	p_orient[0] = particle.orient[0]
	p_orient[1] = particle.orient[1]
	p_orient[2] = particle.orient[2]
	p_orient[3] = particle.orient[3]
	p_orient[4] = particle.orient[4]

	p_scale[0] = particle.scale[0]
	p_scale[1] = particle.scale[1]

	p_size[0] = particle.size[0]
	p_size_y[0]= particle.size[1]
	p_size[1] = particle.size[2]
	p_size_y[1]= particle.size[3]
	p_size[2] = particle.size[4]
	p_size_y[2]= particle.size[5]
	p_size[3] = particle.size[6]
	p_size_y[3]= particle.size[7]
}
refresh()