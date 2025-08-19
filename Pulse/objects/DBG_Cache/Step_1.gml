if !move exit

x = x +(mouse_x - mouse_start[0]  )
y = y + (mouse_y - mouse_start[1]  )

mouse_start = [mouse_x,mouse_y]

if (xprevious != x || yprevious != y)  
{
	activate_collision =  true
}