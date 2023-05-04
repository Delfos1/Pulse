show_debug_overlay(true)

sys= new part_pulse_emitter()

global.pulse.part_types[0].speed_start(.5,1,-.02)
global.pulse.part_types[0].life(30,50)

sys.shape(ac_Shape,"Star")
sys.radius(0,150)

