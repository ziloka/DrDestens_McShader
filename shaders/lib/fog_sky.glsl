uniform float daynight;
uniform float sunset;
uniform float rainStrength;
uniform vec3  fogColor;

/* // My original values
const vec3 sky_up_day   = vec3(0.1, 0.35, 1.0);  //Color of upper part of sky at noon
const vec3 sky_up_night = vec3(0.1, 0.13, 0.25); //Color of upper part of sky at midnight
const vec3 end_sky_up   = vec3(0.2, 0, 0.3);  // Color of the upper sky in the end
const vec3 end_sky_down = vec3(0.05, 0, 0.1); // Color of the lower sky in the end
*/



const vec3 end_sky_up   = vec3(END_SKY_UP_R, END_SKY_UP_G, END_SKY_UP_B);  // Color of the upper sky in the end
const vec3 end_sky_down = vec3(END_SKY_DOWN_R, END_SKY_DOWN_G, END_SKY_DOWN_B); // Color of the lower sky in the end


const vec3 sky_sunset = vec3(SKY_SUNSET_R, SKY_SUNSET_G, SKY_SUNSET_B);

const vec3 sky_day   = vec3(SKY_DAY_R,   SKY_DAY_G,   SKY_DAY_B);
const vec3 sky_night = vec3(SKY_NIGHT_R, SKY_NIGHT_G, SKY_NIGHT_B);
const vec3 sky_day_rain   = vec3(SKY_DAY_RAIN_R,   SKY_DAY_RAIN_G,   SKY_DAY_RAIN_B);
const vec3 sky_night_rain = vec3(SKY_NIGHT_RAIN_R, SKY_NIGHT_RAIN_G, SKY_NIGHT_RAIN_B);

const vec3 fog_day   = vec3(FOG_DAY_R, FOG_DAY_G, FOG_DAY_B);
const vec3 fog_night = vec3(FOG_NIGHT_R, FOG_NIGHT_G, FOG_NIGHT_B);
const vec3 fog_day_rain   = vec3(FOG_DAY_RAIN_R,   FOG_DAY_RAIN_G,   FOG_DAY_RAIN_B);
const vec3 fog_night_rain = vec3(FOG_NIGHT_RAIN_R, FOG_NIGHT_RAIN_G, FOG_NIGHT_RAIN_B);

vec3 getSkyColor(vec3 viewPos) {

    #ifdef NETHER

        return fogColor;

    #elif defined END 

        vec3  eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
        float viewHeight   = clamp(eyePlayerPos.y / sqrt(dot(eyePlayerPos, eyePlayerPos)) * 0.55 + 0.45, 0, 1);

        float offset       = noise(vec2(atan(abs(eyePlayerPos.z / eyePlayerPos.x))) * PI);
        offset            *= 1 - sq(viewHeight * 2 - 1);
        offset             = offset * 0.1 - 0.05;
        viewHeight         = saturate(viewHeight + offset);

        return mix(end_sky_down, end_sky_up, viewHeight);

    #else

        vec3  eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
        float viewHeight   = saturate(eyePlayerPos.y * inversesqrt(dot(eyePlayerPos, eyePlayerPos)) * 0.9 + 0.1);

        vec3  upperSky     = mix(sky_night, sky_day, daynight);
        vec3  upperSkyRain = mix(sky_night_rain, sky_day_rain, daynight);

        vec3  lowerSky     = mix(fog_night, fog_day, daynight);
        vec3  lowerSkyRain = mix(fog_night_rain, fog_day_rain, daynight);

        return mix(mix(lowerSky, lowerSkyRain, rainStrength), mix(upperSky, upperSkyRain, rainStrength), viewHeight);

    #endif

}

vec3 getFogColor(vec3 viewPos, int eyeWater) {
    if (eyeWater == 0) {
        return getSkyColor(viewPos);
    } else if (eyeWater == 1) {
        return fogColor * 0.25;
    } else {
        return fogColor;
    }
}