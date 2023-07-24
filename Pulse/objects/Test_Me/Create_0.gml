debug = true
show_debug_overlay(debug)



// Welcome to Pulse!
// Create a new pulse emitter by typing new pulse_emitter
// You can supply 3 arguments: particle system, particle type and emitter size
// If you don't supply any, Pulse will create them for you.
// Pulse will create the new particle/system and assign it your string as a name.
// If you have already created them with those names, it will re use the existing ones

sys= new pulse_emitter("sys_1","particle")

shockwave=  new pulse_emitter("sys_2","white_wave")

// Particle/System ID s get allocated in global.pulse.systems and global.pulse.part_types respectively.
// If unnamed they get a default name assigned. You can change default values in the Default_config script.
// They can be accessed by their name with a dot accessor like this:

global.pulse.part_types.particle.set_speed(0.6,3,-0.05).set_life(20,50).set_size(0.1,0.35,-.002)

var wave = global.pulse.part_types.white_wave

// Pulse particles store all properties that a regular particle may have
// You can access the actual particle_type ID by accessing ._index
// Using the pulse methods to change properties also saves these properties within the struct
// You can change the properties by using the default GM particle functions and 
// use Pulse's method .reset() to bring it back to the stored properties.


wave.set_color(c_white)
.set_alpha(.5,.2,0)
.set_life(30,35)
.set_blend(true)
.set_speed(15,15,-.2)
.set_shape(pt_shape_sphere)
.set_size(.5,.5,-.01,0)
.set_scale(2,.3)

/* Pulse emitters also have properties and methods of their own, somewhat mimmicking and expanding on GM emitters
 Properties :	FORM: An emitter can be an Ellipse, emmiting from a central origin, or a Path, emitting along a path asset.
				MASK (start and end, by default 0 and 1). Cuts off the emission along the form. In an ellipse, 1=360 degrees.
				RADIUS (inner and outer): the size from the origin point where particles will be created
				STENCIL : A stencil is an Animation Curve that is used to determine the distance from the center
						Can be assigned with the methods	 .set_shape(AnimationCurve,"AnimationChannel")
															.set_tween_shape(shapeA,"ChannelA",shapeB,"ChannelB",tweenvalue)
						Shapes are applied over the whole circumference/along path regardless of your masks.
						Shapes can be tweened from A to B or you can use A for the inner radius and B for the outer Radius for different effects
				TRANSFORM : .transform(scalex,scaley,rotation)

				DISTRIBUTION MODE ALONG NORMAL: Determines distribution along the radius/perpendicular to the path. can be RANDOM, GAUSSIAN, or EVEN
				DISTRIBUTION MODE ALONG FORM: Determines distribution along the form/perimeter. can be RANDOM, GAUSSIAN or EVEN
				DIRECTION_RANGE : an array with 2 elements, min and max. You can change the direction of the particle relative to the normal.
				If its more than 75 degrees, the particle will travel "sideways", or along the form.
				If its more than 135 degrees, the particle will travel inward.
				alter_direction is true by defualt, it will change the direction of the particle
				force_to_edge will force the particles to stay within the inner or outer radius.
*/				


sys.part_type.set_color(c_yellow,c_lime).set_speed(1,5,-.002)
shockwave.set_stencil(ac_Shape,"Splash")
shockwave.set_radius(20,60)
//sys.even_distrib(false,true,3)
sys.set_radius(0,200)//.set_mask(0,.5)
//sys.distr_along_v_coord = PULSE_RANDOM.ANIM_CURVE
//sys.distr_along_u_coord = PULSE_RANDOM.ANIM_CURVE
sys.force_to_edge=PULSE_TO_EDGE.FOCAL_LIFE
//sys.set_line(x+200,y-50)