switch(mode)
{
	case 0:
	gpu_set_blendmode(bm_normal)
	break
	case 1:
	
	gpu_set_blendmode(bm_add)
	break
	case 2:
	gpu_set_blendmode(bm_subtract)
	break
	case 3:
	gpu_set_blendmode_ext(bm_dest_colour, bm_zero);
	break
	case 4:
	gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha,bm_dest_alpha,bm_zero)
	break
	case 5:
	gpu_set_blendmode(bm_max)
	break
	
}

system.draw_it()

gpu_set_blendmode(bm_normal)






