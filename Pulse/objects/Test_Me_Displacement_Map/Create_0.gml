debug = true
show_debug_overlay(debug)


#region Same code as before
sys= new pulse_emitter("sys_1","particle")

shockwave=  new pulse_emitter("sys_2","white_wave")

var _particle =  pulse_fetch_particle("particle")
_particle	.set_speed(2,15,0)
			.set_life(80,100)
			.set_size(.2,.5,-.0005)
			.set_alpha(1,.5,0)
			.set_shape(pt_shape_disk)
			.set_gravity(.2,270)
			.set_orient(0,0,0,0,true)


//.set_blend(true)
sys.boundary=PULSE_BOUNDARY.NONE
sys.set_radius(50,200)


var wave =  pulse_fetch_particle("white_wave")

wave.set_color(c_white)
.set_alpha(.5,.2,0)
.set_life(30,35)
.set_blend(true)
.set_speed(1,15,-.2)
.set_shape(pt_shape_sphere)
.set_size(.01,.2,-.01,0)
.set_scale(2,.3)





shockwave.set_stencil(ac_Shape,"Splash")
shockwave.set_radius(20,60)
#endregion

// This code will generate 5 Perlin noise maps with Dragonite's Macaw 
// Will change the particle's speed by the value of the texture
// and will color the particle in an HSV range from aqua to blue
var i=0
cache=[]
repeat(5)
{
	var _map = macaw_generate(64,64,8,255);

	var dis = sys.set_displacement_map(_map);
//	var col = sys.set_color_map(_map);

	dis.set_speed(1,[1,10])
	dis.set_color(c_green,c_blue,PULSE_COLOR.A_TO_B_HSV)
	//col.displace.color_blend = .5
	//sys.set_displace_uv_scale(1+i,1)
	//You can emit it from a Path too
	//sys.set_path(Path3)
	cache[i]= new pulse_cache(sys, sys.pulse(2000,x,y,true))
	
	i++
}




