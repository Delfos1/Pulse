/// @function              buffer_from_sprite(_sprite,_subimage)
/// @description           loads a sprite into a struct that saves the buffer reference and the size of the image.  Statics: Get, Get Normalized, Destroy. Based on Dragonite's Macaw
/// @param _sprite {Asset.GMSprite}  
/// @param _subimage {real}
/// @return {struct}
function buffer_from_sprite(_sprite,_subimage){
	
    var _sw = sprite_get_width(_sprite);
    var _sh = sprite_get_height(_sprite);
    var _surf = surface_create(_sw, _sh);
    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);
    draw_sprite(_sprite, _subimage, 0, 0);
    surface_reset_target();
	var buffer = buffer_create(_sw * _sh * 4, buffer_fixed, 1);
	buffer_get_surface(buffer, _surf, 0);
    surface_free(_surf);
	
	return new __buffered_sprite(buffer,_sw,_sh);
}

/// @function              buffer_from_surface(_surface)
/// @description           loads a ssurface into a struct that saves the buffer reference and the size of the image.  Statics: Get, Get Normalized, Destroy. Based on Dragonite's Macaw
/// @param _surface {Id.Surface}     
/// @return {struct}
function buffer_from_surface(_surface){
	
	if !surface_exists(_surface) exit
	
    var _sw = surface_get_width(_surface);
    var _sh = surface_get_height(_surface);

	var buffer = buffer_create(_sw * _sh * 4, buffer_fixed, 1);
	buffer_get_surface(buffer, _surface, 0);
	
	return new __buffered_sprite(buffer,_sw,_sh);
}
	
/// Buffered sprite class	
function __buffered_sprite(buffer, w, h) constructor {
    
    self.noise = buffer;
    self.width = w;
    self.height = h;
            
    static Get = function(x, y) {
        x = floor(clamp(x, 0, self.width - 1));
        y = floor(clamp(y, 0, self.height - 1));
		var a = buffer_peek(self.noise, (((x * self.height) + y) * 4)+3, buffer_u8);
		var b = buffer_peek(self.noise, (((x * self.height) + y) * 4)+2, buffer_u8);
		var g = buffer_peek(self.noise, (((x * self.height) + y) * 4)+1, buffer_u8);
		var r = buffer_peek(self.noise, ((x * self.height) + y) * 4, buffer_u8);
		var array = [r,g,b,a]
		return array
     
    };
            
    static GetNormalized = function(u, v) {
		u = clamp(u,0,1)
		v = clamp(v,0,1)
        return self.Get(u * self.width, v * self.height);
    };
    
    static GetNormalised = GetNormalized;
    
    static Destroy = function() {
        buffer_delete(self.noise);
    };
 
}