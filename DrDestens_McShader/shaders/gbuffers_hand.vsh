#version 120

#include "/lib/settings.glsl"
#include "/lib/vertex_transform.glsl"

attribute vec4 mc_Entity;

flat varying float blockId;
varying vec3  viewpos;
varying vec2  lmcoord;
varying vec2  coord;

varying vec4 glcolor;

// Switch on or off Fragment based normal mapping
#ifdef FRAG_NORMALS
flat varying vec3 N;
#else
flat varying mat3 tbn;
#endif

void main() {
	gl_Position = ftransform();

	viewpos = getView();
	lmcoord = getLmCoord();
	coord   = getCoord();
	#ifdef FRAG_NORMALS
	N  		= getNormal();
	#else
	tbn     = getTBN();
	#endif

	blockId = mc_Entity.x;
	glcolor = gl_Color;
}