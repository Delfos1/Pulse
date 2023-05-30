debug = false
show_debug_overlay(debug)


// Welcome to Pulse!
// This is a Path Emitter, you can supply a path, a system and a particle type

sys= new part_pulse_emitter()
sys._path_a=Path1



// Particle/System ID s get allocated in global.pulse._systems and global.pulse.part_types respectively.
// If unnamed they get a default name assigned. You can change default values in the Dafault_config script.
// They can be accessed by their array number.
sys._part_type.speed_start(0.6,3,0.05)
sys._part_type.life(30,50)

radius_max = 30
sys.radius(0,radius_max)
sys.mask(0,0.001)
sys.direction_range(0,0)

on=false

