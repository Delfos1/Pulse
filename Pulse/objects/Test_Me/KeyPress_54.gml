sys.outward_shape(.5,.5,-.2,20,30,true,PULSE_MODE.SHAPE_FROM_SHAPE)
sys.tween_shape(ac_Shape,"Cat_eye",ac_Shape,"Star")
sys._distribution_mode = PULSE_SHAPE.A_TO_B
global.pulse.part_types[0].color(c_purple,c_red)
shockwave.pulse(200,x,y)