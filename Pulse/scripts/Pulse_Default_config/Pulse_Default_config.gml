// Color mode use internally to set to particles
enum __PULSE_COLOR_MODE
{
	COLOR,
	RGB,
	MIX,
	HSV
}
enum PULSE_FORM
{
	PATH,
	ELLIPSE,
	LINE,
}
enum PULSE_STENCIL
{
	INTERNAL			=	10,
	EXTERNAL			=	11,
	A_TO_B				=	12,
	NONE				=	13,
}
enum PULSE_RANDOM
{
	RANDOM				=	20,
	ANIM_CURVE			=	21,
	EVEN				=	22,
}
// Color mode used by emitter
enum PULSE_COLOR
{
	A_TO_B_RGB			=30,
	A_TO_B_HSV			=31,
	COLOR_MAP			=32,
	RGB					=33,
	NONE				=34,
}
enum PULSE_TO_EDGE
{
	NONE=40,
	SPEED=41,
	LIFE=42,
	FOCAL_SPEED = 43,
	FOCAL_LIFE	= 44,
}
enum PULSE_PROPERTY
{
	U_COORD,
	V_COORD,
	PATH_SPEED,
	ORDER_OF_CREATION,
	TO_EDGE,
}
enum PULSE_FORCE
{
	DIRECTION,
	POINT,
	RANGE_INFINITE,
	RANGE_RADIAL,
	RANGE_DIRECTIONAL,
}

function __pulse_show_debug_message(_message)
{
	if __PULSE_SHOW_DEBUG == false exit;
	
	show_debug_message(_message);
}

//Shows messages on the Output
#macro __PULSE_SHOW_DEBUG				true

// Default naming
#macro __PULSE_DEFAULT_SYS_NAME			"_system"

#macro __PULSE_DEFAULT_PART_NAME		"part_type"

// Default Particle properties

#macro __PULSE_DEFAULT_PART_SIZE		[.1,.1,.2,.2,0,0,0,0]

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

#macro __PULSE_DEFAULT_EMITTER_STENCIL_MODE				PULSE_STENCIL.NONE

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