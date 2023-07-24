debug = true
show_debug_overlay(debug)


sys= new pulse_emitter()

// Just do set_path to add a Path to your emitter
sys.set_path(Path2)


sys.part_type.set_speed(-3,-3,0)
sys.part_type.set_size(.15,.15,0,0)
sys.part_type.set_life(200,200).set_color(c_aqua,c_fuchsia)


sys.set_radius(-50,50)
//sys.set_mask(0,0.001)
sys.set_direction_range(-90,-90)

on=false

