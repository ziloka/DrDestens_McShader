#version 130

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    DENOISE AND OUTLINE
//////////////////////////////////////////////////////////////////////////////////////////////////////////


#include "/lib/settings.glsl"
#include "/lib/math.glsl"
#include "/lib/transform.glsl"
#include "/lib/framebuffer.glsl"
#include "/lib/kernels.glsl"

uniform int   worldTime;
uniform vec3  fogColor;
uniform vec3  sunPosition;

in vec2 coord;

flat in vec2 x3_kernel[9];


vec2 pixelSize = vec2(1 / viewWidth, 1 / viewHeight);

float separationDetect(vec2 coord) {
    float edgeColor;
    float edgeColors[4] = float[](0,0,0,0);

    for (int i = 0; i < 9; i++) {
        float ccolor = getDepth_int(x3_kernel[i]);

        edgeColors[0] += ccolor * sobel_vertical[i];
        edgeColors[2] += ccolor * sobel_horizontal[i];

        edgeColors[1] += ccolor * -sobel_vertical[i];
        edgeColors[3] += ccolor * -sobel_horizontal[i];
    }

    edgeColor = abs(edgeColors[0]) + abs(edgeColors[1]) + abs(edgeColors[2]) + abs(edgeColors[3]);

    edgeColor = min(edgeColor * 2, 1);
    return edgeColor;
}

float depthEdgeFast(vec2 coord) {
    float depth         = getDepth(coord);
    // Use trick with linear interpolation to sample 16 pixels with 4 texture calls, and use the overall difference to calculate the edge
    float depthSurround = getDepth_int((pixelSize * 1.5) + coord) + getDepth_int((pixelSize * -1.5) + coord) + getDepth_int(vec2(pixelSize.x * 1.5, pixelSize.y * -1.5) + coord) + getDepth_int(vec2(pixelSize.x * -1.5, pixelSize.y * 1.5) + coord);
    depthSurround *= 0.25;

    return clamp((abs(depthSurround - depth) * OUTLINE_DISTANCE) - 0.075, 0, OUTLINE_BRIGHTNESS);
}

// 2-Sample Dark Priority Despecler
vec3 AntiSpeckleX2(vec2 coord, float threshold, float amount) {
    float pixelOffsetX = pixelSize.x * amount;

    vec3 color           = getAlbedo(coord);

    vec3 color_surround[2]  = vec3[2](
        getAlbedo_int(vec2(coord.x + pixelOffsetX,  coord.y)),
        getAlbedo_int(vec2(coord.x - pixelOffsetX,  coord.y))
    );


    #ifdef DENOISER_DEBUG
    for (int i = 0; i < 2; i++) {
        if ((sum(color) - sum(color_surround[i])) > threshold) {color = vec3(1,0,0);}
    }
    #else

    for (int i = 0; i < 2; i++) {
        if ((sum(color) - sum(color_surround[i])) > threshold) {color = color_surround[i];}
    }

    #endif

    return color;
}

// 4-Sample Dark Priority Despecler
vec3 AntiSpeckleX4(vec2 coord, float threshold, float amount) {
    vec2 pixelOffset = pixelSize * amount;

    vec3 color           = getAlbedo(coord);
    vec2 coordOffsetPos  = coord + pixelOffset;
    vec2 coordOffsetNeg  = coord - pixelOffset;

    vec3 color_surround[4]  = vec3[4](
        getAlbedo_int(vec2(coordOffsetPos.x,  coordOffsetPos.y)),
        getAlbedo_int(vec2(coordOffsetNeg.x,  coordOffsetPos.y)),
        getAlbedo_int(vec2(coordOffsetNeg.x,  coordOffsetNeg.y)),
        getAlbedo_int(vec2(coordOffsetPos.x,  coordOffsetNeg.y))
    );


    #ifdef DENOISER_DEBUG
    for (int i = 0; i < 4; i++) {
        if ((sum(color) - sum(color_surround[i])) > threshold) {color = vec3(1,0,0);}
    }
    #else

    for (int i = 0; i < 4; i++) {
        if ((sum(color) - sum(color_surround[i])) > threshold) {color = color_surround[i];}
    }

    #endif

    return color;
}

// 8-Sample Dark Priority Despecler
vec3 AntiSpeckleX8(vec2 coord, float threshold, float amount) {
    vec2 pixelOffset = pixelSize * amount;

    vec3 color           = getAlbedo(coord);
    vec2 coordOffsetPos  = coord + pixelOffset;
    vec2 coordOffsetNeg  = coord - pixelOffset;

    vec3 color_surround[8]  = vec3[8](
        getAlbedo_int(vec2(coordOffsetPos.x,  coord.y         )),
        getAlbedo_int(vec2(coordOffsetPos.x,  coordOffsetPos.y)),
        getAlbedo_int(vec2(coord.x,           coordOffsetPos.y)),
        getAlbedo_int(vec2(coordOffsetNeg.x,  coordOffsetPos.y)),
        getAlbedo_int(vec2(coordOffsetNeg.x,  coord.y         )),
        getAlbedo_int(vec2(coordOffsetNeg.x,  coordOffsetNeg.y)),
        getAlbedo_int(vec2(coord.x,           coordOffsetNeg.y)),
        getAlbedo_int(vec2(coordOffsetPos.x,  coordOffsetNeg.y))
    );

    #ifdef DENOISER_DEBUG
    for (int i = 0; i < 8; i++) {
        if ((sum(color) - sum(color_surround[i])) > threshold) {color = vec3(1,0,0);}
    }
    #else

    for (int i = 0; i < 8; i++) {
        if ((sum(color) - sum(color_surround[i])) > threshold) {color = color_surround[i];}
    }

    #endif

    return color;
}



