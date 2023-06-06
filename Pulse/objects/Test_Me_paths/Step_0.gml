 if !on exit
 
 sys.pulse(1+(100*sys.mask_end),x,y)
 
if sys.mask_end+0.0025<1 
{
	sys.mask_end+=0.0025
}
else
{
	sys.mask_end=1
}

