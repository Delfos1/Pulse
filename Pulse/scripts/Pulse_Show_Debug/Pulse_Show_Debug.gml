/// @description  0: No extra , 1: Warning , 2 : Error , 3: Success
show_debug_message("██⁂   Welcome to  ͜◌  ◌͜PULSE     ⁂██ v1.0.0 ~ Made by Matias 'Delfos' Poggini. Released under MIT license. 2025" )
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
			_pre = "██⁂     ͜◌ PULSE      ⁂██ : " 
		break
		case 1 : // Warning
			_pre = "██⁂  PULSE WARNING o⁔o  ⁂██ : "
		break
		case 2: // Error
			_pre = "██⁂  PULSE ERROR   o⁔o  ⁂██ : "
		break
		default: // Success
			_pre = "██⁂  PULSE SUCCESS  ^⌣^ ⁂██ : "
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