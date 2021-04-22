#version 130

#include "/lib/math.glsl"
#include "/lib/framebuffer.glsl"
#include "/lib/kernels.glsl"

#define SSR_DENOISE
#define SSR_DENOISE_AMOUNT 1.5          // Denoise Amount                    [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5]

#define DENOISER_THRESHOLD 0.5          // Denoise sensitivity               [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define DENOISER_QUALITY   2            // Denoise Quality                   [1 2 3]
//#define DENOISER_DEBUG

#define OUTLINE
#define OUTLINE_DISTANCE 100            // How far does the outline reach    [50 75 100 125 150 175 200 225 250 275 300]
#define OUTLINE_BRIGHTNESS 1.0          // How bright is the outline         [0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

uniform int worldTime;

in vec2 coord;

flat in vec2 x3_kernel[9];


vec2 pixelSize = vec2(1 / viewWidth, 1 / viewHeight);

float separationDetect(vec2 coord) {
    float edgeColor;
    float edgeColors[4] = float[](0,0,0,0);

    for (int i = 0; i < 9; i++) {
        float ccolor = getDepth_interpolated(x3_kernel[i]);

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
    float depthSurround = getDepth_interpolated((pixelSize * 1.5) + coord) + getDepth_interpolated((pixelSize * -1.5) + coord) + getDepth_interpolated(vec2(pixelSize.x * 1.5, pixelSize.y * -1.5) + coord) + getDepth_interpolated(vec2(pixelSize.x * -1.5, pixelSize.y * 1.5) + coord);
    depthSurround *= 0.25;

    return clamp((abs(depthSurround - depth) * OUTLINE_DISTANCE) - 0.075, 0, OUTLINE_BRIGHTNESS);
}

// 2-Sample Despecler
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

// 4-Sample Despecler
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

// 8-Sample Despecler
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


/* DRAWBUFFERS:0 */

void main() {
    vec3 color;

    vec2 newcoord = coord;

    #ifdef SSR_DENOISE

        if (getType(newcoord) == 3) {

            // Select different despeclers for different denoising qualities
            #if DENOISER_QUALITY == 3
                color = AntiSpeckleX8(newcoord, DENOISER_THRESHOLD, SSR_DENOISE_AMOUNT);
            #elif DENOISER_QUALITY == 2
                color = AntiSpeckleX4(newcoord, DENOISER_THRESHOLD, SSR_DENOISE_AMOUNT);
            #else
                color = AntiSpeckleX2(newcoord, DENOISER_THRESHOLD, SSR_DENOISE_AMOUNT);
            #endif

        } else {

            color = getAlbedo(newcoord);

        }

    #else

        color = getAlbedo(newcoord);

    #endif

    #ifdef OUTLINE
        color = mix(color, vec3(1), depthEdgeFast(newcoord));
    #endif

    //Pass everything forward
    FD0          = vec4(color, 1);
}