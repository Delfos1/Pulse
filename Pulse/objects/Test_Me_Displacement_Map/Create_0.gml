debug = true
show_debug_overlay(debug)


#region Same code as before
sys= new pulse_emitter("sys_1","particle")

shockwave=  new pulse_emitter("sys_2","white_wave")

global.pulse.part_types.particle.set_speed(0.6,3,-0.05).set_life(20,50).set_size(0.1,0.35,-.002)

var wave = global.pulse.part_types.white_wave

wave.set_color(c_white)
.set_alpha(.5,.2,0)
.set_life(30,35)
.set_blend(true)
.set_speed(15,15,-.2)
.set_shape(pt_shape_sphere)
.set_size(.5,.5,-.01,0)
.set_scale(2,.3)



sys.set_radius(20,300)

shockwave.set_stencil(ac_Shape,"Splash")
shockwave.set_radius(20,60)
#endregion

// This code will generate 5 Perlin noise maps with Dragonite's Macaw 
// Will change the particle's speed by the value of the texture
// and will color the particle in an HSV range from aqua to blue
var i=0
repeat(5)
{
	var _map = macaw_generate(128,128,8,255);

	sys.set_displacement_map(_map);
	sys.set_color_map(_map);
	sys.set_displace_speed(1)
	sys.set_displace_color(c_aqua,c_blue,PULSE_COLOR.A_TO_B_HSV)

	cache[i]= sys.pulse(2000,x,y,true)
	i++
}

//You can emit it from a Path too
//sys.set_path(Path3)


