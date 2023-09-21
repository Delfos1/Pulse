varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vPosition;

#define LN 8//Number of lights

uniform sampler2D spec;//specular map
uniform sampler2D norm;//normal map

uniform float lights[LN*4];//x,y,range
uniform float lcolor[LN*3];//r,g,b
uniform vec3 ambiance;//r,g,b
uniform int numEnabled;

void main()
{
    vec3 normal = normalize(texture2D( norm, v_vTexcoord ).rgb*-2.0+1.0);
    vec4 DifSample = texture2D( gm_BaseTexture, v_vTexcoord);
	
    vec3 result = ambiance * DifSample.rgb;
	int i = 0;
	for(i=0; i < numEnabled; i++)
	{
		vec3 lightPos = vec3(lights[i*4], lights[i*4+1], lights[i*4+2]);
		float range = lights[i*4+3];
		
		float attenuation = max(1.0-length(vec3(v_vPosition.x, v_vPosition.y, 0)-lightPos.xyz)/range,0.0);
		
		//normal mapping
		vec3 lightColor = vec3(lcolor[i*3], lcolor[i*3+1], lcolor[i*3+2]);
		vec3 lightDir = normalize(lightPos - vec3(v_vPosition.x, v_vPosition.y, 0)); 
		float d = max(dot(normal, lightDir), 0.0);
		vec3 diffuse = d * lightColor * DifSample.rgb * attenuation;
		result += diffuse;
		result.x = min(result.x, DifSample.x);
		result.y = min(result.y, DifSample.y);
		result.z = min(result.z, DifSample.z);
	}
    gl_FragColor = vec4(result, DifSample.a) * v_vColour;
}

