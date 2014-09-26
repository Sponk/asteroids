#version 130
//400

#ifdef GL_ES
precision highp float;
#endif

#define PI 3.14159265

uniform sampler2D Texture[4];
in vec2 texcoord;

uniform float gamma = 1.1;

// fxaa
uniform int fxaaEnable = 1;

// blur
uniform float blurStrength = 0.0;

// Contrast
uniform float contrastFactor = 1.0;

// General purpose
uniform float Width = 1024;
uniform float Height = 768;

uniform float farPlane = 1000.0;
uniform float nearPlane = 1.0;

float width = Width;
float height = Height;

out vec4 fragmentColor;

float linearize_depth(vec2 uv)
{
  float n = nearPlane; // camera z near
  float f = farPlane; // camera z far
  float z = texture(Texture[1], uv).x;
  return (2.0 * n) / (f + n - z * (f - n));	
}

float get_depth(vec2 uv)
{
	return texture(Texture[1], uv).x;
}

void gamma_correction()
{
	vec3 color = fragmentColor.xyz;
	fragmentColor.rgb = pow(color, vec3(1.0 / gamma));
}

vec4 fxaa(sampler2D textureSampler, vec2 vertTexcoord, vec2 texcoordOffset) 
{
  // The parameters are hardcoded for now, but could be
  // made into uniforms to control fromt he program.
  float FXAA_SPAN_MAX = 8.0;
  float FXAA_REDUCE_MUL = 1.0/8.0;
  float FXAA_REDUCE_MIN = (1.0/128.0);

  vec3 rgbNW = texture(textureSampler, vertTexcoord + (vec2(-1.0, -1.0) * texcoordOffset)).xyz;
  vec3 rgbNE = texture(textureSampler, vertTexcoord + (vec2(+1.0, -1.0) * texcoordOffset)).xyz;
  vec3 rgbSW = texture(textureSampler, vertTexcoord + (vec2(-1.0, +1.0) * texcoordOffset)).xyz;
  vec3 rgbSE = texture(textureSampler, vertTexcoord + (vec2(+1.0, +1.0) * texcoordOffset)).xyz;
  vec3 rgbM  = texture(textureSampler, vertTexcoord).xyz;
	
  vec3 luma = vec3(0.299, 0.587, 0.114);
  float lumaNW = dot(rgbNW, luma);
  float lumaNE = dot(rgbNE, luma);
  float lumaSW = dot(rgbSW, luma);
  float lumaSE = dot(rgbSE, luma);
  float lumaM  = dot( rgbM, luma);
	
  float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
  float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
	
  vec2 dir;
  dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
  dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
	
  float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
	  
  float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
	
  dir = min(vec2(FXAA_SPAN_MAX,  FXAA_SPAN_MAX), 
        max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), dir * rcpDirMin)) * texcoordOffset;
		
  vec3 rgbA = (1.0/2.0) * (
              texture(textureSampler, vertTexcoord + dir * (1.0/3.0 - 0.5)).xyz +
              texture(textureSampler, vertTexcoord + dir * (2.0/3.0 - 0.5)).xyz);
  vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
              texture(textureSampler, vertTexcoord + dir * (0.0/3.0 - 0.5)).xyz +
              texture(textureSampler, vertTexcoord + dir * (3.0/3.0 - 0.5)).xyz);
  float lumaB = dot(rgbB, luma);

  vec4 outfrag;
  
  if((lumaB < lumaMin) || (lumaB > lumaMax))
  {
    outfrag.xyz = rgbA;
  } 
  else 
  {
    outfrag.xyz = rgbB;
  }
  
  return outfrag;
}

vec4 blur(vec4 color, float strength)
{
        if(strength == 0.0)
            return color;
    
        //strength *= float(textureSize(Texture[0], 1).x);
    
	color += texture2D(Texture[0], texcoord+vec2(0.01, 0.0) * strength);
	color += texture2D(Texture[0], texcoord+vec2(-0.01, 0.0) * strength);
	color += texture2D(Texture[0], texcoord+vec2(0.0, 0.01) * strength);
	color += texture2D(Texture[0], texcoord+vec2(0.0, -0.01) * strength);
	color += texture2D(Texture[0], texcoord+vec2(0.007, 0.007) * strength);
	color += texture2D(Texture[0], texcoord+vec2(-0.007, -0.007) * strength);
	color += texture2D(Texture[0], texcoord+vec2(0.007, -0.007) * strength);
	color += texture2D(Texture[0], texcoord+vec2(-0.007, 0.007) * strength);

	return color /= vec4(8.0);
}

void main()
{
        if(blurStrength != 0.0)
        {
            fragmentColor = blur(vec4(1.0,1.0,1.0,1.0), blurStrength);
            fragmentColor = ((fragmentColor - 0.5f) * max(contrastFactor, 0)) + 0.5f;
            return;
        }

	if(fxaaEnable == 1)
		fragmentColor = fxaa(Texture[0], texcoord, vec2(1.0/width,1.0/height));
	else
		fragmentColor = texture(Texture[0], texcoord);
	
	// Contrast
        fragmentColor = ((fragmentColor - 0.5f) * max(contrastFactor, 0)) + 0.5f;

	gamma_correction();
	fragmentColor.a = 1.0;
}
