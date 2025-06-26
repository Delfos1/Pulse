//Create the particle
show_debug_overlay(true)
arrow = pulse_make_particle("arrow_diffuse")

arrow.set_sprite(p_arrow_diffuse,false,false,true).set_speed(2,2,0,0).set_life(500,500).set_orient(0,0,0,0,false)
.set_size(1,1).set_color(c_white)

//Create the emitter
emitter_diffuse = new pulse_emitter("diffuse_system","arrow_diffuse")

//Simple emitter, no edge
emitter_diffuse.set_direction_range(0,0).set_radius(100,100)
emitter_diffuse.set_distribution_v(PULSE_DISTRIBUTION.EVEN,8)
emitter_diffuse.boundary = PULSE_BOUNDARY.NONE

//Then we link the frame of the sprite to the particle direction
emitter_diffuse.set_distribution_frame(PULSE_DISTRIBUTION.LINKED,[ac_Arrow_links,"frame"],PULSE_LINK_TO.DIRECTION)

