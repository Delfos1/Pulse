sys.outward_shape(3,4,20,30,true,PULSE_MODE.SHAPE_FROM_POINT)
sys.tween_shape(ac_Shape,"Star",ac_Shape,"Star")
global.pulse.part_types[0].color(c_teal,c_blue)
sys.outward_shape(3,4,.02,20,30,true,PULSE_MODE.SHAPE_FROM_POINT)
sys.tween_stencil(ac_Shape,"Star",ac_Shape,"Star")
sys._part_type.color(c_teal,c_blue)
>>>>>>> Stashed changes
shockwave.pulse(200,x,y)