// 2-Sample Mean Denoiser
vec3 DenoiseMeanL(vec2 coord, float threshold, float amount) {
    float pixelOffsetX = pixelSize.x * amount;

    vec3 color           = getAlbedo(coord);

    vec3 color_surround[2]  = vec3[2](
        getAlbedo_int(vec2(coord.x + pixelOffsetX,  coord.y)),
        getAlbedo_int(vec2(coord.x - pixelOffsetX,  coord.y))
    );
    
    float average     = sum(color+color_surround[0]+color_surround[1]) / 3;
    float close       = abs(sum(color) - average);
    vec3 closestColor = color;

    for (int i = 0; i < 2; i++) {
        float diff = abs(sum(color_surround[i]) - average);
        if (diff < close) {
            close        = diff;
            closestColor = color_surround[i];
        }
    }

    return closestColor;
}

// 4-Sample Mean Denoiser
vec3 DenoiseMeanM(vec2 coord, float threshold, float amount) {
    vec2 pixelOffset = pixelSize * amount;

    vec3 color           = getAlbedo(coord);
    vec2 coordOffsetPos  = coord + pixelOffset;
    vec2 coordOffsetNeg  = coord - pixelOffset;

    vec3 color_surround[4]  = vec3[4](
        getAlbedo_int(vec2(coordOffsetPos.x,  coordOffsetPos.y)),
        getAlbedo_int(vec2(coordOffsetNeg.x,  coordOffsetPos.y)),
        getAlbedo_int(vec2(coordOffsetNeg.x,  coordOffsetNeg.y)),
        getAlbedo_int(vec2(coordOffsetPos.x,  coordOffsetNeg.y))
    );

    float average     = sum(color+color_surround[0]+color_surround[1]+color_surround[2]+color_surround[3]) * 0.2;
    float close       = abs(sum(color) - average);
    vec3 closestColor = color;

    for (int i = 0; i < 4; i++) {
        float diff = abs(sum(color_surround[i]) - average);
        if (diff < close) {
            close        = diff;
            closestColor = color_surround[i];
        }
    }

    return closestColor;
}

// 8-Sample Mean Denoiser
vec3 DenoiseMeanH(vec2 coord, float threshold, float amount) {
    vec2 pixelOffset = pixelSize * amount;

    vec3 color           = getAlbedo(coord);
    vec2 coordOffsetPos  = coord + pixelOffset;
    vec2 coordOffsetNeg  = coord - pixelOffset;

    vec3 color_surround[8]  = vec3[8](
        getAlbedo_int(vec2(coordOffsetPos.x,  coord.y         )),
        getAlbedo_int(vec2(coordOffsetPos.x,  coordOffsetPos.y)),
        getAlbedo_int(vec2(coord.x,           coordOffsetPos.y)),
        getAlbedo_int(vec2(coordOffsetNeg.x,  coordOffsetPos.y)),
        getAlbedo_int(vec2(coordOffsetNeg.x,  coord.y         )),
        getAlbedo_int(vec2(coordOffsetNeg.x,  coordOffsetNeg.y)),
        getAlbedo_int(vec2(coord.x,           coordOffsetNeg.y)),
        getAlbedo_int(vec2(coordOffsetPos.x,  coordOffsetNeg.y))
    );

    float average     = sum(color+color_surround[0]+color_surround[1]+color_surround[2]+color_surround[3]+color_surround[4]+color_surround[5]+color_surround[6]+color_surround[7]) / 9;
    float close       = abs(sum(color) - average);
    vec3 closestColor = color;

    for (int i = 0; i < 8; i++) {
        float diff = abs(sum(color_surround[i]) - average);
        if (diff < close) {
            close = diff;
            closestColor = color_surround[i];
        }
    }

    return closestColor;
}


/* DRAWBUFFERS:0 */

void main() {
    vec3 color;
    float depth = getDepth(coord);

    vec2 newcoord = coord;

    #ifdef SSR_DENOISE

        if (getType(newcoord) == 3) {

            // Select different despeclers for different denoising qualities
            #if DENOISER_QUALITY == 3
                color = DenoiseMeanH(newcoord, DENOISER_THRESHOLD, SSR_DENOISE_AMOUNT);
            #elif DENOISER_QUALITY == 2
                color = DenoiseMeanM(newcoord, DENOISER_THRESHOLD, SSR_DENOISE_AMOUNT);
            #else
                color = DenoiseMeanL(newcoord, DENOISER_THRESHOLD, SSR_DENOISE_AMOUNT);
            #endif

        } else {

            color = getAlbedo(newcoord);

        }

    #else

        color = getAlbedo(newcoord);

    #endif


    #ifdef FOG

        // Fog
        // Increase Fog when looking at sun/moon
        vec4  sunProjection  = gbufferProjection * vec4(sunPosition, 1.0);
        vec3  sunScreenSpace = (sunProjection.xyz / sunProjection.w) * 0.5 + 0.5;
        float sunDist        = clamp(distance(coord, sunScreenSpace.xy), 0, 1);
        float sunFog         = smoothstep(0.5, 1, 1-sunDist) * 2;

        // Blend between FogColor and normal color based on sqare distance
        vec3  playerpos = toPlayerEye(toView(vec3(coord, depth) * 2 - 1));
        float dist      = dot(playerpos, playerpos) * float(depth != 1);
        float fog       = clamp(dist * 3e-6 * FOG_AMOUNT * (sunFog + 1), 0, 1);

        color           = mix(color, (color * 0.1) + fogColor, fog);

    #endif

    #ifdef OUTLINE
        color = mix(color, vec3(1), depthEdgeFast(newcoord));
    #endif

    //Pass everything forward
    FD0          = vec4(color, 1);
}