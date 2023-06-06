debug = false
show_debug_overlay(debug)


// Welcome to Pulse!
// This is a Path Emitter, you can supply a path, a system and a particle type

sys= new pulse_emitter()
sys.path_a=Path1
//sys.stencil(ac_Shape,"Letter_P")
//sys.force_to_edge=true

// Particle/System ID s get allocated in global.pulse._systems and global.pulse.part_types respectively.
// If unnamed they get a default name assigned. You can change default values in the Dafault_config script.
// They can be accessed by their array number.
sys._part_type.set_speed_start(0.6,.6,0.005)
sys._part_type.set_size(.05,.05,0,0)
sys._part_type.set_life(30,50)

radius_max = 30
sys.set_radius(0,radius_max)
sys.set_mask(0,0.001)
sys.set_direction_range(0,0)

on=false

