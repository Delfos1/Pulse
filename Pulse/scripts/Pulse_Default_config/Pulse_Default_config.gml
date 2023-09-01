enum __PULSE_COLOR_MODE
{
	COLOR,
	RGB,
	MIX,
	HSV
}

//Shows messages on the Output
#macro __PULSE_SHOW_DEBUG				true

// Default naming
#macro __PULSE_DEFAULT_SYS_NAME			"_system"

#macro __PULSE_DEFAULT_PART_NAME		"part_type"

// Default Particle properties

#macro __PULSE_DEFAULT_PART_SIZE		[.1,.2,0,0]

#macro __PULSE_DEFAULT_PART_SCALE		[1,1]

#macro __PULSE_DEFAULT_PART_LIFE		[30,30]

#macro __PULSE_DEFAULT_PART_COLOR		[c_white,c_aqua,c_navy]

#macro __PULSE_DEFAULT_PART_COLOR_MODE	__PULSE_COLOR_MODE.COLOR

#macro __PULSE_DEFAULT_PART_ALPHA		[1,1,0]

#macro __PULSE_DEFAULT_PART_BLEND		false

#macro __PULSE_DEFAULT_PART_SPEED		[2,3,0,0]

#macro __PULSE_DEFAULT_PART_SHAPE		pt_shape_disk

#macro __PULSE_DEFAULT_PART_ORIENT		[0,0,0,0,true]

#macro __PULSE_DEFAULT_PART_GRAVITY		[0,270]

#macro __PULSE_DEFAULT_PART_DIRECTION	[0,0,0,0]


//Default Pulse Emitter Properties

#macro __PULSE_DEFAULT_EMITTER_STENCIL_MODE				PULSE_STENCIL.EXTERNAL

#macro __PULSE_DEFAULT_EMITTER_FORM_MODE				PULSE_FORM.ELLIPSE

//Distribution along the perpendicular (the radius of a circle, normal vector of a path)
#macro __PULSE_DEFAULT_EMITTER_DISTR_ALONG_V_COORD		PULSE_RANDOM.RANDOM

//Distribution along the transversal (along the path or perimeter)
#macro __PULSE_DEFAULT_EMITTER_DISTR_ALONG_U_COORD			PULSE_RANDOM.RANDOM

//Whether the emitter changes the direction of the particle is emitting
#macro __PULSE_DEFAULT_EMITTER_ALTER_DIRECTION			true

#macro __PULSE_DEFAULT_EMITTER_FORCE_TO_EDGE			PULSE_TO_EDGE.LIFE

#macro __PULSE_DEFAULT_DISTR_PROPERTY				PULSE_RANDOM.RANDOM

// Systems can reduce their particle count after a certain amount of frames.
#macro __PULSE_DEFAULT_COUNT_TIMER		80