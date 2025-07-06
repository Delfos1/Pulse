enum __PULSE_COLOR_MODE
{// Color mode use internally to set to particles
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
enum PULSE_DISTRIBUTION
{
	RANDOM				=	20,
	ANIM_CURVE			=	21,
	EVEN				=	22,
	LINKED				=	23,
	LINKED_CURVE		=	24,
	NONE,
}

enum PULSE_COLOR
{// Color mode used by emitter
	A_TO_B_RGB			=30,
	A_TO_B_HSV			=31,
	COLOR_MAP			=32,
	RGB					=33,
	NONE				=34,
}
enum PULSE_BOUNDARY
{
	NONE=40,
	SPEED=41,
	LIFE=42,
	FOCAL_SPEED = 43,
	FOCAL_LIFE	= 44,
}
enum PULSE_LINK_TO
{
	U_COORD ,
	V_COORD,
	PATH_SPEED,
	SPEED,
	DIRECTION,
	DISPL_MAP,
	COLOR_MAP,
	NONE
}

enum PULSE_FORCE
{
	DIRECTION,
	POINT,
	RANGE_INFINITE,
	RANGE_RADIAL,
	RANGE_DIRECTIONAL,
}
/// @description  0: No extra , 1: Warning , 2 : Error , 3: Success
function __pulse_show_debug_message(_message,_type = 0)
{
	if __PULSE_SHOW_DEBUG == false exit;
	
	var _pre = ""
	switch (_type)
	{
		case 0 : // Normal message
			_pre = "█♋█  PULSE  █♋█ : " 
		break
		case 1 : // Warning
			_pre = "▉♋▉  PULSE WARNING  ▉♋▉ : "
		break
		case 2: // Error
			_pre = "▉♋▉  PULSE ERROR  ▉♋▉ : "
		break
		case 3: // Success
			_pre = "█♋█  PULSE SUCCESS █♋█ : "
		break
	}
	if __PULSE_SHOW_DEBUG_STACK
	{
		var _stack = debug_get_callstack(3)
		show_debug_message($"{_pre} {_message} : {_stack}");
	}else{
		show_debug_message($"{_pre} {_message}");
	}
	
}

//Shows messages on the Output
#macro __PULSE_SHOW_DEBUG				true
#macro __PULSE_SHOW_DEBUG_STACK			true
// Default naming
#macro __PULSE_DEFAULT_SYS_NAME			"_system"

#macro __PULSE_DEFAULT_PART_NAME		"part_type"

// Default directory for exporting/importing

#macro __PULSE_DEFAULT_DIRECTORY		working_directory //string_concat(working_directory  + "Pulse")


// Default Particle properties 

#macro __PULSE_DEFAULT_PART_SIZE		[.1,.1,.2,.2,0,0,0,0] // minx, min y, max x, max y, acc x, acc y, wiggle x wiggle y

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


//The default external radius for emitters
#macro __PULSE_DEFAULT_EMITTER_RADIUS					50

#macro __PULSE_DEFAULT_EMITTER_STENCIL_MODE				PULSE_STENCIL.NONE

#macro __PULSE_DEFAULT_EMITTER_FORM_MODE				PULSE_FORM.ELLIPSE

//Distribution along the perpendicular (the radius of a circle, normal vector of a path)
#macro __PULSE_DEFAULT_EMITTER_DISTR_ALONG_V_COORD		PULSE_DISTRIBUTION.RANDOM

//Distribution along the transversal (along the path or perimeter)
#macro __PULSE_DEFAULT_EMITTER_DISTR_ALONG_U_COORD		PULSE_DISTRIBUTION.RANDOM

//Whether the emitter changes the direction of the particle is emitting
#macro __PULSE_DEFAULT_EMITTER_ALTER_DIRECTION			true

#macro __PULSE_DEFAULT_EMITTER_BOUNDARY			PULSE_BOUNDARY.LIFE

#macro __PULSE_DEFAULT_DISTR_PROPERTY					PULSE_DISTRIBUTION.RANDOM

// Systems can reduce their particle count after a certain amount of frames.
#macro __PULSE_DEFAULT_COUNT_TIMER		80

