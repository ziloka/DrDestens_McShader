#version 120

uniform int worldTime;

#include "/lib/transform.glsl"
#include "/lib/settings.glsl"
#include "/lib/math.glsl"
#include "/lib/labPBR13.glsl"
#include "/lib/lighting.glsl"
#include "/lib/gamma.glsl"

uniform sampler2D lightmap;
uniform sampler2D texture;

uniform vec3 fogColor;

flat varying float blockId;

varying vec3  viewpos;
varying vec2  lmcoord;
varying vec2  coord;
varying vec4  glcolor;

flat varying mat3 tbn;
// tbn[0] = tangent vector
// tbn[1] = binomial vector
// tbn[2] = normal vector

/* DRAWBUFFERS:0231 */
void main() {
	vec3  normal = tbn[2];
	float reflectiveness = 0;

	vec4 color		   = texture2D(texture, coord);
	color.rgb 		  *= glcolor.rgb * glcolor.a;
	color.rgb         *= texture2D(lightmap, lmcoord).rgb + DynamicLight(lmcoord);
	gamma(color.rgb);

	#ifdef PHYSICALLY_BASED

		MaterialInfo MatTex = FullMaterial(coord, color);

		PBRout Material    = PBRMaterial(MatTex, lmcoord, tbn, viewpos, fogColor * 0.05);

		color	           = Material.color;
		normal	   	       = Material.normal;
		reflectiveness     = Material.reflectiveness;

	#endif

	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normal, 1);
	gl_FragData[2] = vec4(blockId - 1000, vec3(1));
	gl_FragData[3] = vec4(reflectiveness, vec3(1));
}