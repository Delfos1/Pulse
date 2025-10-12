/// @description  0: No extra , 1: Warning , 2 : Error , 3: Success
show_debug_message("█⁂⁂   Welcome to  ⁂PULSE⁂    v1.0.0 ~ by Delfos ⁂⁂█" )
function __pulse_show_debug_message(_message,_type = 0)
{
	static prev_messages = ""
	if __PULSE_SHOW_DEBUG == false exit;
	
	if _message == prev_messages exit
	
	prev_messages = _message
	
	var _pre = ""
	switch (_type)
	{
		case 0 : // Normal message
			_pre = "█     ⁂Pulse⁂       █ : " 
		break
		case 1 : // Warning
			_pre = "█  ⁂Pulse⁂ Warning  █ : "
		break
		case 2: // Error
			_pre = "█  ⁂Pulse⁂ Error    █ : "
		break
		default: // Success
			_pre = "█  ⁂Pulse⁂ Success  █ : "
		break
	}
	if __PULSE_SHOW_DEBUG_STACK
	{
		var _stack = debug_get_callstack(3)
		show_debug_message($"{_pre} {_message} : {_stack[2]}");
	}else{
		show_debug_message($"{_pre} {_message}");
	}
	
}