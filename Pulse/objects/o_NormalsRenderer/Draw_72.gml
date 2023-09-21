/// @description Diffuse
draw_set_alpha(1);
draw_set_color(c_white);

//set lights
var playerLightSize = 200;

NM_set_ambiance(make_colour_rgb(AMBIANCE_R,AMBIANCE_G,AMBIANCE_B))//Set ambiance color

numLights = 1;
NM_set_light(other.numLights++, mouse_x, mouse_y,mouse_height, playerLightSize,c_white);//#805099

with (o_NormalLight)
{
	NM_set_light(other.numLights++, x, y, _depth, radius, lightColor);
}
	
NM_diffuse(true);

p_smoke.set_sprite(Smoke_up___200_200_,true,true,true).set_color(c_gray,c_dkgray)
system.draw_it()
NM_diffuse(false);