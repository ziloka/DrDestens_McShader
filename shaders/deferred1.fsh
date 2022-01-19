#include "/lib/settings.glsl"
#include "/lib/math.glsl"
#include "/lib/kernels.glsl"
#include "/lib/transform.glsl"
#include "/lib/composite_basics.glsl"
#include "/lib/lighting_basics.glsl"

vec2 coord = gl_FragCoord.xy * screenSizeInverse;

/* DRAWBUFFERS:0 */
void main() {
    vec3  color = getAlbedo(ivec2(gl_FragCoord.xy));
    float id    = getID(ivec2(gl_FragCoord.xy));

    bool  isPBR      = id != 2 && id != 3 && id != 4;
    bool  isLightmap = id != 4;

    material PBR = getMaterial(coord);

    if (isLightmap) {
        color *= getLightmap(getLmCoord(coord), isPBR ? PBR.ao : 1);
    }

    //color = getNormal(coord) * 0.5 + 0.5;

    gl_FragData[0] = vec4(color, 1.0);
}