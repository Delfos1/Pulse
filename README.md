~~~~~Welcome to Pulse!~~~~~

Welcome to Pulse v 0.0.0(...)0.1 . Very first iteration of it.
Pulse is a custom particle emitter for GameMakerStudio working on 2023.4.
GameMaker is changing rapidly, so this might become obsolete quick, but meanwhile here we are.

I haven't written a comprehensive manual for this, as I'm expecting it to change according to user (you!) input.
So I highly recommend looking at the test project to understand how to do things. 
Still, here are some pointers:



~~~~~~~~~~~~~~~~~01 _ Create a new Pulse emitter~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a new pulse emitter by typing new part_pulse_emitter
You can supply 3 arguments: particle system, particle type and emitter size
If you don't supply any, Pulse will create them for you.

			sys= new part_pulse_emitter()

You can also provide a string. Pulse will create the new particle/system and assign it your given name.
If you have already created them with those names, it will re use the existing ones

			shockwave=  new part_pulse_emitter("sys_2","white_wave")

Particle/System ID s get allocated in global.pulse._systems and global.pulse.part_types respectively.
If unnamed they get a default name assigned. You can change default values in the Dafault_config script.


~~~~~~~~~~~~~~~~02_Accessing Pulse particles and systems~~~~~~~~~~~~~~~~~~~~~

They can be accessed by their array number or by searching the string name

				global.pulse.part_types[0].life(30,50)
		var wave = 	pulse_particle_get_ID("white_wave")

Pulse particles store (almost) all properties that a regular particle may have
You can access the actual particle_type ID by accessing ._part_type

~~~~~~~~~~~~~~03_ Change Pulse particles properties~~~~~~~~~~~~~~~~~~~~~~~~

// Using the pulse methods to change properties also saves these properties within the struct
// You can change the properties by using the default GM particle functions and 
// use Pulse's method .reset() to bring it back to the stored properties.

		wave.color(c_white)
		wave.alpha(.5,.2,0)
		wave.life(30,35)
		wave.blend(true)
		wave.speed_start(15,15,-.2)
		wave.shape(pt_shape_sphere)
		wave.size(.5,.5,-.01,0)
		wave.scale(2,.3)



~~~~~~~~~~~~~ 04 _ Pulse emitters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Pulse emitters also have properties and methods of their own, somewhat mimmicking and expanding on GM emitters
 Properties :	ANGLE (start and end, by default 0 and 360)
				RADIUS (inner and outer)
				SHAPE : A shape is an Animation Curve that is used to determine minimum and maximum length.
						Can be assigned with the methods	 .shape(AnimationCurve,"AnimationChannel")
															.tween_shape(shapeA,ChannelA,shapeB,ChannelB,tweenvalue)
						Shapes are applied over the whole circumference regardless of your angles.
						Shapes can be tweened from A to B or you can use A for the inner radius and B for the outer Radius for different effects
				TRANSFORM : .transform(scalex,scaley,rotation)
				SPEED_START : Speed is used by Pulse to calculate how far a particle travels, and its adjusted per each particle
						to keep them within your chosen limits. Pulse doesn't work with any kind of acceleration yet.
				EMITTER MODE: There are 4 modes :
									OUTWARD : Particles are created within radius and directed away from origin
									INWARD	: Particles are directed towards the origin. They stop at the origin
									SHAPE_FROM_POINT : Particles are created anywhere within radius from the origin point and directed away from origin. They remain inside the shape
									SHAPE_FROM_POINT : Particles are created anywhere within the inner and outer radius, following their shape, and directed away from origin. They remain inside the shape
							  They can be set by the methods: .inward() and .outward_shape()
				DISTRIBUTION MODE: Determines distribution along the radius. can be RANDOM, GAUSSIAN, A_TO_B (using shapes A and B for inner and outer radius) or NONE (Evenly distributed)
				DIRECTION MODE: Determines distribution along the angle range. can be RANDOM, GAUSSIAN or NONE (Evenly distributed)
			
~~~~~~~~~~~~~~~~~~ 05_ "Burst" method ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Just use the method  .pulse(_amountofparticles,x,y)	. As simple as that	

~~~~~~~~~~~~~~~~~ 06 _ Clean up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Pulse removes all pulse particle systems, pulse particle types, and removes them from its own internal log

pulse_destroy_all()

This would prevent memory leaks, as particles are not garbage collected. NOTE this works only for the particles and systems created with Pulse.
You still need to manually clean other particles created through GameMaker.
