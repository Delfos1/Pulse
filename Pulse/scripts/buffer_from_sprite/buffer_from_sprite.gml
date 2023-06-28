/// @function              buffer_from_sprite(_sprite,_subimage)
/// @description           loads a sprite into a buffer-struct that saves the buffer reference and the size of the image.  
/// @param {Asset.Sprite}     
/// @return {Buffer}
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
       // return buffer_peek(self.noise, ((x * self.height) + y) * 4, buffer_u8);
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