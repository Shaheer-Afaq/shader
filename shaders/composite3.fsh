#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform mat4 gbufferProjection;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform int worldTime;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform float frameTimeCounter;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

void main() {
    color.xyz = texture(colortex0, texcoord).rgb;
    
    vec4 sunPosClip = gbufferProjection * vec4(sunPosition, 1.0);
    vec3 sunPosNDC = sunPosClip.xyz / sunPosClip.w;
    vec2 sunScreenPos = sunPosNDC.xy * 0.5 + 0.5;

    vec2 aspectVec = vec2(viewWidth / viewHeight, 1.0);
    float distToSun = distance(texcoord * aspectVec, sunScreenPos * aspectVec);
    
    float glare = exp(-distToSun * 20.0) * 0.8;

    float rays = 0.0;
    vec2 relPos = (texcoord - sunScreenPos) * aspectVec;
    float angle = atan(relPos.y, relPos.x);
    
    for(int i = 0; i < 6; i++) {
        float rayAngle = float(i)/6.0 * 6.2831 + sin(frameTimeCounter * 0.5) * 0.1 * ((i % 2 == 0) ? 1.0 : -1.0);
        float beam = cos(angle - rayAngle);
        beam = pow(max(0.0, beam), 700.0);
        beam *= exp(-distToSun * 2.5);
        rays += beam;
    }
    
    float depth = texture(depthtex0, texcoord).r;
    float sunDepth = texture(depthtex0, sunScreenPos).r;
    if (depth < 0.9999) {
        glare = 0.0;
    }

    if (sunDepth < 1.0) {
        rays = 0.0;
    }   

    float sunrise = smoothstep(0.0, 1000.0, float(worldTime));
    float sunset = smoothstep(13000.0, 12000.0, float(worldTime));
    float timeWeatherLimit = min(sunrise, sunset) * (1.0 - rainStrength);

    if (sunPosNDC.z > 0.0 && (worldTime > 23400 || worldTime >= 0) && worldTime < 12700){
        vec3 glareTint = vec3(0.9, 0.8, 0.7);
        color.rgb += glareTint * glare * timeWeatherLimit;
        color.rgb += glareTint * rays * 0.4 * timeWeatherLimit;
    }
}