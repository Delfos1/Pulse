varying vec2 v_vTexcoord;
varying vec4 v_vColour;
const vec3 grey = vec3(0.229, 0.587, 0.114);
float togrey(vec3 color) {
  return dot(color, grey);
	}

void main()
{
    vec4 base_col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	float alpha = step(0.68,base_col.a);


    gl_FragColor = vec4(base_col.rgb,alpha);

}