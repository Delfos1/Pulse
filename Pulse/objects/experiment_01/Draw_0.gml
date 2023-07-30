if emitter.displacement_map == undefined
{

	_map = buffer_from_sprite(_64_pol,17)
	var white = make_color_hsv(170,1,255)
	emitter.set_displacement_map(_map).set_displace_speed(1).set_displace_life(.6).set_displace_color(c_blue,white,PULSE_COLOR.A_TO_B_HSV)
	emitter3.set_displacement_map(_map).set_displace_speed(1).set_displace_life(.6).set_displace_color(c_blue,white,PULSE_COLOR.A_TO_B_HSV)
	emitter_2.set_displacement_map(_map).set_displace_color(c_blue,white,PULSE_COLOR.A_TO_B_HSV).set_displace_speed(.7)
}


if (!surface_exists(surf_Blobs)) {
	var width = room_width
	var height = room_height
	surface_depth_disable(true);// Disabel depth buffer (only used for 3D,so this saves memory)
	surf_Blobs = surface_create(width, height);
	surf_Blobs_back = surface_create(width, height);
	surface_depth_disable(false);
};
//Surface set
surface_set_target(surf_Blobs);
draw_clear_alpha(c_black,0);

//Draw Color

gpu_set_alphatestenable(true);
gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha,bm_src_alpha,bm_one)

part_system_drawit(global.pulse.systems.front.index);

//Surface set

surface_reset_target();
surface_set_target(surf_Blobs_back);
gpu_set_colorwriteenable(true,true,true,true);//Enables color channels-alpha
draw_clear_alpha(c_black,0);
gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha,bm_src_alpha,bm_one)
part_system_drawit(global.pulse.systems.back.index);

//Reset all variables
gpu_set_colorwriteenable(true,true,true,true);//Enables color channels-alpha
surface_reset_target();
gpu_set_alphatestenable(false);


//gpu_set_alphatestref(limit);
shader_set(shd_Blob);
draw_surface(surf_Blobs_back,0,0);
draw_surface(surf_Blobs,0,0);
shader_reset();

	