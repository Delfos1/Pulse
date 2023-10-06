switch(mode)
{
	case 0:
	gpu_set_blendmode(bm_normal)
	particle.set_blend(false)
	break
	case 1:
	
	gpu_set_blendmode_ext(bm_one,bm_inv_src_color);
	break
	case 2:
	gpu_set_blendmode(bm_subtract)
	break
	case 3:
	gpu_set_blendmode_ext_sepalpha(bm_dest_colour, bm_zero,bm_src_alpha,bm_inv_src_alpha);
	break
	case 4:
	gpu_set_blendmode_ext_sepalpha(bm_src_color,bm_inv_src_alpha,bm_src_alpha,bm_inv_src_alpha)
	break
	case 5:
	gpu_set_blendmode(bm_add)
	break
	
}

system.draw_it()

draw_sprite_ext(Sprite50,0,50,50,1,1,1,c_orange,.5)
draw_sprite_ext(Sprite50,0,75,50,1,1,1,c_orange,.5)
gpu_set_blendmode(bm_normal)

draw_text(50,50,$"{mode}")






