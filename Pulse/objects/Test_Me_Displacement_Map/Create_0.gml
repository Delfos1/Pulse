debug = true
show_debug_overlay(debug)


#region Same code as before
sys= new pulse_emitter("sys_1","particle")

shockwave=  new pulse_emitter("sys_2","white_wave")

global.pulse.part_types.particle.set_speed(15,65,-1)
.set_life(200,200)
.set_size(1.2,1.8,-.005)
.set_alpha(1,.5,0)
.set_shape(pt_shape_flare)
.set_gravity(2,270)
.set_orient(0,360,.2,0,false)
//.set_blend(true)
sys.force_to_edge=PULSE_TO_EDGE.NONE
sys.set_radius(50,200).set_mask(.1,.4)
//sys.distr_along_v_coord = PULSE_RANDOM.ANIM_CURVE
sys.distr_along_u_coord = PULSE_RANDOM.ANIM_CURVE

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
	sys.set_displace_color(c_red,c_yellow,PULSE_COLOR.A_TO_B_RGB)
	sys.set_displace_uv_scale(1+i,1)
	//You can emit it from a Path too
	//sys.set_path(Path3)
	cache[i]= sys.pulse(2000,x,y,true)
	i++
}




