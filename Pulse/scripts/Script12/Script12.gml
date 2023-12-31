#region jsDoc
/// @func    func()
/// @desc    Define
///          continue...
/// @self    constructor_name
/// @param   {type} name : desc
/// @returns {type}
#endregion


function animcurve_points_add(array,posx,value,replace=false)
{
	var length = array_length(array)
	if length == 0
	{
		animcurve_point_make(array,0,posx,value)
		length += 1
		
		return
	}

	var _i =0
	repeat (length+1)
	{
		if _i == length
		{
			animcurve_point_make(array,_i,posx,value)
			length += 1
			return
		}

		if array[_i].posx < posx
		{
			_i += 1
		}
		else if array[_i].posx == posx 
		{
			if replace
			{
				array_delete(array,_i,1)
				animcurve_point_make(array,_i,posx,value)
			}
			break
		}
		else if array[_i].posx > posx
		{
			animcurve_point_make(array,_i,posx,value)
			length += 1
		}
	}
}	

function animcurve_point_make(array,index,posx,value)
{
		var point			= animcurve_point_new()
		point.posx	= posx
		point.value	= value
		
		array_insert(array, index, point)
}

function animcurve_point_delete(array,posx)
{
	var _i = 0
	repeat(array_length(array))
	{
		if array[_i].posx == posx
		{
			array_delete(array,_i,1)
		}
	}
}