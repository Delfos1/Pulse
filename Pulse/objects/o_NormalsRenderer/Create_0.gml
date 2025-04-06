show_debug_overlay(true)
Init();
NM_start()//Setup for required variables
NM_set_ambiance(make_colour_rgb(AMBIANCE_R,AMBIANCE_G,AMBIANCE_B))//Set ambiance color

numLights = 1;
dynamicLights = ds_list_create();
mouse_height = -100
// Pulse stuff starts here

system = pulse_make_system("Normals_Test").set_draw(false).set_draw_oldtonew(false)
p_smoke = pulse_make_particle("smoke")

p_smoke.set_sprite(Smoke_up___200_200_,true,true,true).set_speed(3,4).set_color(c_gray,c_dkgray).set_alpha(0,.9,.7)
.set_life(200,200).set_direction(85,95).set_size(.6,.9,.003).set_orient(0,0,0,0,false)


emitter = new pulse_emitter("Normals_Test","smoke")
emitter.set_mask(.125,.375).set_radius(0,100)
emitter.alter_direction=false
emitter.force_to_edge=PULSE_TO_EDGE.NONE

