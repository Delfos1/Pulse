function NM_start() {
	globalvar NMlights,NMcolor,NMamb,NMdif,NMnorm,unorm,uamb,ulights,ucolor,uangle,uNumEnabled;
	NMlights = array_create(24, 0);
	NMcolor = array_create(24, 0);
	NMamb = c_black;
	var width = room_width;
	var height = room_height;
	NMdif = surface_create(width, height);
	NMnorm = surface_create(width, height);
	unorm = shader_get_sampler_index(sh_normal,"norm");
	uamb = shader_get_uniform(sh_normal,"ambiance");
	ulights = shader_get_uniform(sh_normal,"lights");
	ucolor = shader_get_uniform(sh_normal,"lcolor");
	uNumEnabled = shader_get_uniform(sh_normal,"numEnabled");
	uangle = shader_get_uniform(sh_rotate,"angle");
}


/// @description NM_set_light(light id,x,y,range,color)
/// @param light id
/// @param x
/// @param y
/// @param range
/// @param color
function NM_set_light(light_id,X,Y,Z, _range,_color) {
	NMlights[light_id*4] = X;
	NMlights[light_id*4+1] = Y;
	NMlights[light_id*4+2] = Z;
	NMlights[light_id*4+3] = _range;
	NMcolor[light_id*3] = colour_get_red(_color)/255;
	NMcolor[light_id*3+1] = colour_get_green(_color)/255;
	NMcolor[light_id*3+2] = colour_get_blue(_color)/255;
}

/// @description NM_normal(add,rotation)
/// @param add
/// @param rotation
function NM_normal(_add, _rotation) {
	if _add
	{
		if (!surface_exists(NMnorm))
		{
			NMnorm = surface_create(room_width, room_height);
		}
		shader_set(sh_rotate)
		shader_set_uniform_f(uangle,-_rotation)
		surface_set_target(NMnorm)
	
		global.renderPass = RP_NORMAL;
		draw_clear_alpha(0,0);
	}
	else
	{
	    shader_reset()
	    surface_reset_target()
	}
}
	
/// @description NM_diffuse(add)
/// @param add

function NM_diffuse(_add) {
	if _add
	{
		if (!surface_exists(NMdif))
		{
			NMdif = surface_create(room_width, room_height);
		}
		surface_set_target(NMdif)
		global.renderPass = RP_DIFFUSE;
		draw_clear_alpha(0,0);
	}
	else
	{
	    surface_reset_target()
	}


}
	
/// @description NM_draw(x,y)
/// @param x
/// @param y
function NM_draw(x, y) {
	//draw_clear_alpha(0,0);
	shader_set(sh_normal)
	texture_set_stage(unorm,surface_get_texture(NMnorm))
	shader_set_uniform_f_array(ulights,NMlights)
	shader_set_uniform_f_array(ucolor,NMcolor)
	shader_set_uniform_f(uamb,colour_get_red(NMamb)/255,colour_get_green(NMamb)/255,colour_get_blue(NMamb)/255)
	shader_set_uniform_i(uNumEnabled, min(numLights,8));
	draw_surface(NMdif,x,y)

	shader_reset()
}

function NM_reset_default_shader() {
	if (global.renderPass != RP_DIFFUSE)
	{
		shader_reset();
	}
}

/// @description NM_set_ambiance(color)
/// @param color
function NM_set_ambiance(_color) {
	NMamb = _color;
}

function NM_set_default_shader() {
	if (global.renderPass == RP_NORMAL)
	{
		shader_set(sh_defaultNormal);
	}
}

/// @description NM_wiggle(light id,range,radius,time)
/// @param light id
/// @param range
/// @param radius
/// @param time
function NM_wiggle( light_id, range, radius, time) {

	NMlights[light_id*3+3] = range+dcos(time)*radius;

}

function Init() {
#macro RP_DIFFUSE 0
#macro RP_NORMAL 1
	global.renderPass = RP_DIFFUSE;
#macro AMBIANCE_R 0 * 1.75
#macro AMBIANCE_G 0 * 1.75
#macro AMBIANCE_B 0 * 1.75
	global.playerLightColors[0] = 255;
	global.playerLightColors[1] = 255;
	global.playerLightColors[2] = 255;
}