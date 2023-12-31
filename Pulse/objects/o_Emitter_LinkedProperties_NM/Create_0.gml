show_debug_overlay(true)
Init();
NM_start()//Setup for required variables
NM_set_ambiance(make_colour_rgb(AMBIANCE_R,AMBIANCE_G,AMBIANCE_B))//Set ambiance color

numLights = 1;
dynamicLights = ds_list_create();
mouse_height = -100


//Create the particle

arrow = pulse_make_particle("arrow")

arrow.set_sprite(p_arrow_diffuse,false,false,false).set_speed(.5,.5,0,0).set_life(500,500).set_orient(0,0,0,0,false).set_size(1,1).set_color(c_white)


system = pulse_make_system("system").set_draw(false)
//Create the emitter
emitter = new pulse_local_emitter("system","arrow")

//Simple emitter, no edge
emitter.set_direction_range(180,180).set_radius(0,0)
//emitter.set_distribution_u(PULSE_DISTRIBUTION.EVEN,8)
emitter.force_to_edge = PULSE_TO_EDGE.NONE
emitter.form_path(Path3)

//Then we link the frame of the sprite to the particle direction
emitter.set_distribution_frame(PULSE_DISTRIBUTION.LINKED,[ac_Arrow_links,"frame"],PULSE_LINK_TO.DIRECTION)

