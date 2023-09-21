varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vPosition;

#define LN 8//Number of lights

uniform sampler2D spec;//specular map
uniform sampler2D norm;//normal map

uniform float lights[LN*3];//x,y,range
uniform float lcolor[LN*3];//r,g,b
uniform vec3 ambiance;//r,g,b
uniform int numEnabled;

const vec3 grey = vec3(0.229, 0.587, 0.114);
float togrey(vec3 color) {
  return dot(color, grey);
	}
	
void main()
{
    vec3 normal = normalize(texture2D( norm, v_vTexcoord ).rgb*-2.0+1.0);
    vec4 DifSample = texture2D( gm_BaseTexture, v_vTexcoord);
	
    vec3 result = ambiance * DifSample.rgb;
	int i = 0;
	for(i=0; i < numEnabled; i++)
	{
		vec3 lightPos = vec3(lights[i*3], lights[i*3+1], -100.0);
		float range = lights[i*3+2];
		//smooth attenuation
		float attenuation = max(1.0-length(vec2(v_vPosition)-lightPos.xy)/range,0.0);
		//graded attenuation
		/*
		if (attenuation > 0.25)
		{
			attenuation = 1.0;
		} else if (attenuation > 0.0)
		{
			attenuation = 0.5;
		}*/
		
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
	
	vec4 base_col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	float alpha = step(0.68, DifSample.a);
	float levels = 7.0;
	float greyscale = togrey(result.rgb);
	float lower     = floor(greyscale * levels)/levels;
	float lowerDiff = abs(greyscale - lower);
    float upper     = ceil(greyscale * levels)/levels;
	float upperDiff = abs(upper - greyscale);
    float level      = lowerDiff <= upperDiff ? lower : upper;
	float adjustment = level / greyscale;
	
    gl_FragColor = vec4(result*adjustment, DifSample.a) * v_vColour;
}