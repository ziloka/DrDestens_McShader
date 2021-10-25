

#include "/lib/settings.glsl"
#include "/lib/vertex_transform_simple.glsl"
#include "/lib/kernels.glsl"

#ifdef TAA
uniform int  frameCounter;
uniform vec2 screenSizeInverse;
#endif

varying vec2 coord;
varying vec3 normal;
varying vec3 viewPos;
varying vec4 glcolor;

void main() {
	vec4 clipPos = ftransform();

	#ifdef TAA
		clipPos.xy += TAAOffsets[int( mod(frameCounter, 4) )] * TAA_JITTER_AMOUNT * clipPos.w * screenSizeInverse * 2;
	#endif
	
	gl_Position = clipPos;
	
	normal  = getNormal();
	viewPos = getView();
	coord   = getCoord();
	glcolor = gl_Color;
}