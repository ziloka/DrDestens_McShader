

#include "/lib/settings.glsl"
#include "/lib/math.glsl"
#include "/lib/kernels.glsl"
#include "/lib/transform.glsl"
#include "/lib/composite_basics.glsl"

uniform float nearInverse;
uniform float aspectRatio;

uniform int   frameCounter;

vec2 coord = gl_FragCoord.xy * screenSizeInverse;

uniform sampler2D colortex4;
const bool colortex4MipmapEnabled = true; //Enabling Mipmapping

//////////////////////////////////////////////////////////////////////////////
//                     SCREEN SPACE AMBIENT OCCLUSION
//////////////////////////////////////////////////////////////////////////////

float linearPeakAttenuation(float depthDiff, float slope){
    float f = depthDiff * slope;
    float g = -(depthDiff - (1 + 1/slope));
    return saturate(min(g, f));
}
float peakAttenuation(float depthDiff, float peak) {
    return peak - abs(depthDiff - peak);
}
float linearAttenuation(float depthDiff, float cutoff, float slope) {
    return saturate((cutoff - depthDiff) * slope);
}
float cubicAttenuation(float depthDiff, float cutoff) {
    float tmp = depthDiff / cutoff;
    return saturate(-tmp * tmp + 1);
}
float cubicAttenuation2(float depthDiff, float cutoff) {
    depthDiff = min(cutoff, depthDiff);
    float tmp = (depthDiff - cutoff) / cutoff;
    return saturate(tmp * tmp);
}

// Old function, keeping it for reference
/* float AmbientOcclusionLOW(vec3 screenPos, vec3 normal, float size) {
    vec3 viewPos           = toView(screenPos * 2 - 1);
    mat3 TBN               = arbitraryTBN(normal);

    #ifdef TAA
     float ditherTimesSize  = (fract(Bayer4(screenPos.xy * screenSize) + (frameCounter * 0.136)) * 0.85 + 0.15) * size;
    #else
     float ditherTimesSize  = (Bayer4(screenPos.xy * screenSize) * 0.85 + 0.15) * size;
    #endif
    float depthTolerance   = 0.075/-viewPos.z;

    float hits = 0;
    vec3 sample;
    for (int i = 0; i < 8; i++) {
        sample      = half_sphere_8[i] * ditherTimesSize; 
        sample.z   += 0.05;                                                       // Adding a small (5cm) z-offset to avoid clipping into the block due to precision errors
        sample      = TBN * sample;
        sample      = backToClip(sample + viewPos) * 0.5 + 0.5;                  // Converting Sample to screen space, since normals are in view space
    
        float hitDepth = getDepth_int(sample.xy);

        hits += float(sample.z > hitDepth && (sample.z - hitDepth) < depthTolerance);
    }

    hits  = -hits * 0.125 + 1;
    return sq(hits);
} */
float AmbientOcclusionLOW(vec3 screenPos, vec3 normal, float size) {
    vec3 viewPos      = toView(screenPos * 2 - 1);
    float linearDepth = linearizeDepthf(screenPos.z, nearInverse);

    #ifdef TAA
     float ditherTimesSize  = (fract(Bayer4(screenPos.xy * screenSize) + (frameCounter * PHI_INV)) * 0.9 + 0.1) * size;
    #else
     float ditherTimesSize  = (Bayer4(screenPos.xy * screenSize) * 0.85 + 0.15) * size;
    #endif

    float hits = 0;
    for (int i = 0; i < 8; i++) {

        vec3 sample = vogel_sphere_8[i] * ditherTimesSize;
        sample     *= sign(dot(normal, sample));                        // Inverts the sample position if its pointing towards the surface (thus being within it). Much more efficient than using a tbn
        sample     += normal * 0.025;                                    // Adding a small offset away from the surface to avoid self-occlusion and SSAO acne
        sample      = backToClip(sample + viewPos) * 0.5 + 0.5;

        float hitDepth = getDepth_int(sample.xy);

        float depthDiff = saturate(sample.z - hitDepth) * linearDepth;
        hits += linearAttenuation(depthDiff, size, 3) * float(sample.z > hitDepth);
    }

    hits  = saturate(-hits * 0.125 + 1.125);
    return sq(hits);
}

