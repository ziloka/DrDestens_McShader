#version 130

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                         BLOOM
//////////////////////////////////////////////////////////////////////////////////////////////////////////


#include "/lib/math.glsl"
#include "/lib/framebuffer.glsl"
#include "/lib/bloom.glsl"

in vec2 coord;


/* DRAWBUFFERS:5 */
void main() {
    float blursize = 2 / viewHeight;
    vec3 color = gBlur_vertical7_bloom_clamp((coord + (0.5 / ScreenSize)) * 0.1, blursize, 0.099);

    FD0 = vec4(color, 1);
}