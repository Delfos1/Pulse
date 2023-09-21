varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform float angle;//Angle in degrees
void main()
{
    float A = radians(angle);//Angle in radians
    mat3 anglemat = mat3(cos(A),-sin(A),0.0,sin(A),cos(A),0.0,0.0,0.0,1.0);
    vec4 Col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = vec4((normalize(Col.rgb*2.0-1.0) * anglemat)*0.5+0.5 ,Col.a);
}