float AmbientOcclusionHIGH(vec3 screenPos, vec3 normal, float size) {
    vec3  viewPos     = toView(screenPos * 2 - 1);
    float linearDepth = linearizeDepthf(screenPos.z, nearInverse);

    #ifdef TAA
     float ditherTimesSize  = (fract(Bayer4(screenPos.xy * screenSize) + (frameCounter * 0.136)) * 0.85 + 0.15) * size;
    #else
     float ditherTimesSize  = (Bayer4(screenPos.xy * screenSize) * 0.85 + 0.15) * size;
    #endif
    float depthTolerance   = 0.075/-viewPos.z;

    float hits = 0;
    for (int i = 0; i < 16; i++) {

        vec3 sample = vogel_sphere_16[i] * ditherTimesSize;
        sample     *= sign(dot(normal, sample));                   // Inverts the sample position if its pointing towards the surface (thus being within it). Much more efficient than using a tbn
        sample     += normal * 0.025;                               // Adding a small offset away from the surface to avoid self-occlusion and SSAO acne
        sample      = backToClip(sample + viewPos) * 0.5 + 0.5;

        float hitDepth = getDepth_int(sample.xy);

        float depthDiff = saturate(sample.z - hitDepth) * linearDepth;
        hits += linearAttenuation(depthDiff, size, 3) * float(sample.z > hitDepth);
    }

    hits  = -hits * 0.0625 + 1;
    return sq(hits);
}

// Really Fast™ SSAO
float SSAO(vec3 screenPos, float radius) {
    if (screenPos.z >= 1.0) { return 1.0; };

    #ifdef TAA
     float dither = fract(Bayer8(screenPos.xy * screenSize) + (frameCounter * PHI_INV)) * 0.2;
    #else
     float dither = Bayer8(screenPos.xy * screenSize) * 0.2;
    #endif

    float radZ   = radius * linearizeDepthfDivisor(screenPos.z, nearInverse);
    radZ         = clamp(radZ, 1e-3, 0.2);
    float dscale = 20 / radZ;
    vec2  rad    = vec2(radZ * fovScale, radZ * fovScale * aspectRatio);

    float sample      = 0.2 + dither;
    float increment   = radius * PHI_INV;
    float occlusion   = 0.0;
    for (int i = 0; i < 8; i++) {

        vec2 offs = spiralOffset_full(sample, 4.5) * rad;

        float sdepth = getDepth(screenPos.xy + offs);
        float diff   = screenPos.z - sdepth;

        occlusion   += clamp(diff * dscale, -1, 1) * cubicAttenuation2(diff, radZ);

        sample += increment;

    }

    occlusion = cb(1 - saturate(occlusion * 0.125));
    return occlusion;
}

/* float SSAO2(vec3 screenPos, float radius) {
    if (screenPos.z >= 1.0) { return 1.0; };

    #ifdef TAA
     int dither = int(fract(Bayer8(screenPos.xy * screenSize) + (frameCounter * PHI_INV)) * 56);
    #else
     int dither = int(Bayer8(screenPos.xy * screenSize) * 56);
    #endif

    float radZ   = radius * linearizeDepthfDivisor(screenPos.z, nearInverse);
    radZ         = clamp(radZ, 1e-3, 0.1);
    float dscale = 20 / radZ;
    vec2  rad    = vec2(radZ * fovScale, radZ * fovScale * aspectRatio);

    float sample      = 0.2 + dither;
    float increment   = radius * PHI_INV;
    float occlusion   = 0.0;
    for (int i = 0; i < 8; i++) {

        vec2 offs = vogel_disk_64_progressive[i+dither] * rad;

        float sdepth = getDepth(screenPos.xy + offs);
        float diff   = screenPos.z - sdepth;

        occlusion   += clamp(diff * dscale, -1, 1) * cubicAttenuation2(diff, radZ);

        sample += increment;

    }

    occlusion = saturate(cb(1.125 - saturate(occlusion * (0.125 / 0.875))));
    return occlusion;
} */

/* DRAWBUFFERS:0 */
void main() {
    vec3  color       = getAlbedo(coord);
    float depth       = getDepth(coord);
    float type        = getType(coord);

    //////////////////////////////////////////////////////////
    //                  SSAO
    //////////////////////////////////////////////////////////

    #ifdef SCREEN_SPACE_AMBIENT_OCCLUSION

        if (type != 50 && type != 51 && depth != 1) {

            #if   SSAO_QUALITY == 1

                color        *= SSAO(vec3(coord, depth), 0.2) * SSAO_STRENGTH + (1 - SSAO_STRENGTH);

            #elif SSAO_QUALITY == 2

                vec3 normal = getNormal(coord);
                color      *= AmbientOcclusionLOW(vec3(coord, depth), normal, 0.5) * SSAO_STRENGTH + (1 - SSAO_STRENGTH);

            #elif SSAO_QUALITY == 3

                vec3 normal = getNormal(coord);
                color       *= AmbientOcclusionHIGH(vec3(coord, depth), normal, 0.5) * SSAO_STRENGTH + (1 - SSAO_STRENGTH);

            #endif
            
        }

    #endif

    gl_FragData[0] = vec4(color, 1.0);
}