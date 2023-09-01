debug = true
show_debug_overlay(debug)


#region Same code as before
sys= new pulse_local_emitter("sys_1","particle")

shockwave=  new pulse_local_emitter("sys_2","white_wave")

global.pulse.part_types.particle.set_speed(10,15,-.21)
.set_life(80,100)
.set_size(1.2,1.8,-.0005)
.set_alpha(1,.5,0)
.set_shape(pt_shape_disk)
.set_gravity(.2,270)
.set_orient(0,0,0,0,true)


//.set_blend(true)
sys.force_to_edge=PULSE_TO_EDGE.NONE
sys.set_radius(50,200)


var wave = global.pulse.part_types.white_wave

wave.set_color(c_white)
.set_alpha(.5,.2,0)
.set_life(30,35)
.set_blend(true)
.set_speed(15,15,-.2)
.set_shape(pt_shape_sphere)
.set_size(.5,.5,-.01,0)
.set_scale(2,.3)





shockwave.set_stencil(ac_Shape,"Splash")
shockwave.set_radius(20,60)
#endregion

// This code will generate 5 Perlin noise maps with Dragonite's Macaw 
// Will change the particle's speed by the value of the texture
// and will color the particle in an HSV range from aqua to blue
var i=0

repeat(5)
{
	var _map = macaw_generate(256,256,8,255);

	sys.set_displacement_map(_map);
	sys.set_color_map(_map);
	sys.set_displace_speed(1)
	sys.set_displace_color(c_green,c_blue,PULSE_COLOR.A_TO_B_HSV)
	sys.displace.color_blend = .5
	//sys.set_displace_uv_scale(1+i,1)
	//You can emit it from a Path too
	//sys.set_path(Path3)
	cache[i]= sys.pulse(2000,x,y,true)
	i++
}




