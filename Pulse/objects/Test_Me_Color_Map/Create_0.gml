debug = false
show_debug_overlay(debug)


#region Same code as before
emit= new pulse_local_emitter("mario","mario_particle")

global.pulse.part_types.mario_particle.set_speed(0,0).set_life(30,30).set_size(0.1,0.1)

emit.set_radius(0,300)

#endregion

// This code will create a Mario image using a sprite as a color map. Check the Draw event


emit.form_path(Path3)


